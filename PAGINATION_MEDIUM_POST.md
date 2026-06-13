# Paginated UICollectionView using DiffableDataSource, MVVM and Async/Await

*How to build a smooth, infinitely scrolling product list in UIKit — with placeholder cells, cancellable network requests, and zero `reloadData()` calls.*

---

## Introduction

Pagination is one of those features that looks trivial on a whiteboard and turns into a mess in production. You start with "just load more when the user scrolls to the bottom," and a week later you're fighting duplicate network calls, flickering cells, race conditions between an old search and a new one, and a `UICollectionView` that jumps around every time new data arrives.

In this article I'll walk through a pagination implementation I'm genuinely happy with. It combines three modern tools that complement each other beautifully:

- **`UICollectionViewDiffableDataSource`** — so we never call `reloadData()` and never compute index paths by hand.
- **MVVM** — so the networking, paging math, and request de-duplication live in a testable `ViewModel`, not in the view controller.
- **Async/await + structured concurrency** — so each page is a cancellable `Task`, and starting a new search cleanly tears down the in-flight requests of the old one.

The example is a product search screen (`ProductSearchViewController` + `ProductSearchViewModel`) from a sample e‑commerce app. Let's build it up piece by piece.

**What you'll learn:**

- Modelling a paginated result as a *sparse array* of optionals
- Driving a diffable snapshot from real items **and** placeholder cells
- Triggering the next page from `willDisplay` instead of scroll-offset math
- De-duplicating and cancelling page requests with `Task` and a lock
- Keeping the View dumb and the ViewModel in charge

---

## The Core Idea: A Sparse Array of Optionals

Most pagination tutorials append pages to a growing `[Item]` array: you have 20 items, you load 20 more, now you have 40. That works, but it throws away a very useful piece of information the backend already gave you — **how many items exist in total**.

If we know the total up front, we can allocate the whole array immediately and fill it in lazily:

```swift
struct ProductSearchResult: CustomDebugStringConvertible {

    var search: String?
    var products: [ProductModel?]   // <- the whole list, mostly nil at first
    var total: Int
    var skip: Int
    var limit: Int

    var lastFetched: [ProductModel]

    init(search: String? = nil, products lastFetched: [ProductModel], total: Int, skip: Int, limit: Int) {
        self.products = Array(repeating: nil, count: total)   // allocate `total` empty slots
        self.lastFetched = lastFetched
        self.total = total
        self.skip = skip
        self.limit = limit
        self.update(products: lastFetched, skip: skip, limit: limit)
    }

    mutating func update(products lastFetched: [ProductModel], skip: Int, limit: Int) {
        let start = self.products.startIndex.advanced(by: skip)
        let end = start.advanced(by: lastFetched.endIndex - 1)
        guard start <= end else { return }
        let range = start...end
        guard start >= self.products.startIndex,
              end <= self.products.endIndex
        else {
            return
        }
        self.products.replaceSubrange(range, with: lastFetched)
        self.skip = skip
        self.limit = limit
    }
}
```

The key insight is `products: [ProductModel?]`. If the backend says there are 200 products, `products` is a 200-element array where every slot starts as `nil`. As pages come in, `update(products:skip:limit:)` splices the freshly fetched page into the correct range — page 0 fills indices `0..<20`, page 3 fills `60..<80`, and so on.

This gives us something powerful for free: **a `nil` slot means "this product exists but hasn't loaded yet."** That's exactly the signal we need to show a placeholder cell and to know when to fetch the next page. We don't need a separate "isLoadingMore" flag or a sentinel item — the shape of the data tells us everything.

---

## The ViewModel: Paging Math, De-duplication, and Cancellation

The ViewModel owns all the hard parts. It exposes a tiny protocol to the View:

```swift
protocol ProductSearchViewModelType: AnyObject, Sendable {

    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }

    var searchText: String { get set }

    var searchResultsPublisher: AnyPublisher<ProductSearchResult?, Never> { get }

    func fetch(item: Int)
}

extension ProductSearchViewModelType {
    func fetch() {
        self.fetch(item: 0)
    }
}
```

Notice the API the View gets is almost insultingly simple: set `searchText`, observe `searchResultsPublisher`, and call `fetch(item:)` with the index of a cell that's about to appear. Everything else — which page that index belongs to, whether it's already loading, whether to cancel — is the ViewModel's job.

### Setting up the reactive pipeline

```swift
@MainActor
final class ProductSearchViewModel: @preconcurrency ProductSearchViewModelType {

    var searchText: String = "" {
        didSet { self.fetch() }   // a new search resets everything
    }

    private var searchResultsValueSubject = CurrentValueSubject<ProductSearchResult?, Never>(nil)
    var searchResultsPublisher: AnyPublisher<ProductSearchResult?, Never> {
        return self.searchResultsValueSubject.eraseToAnyPublisher()
    }

    // One in-flight Task per page, keyed by page number
    var fetchTasks: [Int: Task<ProductSearchResult?, Error>] = [:]

    @Injected(\.productService)
    private var productService: any ProductServiceType

    private var lock = NSLock()
}
```

Two fields do the heavy lifting:

- `searchResultsValueSubject` is a `CurrentValueSubject` holding the current sparse result. The View subscribes to it and rebuilds its snapshot whenever it changes.
- `fetchTasks` is a dictionary of **one `Task` per page**. This is how we de-duplicate: if page 2 is already loading, we won't kick off a second request for it.

### The `fetch(item:)` method

This is the heart of the implementation. Read it slowly:

```swift
func fetch(item: Int) {

    self.lock.lock()

    if item == 0 {
        // Initial search or new search: tear down everything in flight
        self.fetchTasks.forEach { $1.cancel() }
        self.fetchTasks.removeAll()
        self.searchResultsValueSubject.value = nil
    }

    let page: Int = item / .defaultPageSize

    // De-dup #1: this page is already being fetched
    guard self.fetchTasks[page] == nil else {
        self.lock.unlock()
        return
    }

    // De-dup #2: this slot is already filled
    if let products = self.searchResultsValueSubject.value?.products,
       products.indices.contains(item),
       products[item] != .none {
        self.lock.unlock()
        return
    }

    let fetchTask = Task { [page] () throws -> ProductSearchResult? in
        let result = try await self.productService.fetch(search: self.searchText,
                                                         brands: self.selectedBrands,
                                                         categories: self.selectedCategories,
                                                         limit: .defaultPageSize,
                                                         skip: page * .defaultPageSize)
        return result
    }

    self.set(task: fetchTask, at: page)
    self.lock.unlock()

    Task {
        guard !fetchTask.isCancelled else { return }
        guard let result: ProductSearchResult = try await fetchTask.value else { return }
        let page = result.skip / .defaultPageSize

        self.lock.withLock {
            if var current = self.searchResultsValueSubject.value {
                current.update(products: result.lastFetched, skip: result.skip, limit: result.limit)
                self.searchResultsValueSubject.value = current
            } else {
                self.searchResultsValueSubject.value = result
            }
            self.set(task: nil, at: page)
        }
    }
}
```

There's a lot of careful engineering packed in here, so let's unpack the decisions:

**1. `item == 0` means "start over."** When the user types a new query (or pulls to refresh), we cancel every in-flight `Task`, empty `fetchTasks`, and reset the published result to `nil`. Structured concurrency makes this clean — `task.cancel()` propagates cancellation into the `await`, and the suspended network call unwinds. No orphaned responses from the previous search will sneak in and corrupt the new one.

**2. Index → page math.** `let page = item / .defaultPageSize`. With a page size of 20, cell index 0–19 is page 0, 20–39 is page 1, etc. The backend is called with `skip: page * .defaultPageSize`. The View never has to know any of this; it just hands over a cell index.

**3. Two layers of de-duplication.** Because `willDisplay` can fire many times for the same region, we guard twice: once on "is a `Task` already running for this page?" and once on "is this slot already populated?" Either guard short-circuits and we make zero extra network calls.

**4. An `NSLock` around the mutable state.** `fetchTasks` and the subject are touched from multiple `Task`s. The lock keeps the check-then-insert sequence atomic so two cells appearing on the same frame can't both start a request for the same page.

**5. Splice, don't replace.** When a page arrives, we don't overwrite the whole result — we `update(...)` the existing sparse array in place, preserving every other page that's already loaded. Then we re-publish so the View can diff.

The helper that keeps the loading flag in sync:

```swift
private func set(task: Task<ProductSearchResult?, Error>?, at index: Int) {
    self.fetchTasks[index] = task
    self.isLoadingValueSubject.value = !self.fetchTasks.isEmpty
}
```

`isLoading` is simply "are there any tasks in flight?" — derived state, not something we set by hand in five different places.

---

## The View: DiffableDataSource Driven by the Snapshot

Now the fun part. The view controller declares its data source over two custom types — a `Section` and an `Item`:

```swift
@IBOutlet weak var productCollectionView: UICollectionView!
var productDataSource: UICollectionViewDiffableDataSource<Section, Item>!
```

### Section and Item

```swift
extension ProductSearchViewController {

    enum Section: Hashable, @unchecked Sendable {
        case products([ProductModel])
        case placeholders([Item])
        // ... custom Hashable/Equatable below
    }

    enum Item: Hashable, @unchecked Sendable {
        case product(ProductModel)
        case placeholder(NSObject = NSObject())
        // ...
    }
}
```

The `Item` enum is the crucial bit. A row is **either** a real `.product` **or** a `.placeholder`. Each placeholder wraps a fresh `NSObject`, which guarantees every placeholder is unique for diffing purposes — so the data source treats two placeholder cells as distinct items and animates them independently.

### The cell provider

The same cell renders both states. A real product configures itself; a placeholder just spins an activity indicator:

```swift
self.productDataSource = .init(collectionView: self.productCollectionView) { collectionView, indexPath, content in
    let cell = collectionView.dequeue(cell: ProductCollectionViewCell.self, for: indexPath)
    switch content {
        case .product(let product):
            cell.configure(with: product)
            cell.seperator.isHidden = collectionView.isLastInSection(indexPath)
            cell.activityIndicator.stopAnimating()
        case .placeholder:
            cell.activityIndicator.startAnimating()
    }
    return cell
}
```

### Building the snapshot from the sparse result

Whenever the ViewModel publishes a new `ProductSearchResult`, the View rebuilds a snapshot. Real products are grouped by brand into sections; the still-`nil` slots become a trailing section of placeholders:

```swift
self.viewModel.searchResultsPublisher
    .receive(on: RunLoop.main)
    .sink { [weak self] searchResults in

        self?.refreshControl.endRefreshing()

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        guard let searchResults else {
            self?.productDataSource?.apply(snapshot)   // empty snapshot = clear screen
            return
        }

        // Real, loaded products -> grouped into sections by brand
        let grouped = searchResults.products
            .filter { $0.exists }
            .compactMap { $0 }
            .grouped(by: \.brand)

        for brand in grouped.keys.sorted() {
            guard let group = grouped[brand] else { continue }
            snapshot.appendSections([.products(group)])
            snapshot.appendItems(group.map { Item.product($0) })
        }

        // Every nil slot -> a placeholder item
        let placeholders: [Item] = searchResults.products
            .filter { $0.isNil }
            .map { _ in Item.placeholder() }

        if !placeholders.isEmpty {
            snapshot.appendSections([.placeholders(placeholders)])
            snapshot.appendItems(placeholders)
        }

        self?.productDataSource?.apply(snapshot)
    }
    .store(in: &self.cancellables)
```

Because we `apply` a diffable snapshot, the collection view computes the minimal set of inserts/moves/deletes itself and animates them. As page 2 lands, its 20 placeholder cells are diffed away and replaced by real product cells — no flicker, no manual `performBatchUpdates`, no index-path bookkeeping.

### Triggering the next page

Here's where it all comes together. We don't do scroll-offset math. Instead, we let the collection view tell us a placeholder is about to appear, and we ask the ViewModel to fill it:

```swift
func collectionView(_ collectionView: UICollectionView,
                    willDisplay cell: UICollectionViewCell,
                    forItemAt indexPath: IndexPath) {
    guard collectionView == self.productCollectionView else { return }

    let itemIdentifier = self.productDataSource?.itemIdentifier(for: indexPath)
    switch itemIdentifier {
        case .placeholder:
            guard let index = self.productCollectionView.indexPaths.firstIndex(of: indexPath) else { return }
            self.viewModel.fetch(item: index)
        default:
            break
    }
}
```

When a placeholder cell scrolls into view, we compute its flat index and call `fetch(item:)`. The ViewModel converts that index to a page, checks its de-dup guards, and fires exactly one request if needed. The result splices into the sparse array, gets republished, and the snapshot swaps the placeholder for a real cell. The loop is self-sustaining: scroll → placeholder appears → fetch → real cells appear → more placeholders below → repeat.

---

## Putting It All Together

Here's the full round trip for a single page:

```
User scrolls
   │
   ▼
placeholder cell enters viewport
   │  willDisplay(forItemAt:)
   ▼
viewModel.fetch(item: 42)
   │  page = 42 / 20 = 2
   │  guard: page 2 not already loading? not already filled?
   ▼
Task { await productService.fetch(skip: 40, limit: 20) }
   │  (cancellable; cancelled wholesale on a new search)
   ▼
result spliced into products[40..<60]
   │  searchResultsValueSubject.value = updated
   ▼
View rebuilds NSDiffableDataSourceSnapshot
   │  apply() diffs placeholders -> real cells
   ▼
Cells animate in. Fresh placeholders below trigger the next page.
```

The responsibilities stay clean:

- **The Model** (`ProductSearchResult`) knows the *shape* of the data — total size, which slots are filled.
- **The ViewModel** knows the *rules* — page math, de-duplication, cancellation, when to reset.
- **The View** knows the *presentation* — how to turn a sparse result into sections, cells, and placeholders, and when to ask for more.

No massive view controller, no networking in the UI layer, and no manual diffing.

---

## Gotchas and Two Bugs Worth Dissecting

While writing this article I found two real bugs in the implementation. Both are instructive, because they're the *kind* of bug this whole architecture is prone to — so let's dissect them rather than sweep them under the rug.

### Bug #1: Paginating over a non-total sort order

This is the big one, and it's the bug that makes pagination "mostly work" until it mysteriously doesn't — the worst kind. The backend sorted results by brand before slicing them into pages:

```swift
// Backend — before
products = products.sorted(by: { ($0.brand ?? "") < ($1.brand ?? "") })
let skipped = products.suffix(from: parameters.skip)
let limited = skipped.prefix(response.limit)
```

The problem: **`brand` is not a unique key.** Loads of products share a brand, and many have no brand at all (they collapse to `""` and all tie). Now consider that *every page request re-runs this entire pipeline* — re-fetch the full list, re-filter, re-sort, then slice out `skip..<skip+limit`. Swift's `sorted(by:)` makes **no stability guarantee**, so when a batch of products compares equal, their order after sorting is unspecified and can differ from one call to the next.

The consequence is subtle and nasty. Page 0 is sliced from one ordering; page 1 is sliced from a *different* ordering of the same tied elements. An item sitting near the boundary can land in both slices (**duplicated**) or in neither (**skipped**). You won't see it in the first screen of results — it shows up as the occasional doubled or missing product deep in a long list, which is exactly the kind of thing that's miserable to reproduce.

The rule to internalize: **you can only paginate over a *total* ordering** — one with no ties, that's identical on every request. The fix is a one-liner: add the unique `id` as a tiebreaker.

```swift
// Backend — after
products = products.sorted(by: { ($0.brand ?? "", $0.id) < ($1.brand ?? "", $1.id) })
```

Swift compares `(String, Int)` tuples lexicographically, so this orders by brand and then breaks every tie deterministically by `id`. The order is now total, reproducible across requests, and — not coincidentally — matches the client, which displays products grouped by brand and whose `ProductModel` is `Comparable` by `id`. Both ends finally agree on one canonical order, which is the whole ballgame for pagination.

### Bug #2: A load-bearing typo in `Equatable`

Diffable data sources lean *entirely* on `Hashable`/`Equatable` to compute their diffs. A subtle typo in an `==` implementation makes the diff misbehave — cells that should update don't, or vice versa. `ProductModel` had one:

```swift
// Before
guard !(lhs.isPlaceholder || lhs.isPlaceholder) else { return false }
//                            ^^^ should be rhs.isPlaceholder
// After
guard !(lhs.isPlaceholder || rhs.isPlaceholder) else { return false }
```

It referenced `lhs` twice instead of comparing both sides. It was *mostly* harmless here because placeholders are modelled as a separate `Item.placeholder` case and `ProductModel` hashes only on `id` — but it's precisely the kind of bug that bites the moment your equality logic gets more interesting. Audit your `==` and `hash(into:)` carefully; in a diffable world they're load-bearing.

### And one design trade-off (not a bug)

`willDisplay`-based prefetch is **coarse**. Triggering on the first visible placeholder is dead simple and works well, but it fetches a touch late. For buttery infinite scroll you can switch to `UICollectionViewDataSourcePrefetching` and call `fetch(item:)` for upcoming index paths before they're on screen — and because the paging logic lives entirely in the ViewModel, the API doesn't change at all. That's the payoff of keeping the View dumb.

---

## Conclusion

Pagination doesn't have to be a pile of flags and manual batch updates. By letting three tools each do what they're best at —

- a **sparse `[Model?]`** that encodes "not loaded yet" directly in the data,
- **diffable snapshots** that turn that data into animated cells with no `reloadData()`,
- and **async/await `Task`s** that make each page cancellable and de-dupable,

— you get an infinite list that's smooth, testable, and small enough to reason about. The View stays dumb, the ViewModel stays in control, and adding prefetching or changing the page size is a one-line change.

Give it a try in your next list screen. Once you've shipped pagination this way, the old "append-and-reload" approach feels like doing arithmetic by hand.

---

*The full source — `ProductSearchViewController` and `ProductSearchViewModel` — is part of a three-app MVVM-CS architecture showcase (UIKit, Mixed, and pure SwiftUI). The same paginated ViewModel powers all three.*
