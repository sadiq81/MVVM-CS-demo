
struct ProductSearchResult: CustomDebugStringConvertible {

    var search: String?
    var products: [ProductModel?]
    var total: Int
    var skip: Int
    var limit: Int

    var lastFetched: [ProductModel]

    init(search: String? = nil, products lastFetched: [ProductModel], total: Int, skip: Int, limit: Int) {
        self.products = Array(repeating: nil, count: total)
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

    var debugDescription: String {
        return "ProductSearchResult(search: \(String(describing: self.search)), " +
        "total: \(self.total), " +
        "skip: \(self.skip), " +
        "limit: \(self.limit)), " +
        "real: \(self.products.compactMap({$0}).count)"
    }

}
