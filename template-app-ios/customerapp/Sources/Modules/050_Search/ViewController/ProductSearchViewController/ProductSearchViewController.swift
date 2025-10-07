
import MustacheFoundation
import MustacheServices
import MustacheUIKit

import MustacheCombine

// TODO: Fix pagination, something is wrong with the way they are sorted on the backend compared to app, for the pagination to work properly sorting should be the same
class ProductSearchViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var searchViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    var filterDataSource: UICollectionViewDiffableDataSource<Int, ProductFilterType>!
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    var productDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    
    // MARK: ViewModel
    
    @Injected
    private var viewModel: ProductSearchViewModelType
    
    // MARK: Coordinator
    
    var coordinator: CoordinatorType!
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    var refreshControl = UIRefreshControl()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configure()
        self.configureFilterCollectionViewLayout()
        self.configureFilterBindings()
        self.configureProductCollectionViewLayout()
        self.configureProductBindings()
    }
    
    // MARK: Configure
    
    private func configure() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.filterCollectionView.backgroundColor = .clear
        self.productCollectionView.backgroundColor = .clear

        self.searchTextField.configure(textStyle: .body, placeholder: Strings.Product.Search.placehoder)
    }
    
    private func configureFilterCollectionViewLayout() {
        
        // MARK: Filter
        self.filterCollectionView.register(nib: ProductFilterTypeCell.self)
        
        // MARK: Products
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.scrollDirection = .horizontal
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(36))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(36))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Spacing.Scale.sm
        section.contentInsets = NSDirectionalEdgeInsets(top: Spacing.Scale.sm, leading: Spacing.Scale.sm, bottom: 0, trailing: Spacing.Scale.lg)
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        self.filterCollectionView.collectionViewLayout = layout
    }
    
    private func configureFilterBindings() {
        
        self.filterDataSource = .init(collectionView: self.filterCollectionView) { (collectionView, indexPath, content) -> UICollectionViewCell? in
            let cell = collectionView.dequeue(cell: ProductFilterTypeCell.self, for: indexPath)
            cell.configure(with: content)
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, ProductFilterType>()
        snapshot.appendSections([0])
        snapshot.appendItems(ProductFilterType.allCases)
        
        self.filterDataSource?.apply(snapshot)
        
        self.filterCollectionView.delegate = self
        
    }
    
    private func configureProductCollectionViewLayout() {
        
        // MARK: Products
        self.productCollectionView.register(nib: ProductCollectionViewCell.self)
        self.productCollectionView.register(supplementaryView: HeaderCell.self, type: .header)
        self.productCollectionView.register(supplementaryView: UICollectionReusableView.self, type: .footer)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Spacing.Common.screenMargin, bottom: 0, trailing: Spacing.Common.screenMargin)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Spacing.Common.cardSpacing
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(16))
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        self.productCollectionView.collectionViewLayout = layout
    }
    
    private func configureProductBindings() {
        
        self.productDataSource = .init(collectionView: self.productCollectionView) { (collectionView, indexPath, content) -> UICollectionViewCell? in
            let cell = collectionView.dequeue(cell: ProductCollectionViewCell.self, for: indexPath)
            switch content {
                case .product(let product):
                    cell.configure(with: product)
                    cell.seperator.isHidden = collectionView.isLastInSection(indexPath)
                    cell.activityIndicator.stopAnimating()
                case .placeholder:
                    cell.activityIndicator.startAnimating()
                    break
            }
            
            return cell
        }
        
        self.productDataSource?.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                
                let content = self.productDataSource?.itemIdentifier(for: indexPath)
                let reusableView = collectionView.dequeue(supplementaryView: HeaderCell.self, type: .header, for: indexPath)
                switch content {
                    case .product(let product) where product.brand.hasElements:
                        reusableView.label.configure(textStyle: .body, text: product.brand, color: .muted)
                    default:
                        reusableView.label.configure(textStyle: .body, text: Strings.Product.Header.NoBrand.title, color: .muted)
                        break
                }
                
                return reusableView
                
            } else {
                let footer = collectionView.dequeue(supplementaryView: UICollectionReusableView.self, type: .footer, for: indexPath)
                return footer
            }
            
        }
        
        self.viewModel.searchResultsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] searchResults in
                
                self?.refreshControl.endRefreshing()
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                
                guard let searchResults else {
                    self?.productDataSource?.apply(snapshot)
                    return
                }
                
                let grouped: [String: [ProductModel]] = searchResults.products.filter { $0.exists }.compactMap({ $0 }).grouped(by: \.brand)
                let sorted = grouped.keys.sorted()
                
                for brand in sorted {
                    guard let group = grouped[brand] else { continue }
                    snapshot.appendSections([.products(group)])
                    let items = group.map { Item.product($0) }
                    snapshot.appendItems(items)
                }
                
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
        
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        self.productCollectionView.delegate = self
        self.productCollectionView.refreshControl = self.refreshControl
        
        // TODO: Check if this leaks
        self.searchTextField.textPublisher()
            .assign(to: \.searchText, on: self.viewModel)
            .store(in: &self.cancellables)
        
    }
    
    // MARK: @IBActions
    
    @IBAction private func toggleSearch() {
        
        if self.searchViewWidthConstraint.constant.isEqual(to: .closedSearchWidth) {
            // Start free text search
            self.filterCollectionView.contentInset.left = 8
            self.searchViewWidthConstraint.constant = self.view.frame.width
            self.searchTextField.becomeFirstResponder()
        } else {
            // End free text search
            self.filterCollectionView.contentInset.left = 0
            self.searchViewWidthConstraint.constant = .closedSearchWidth
            self.searchTextField.text = nil
            self.searchTextField.sendActions(for: .valueChanged)
            self.searchTextField.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func refresh() {
        self.viewModel.fetch()
    }
    
    // MARK: Override UIViewController functions
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    deinit {
        self.cancellables.removeAll()
        debugPrint("deinit \(self)")
    }
}

// MARK: Extensions

extension ProductSearchViewController {
    
    enum Section: Hashable {
        case products([ProductModel])
        case placeholders([Item])
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            switch (rhs, lhs) {
                case (.products(let lhs), .products(let rhs)):
                    return lhs == rhs
                case (.placeholders(let lhs), .placeholders(let rhs)):
                    return lhs == rhs
                default:
                    return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
                case .products(let products):
                    let sectionIdentifer = products.map { $0.id.string }.joined(separator: "-")
                    sectionIdentifer.hash(into: &hasher)
                case .placeholders(let objects):
                    objects.hash(into: &hasher)
            }
            
        }
    }
    
    enum Item: Hashable {
        case product(ProductModel)
        case placeholder(NSObject = NSObject())
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (rhs, lhs) {
                case (.product(let lhs), .product(let rhs)):
                    return lhs == rhs
                case (.placeholder(let lhs), .placeholder(let rhs)):
                    return lhs == rhs
                default:
                    return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
                case .product(let product):
                    product.hash(into: &hasher)
                case .placeholder(let object):
                    object.hash(into: &hasher)
            }
            
        }
    }
}

extension ProductSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
            case self.filterCollectionView:
                guard let itemIdentifier = self.filterDataSource?.itemIdentifier(for: indexPath) else { return }
                try? self.coordinator.transition(to: SearchProductTransition.filter(itemIdentifier))
            case self.productCollectionView:
                let itemIdentifier = self.productDataSource?.itemIdentifier(for: indexPath)
                switch itemIdentifier {
                    case .product(let product):
                        try? self.coordinator.transition(to: SearchProductTransition.details(product))
                    default:
                        break
                }
                collectionView.deselectItem(at: indexPath, animated: true)
            default:
                break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView {
            case self.productCollectionView:
                let itemIdentifier = self.productDataSource?.itemIdentifier(for: indexPath)
                switch itemIdentifier {
                    case .placeholder:
                        guard let index = self.productCollectionView.indexPaths.firstIndex(of: indexPath) else { return }
                        self.viewModel.fetch(item: index)
                    default:
                        break
                }
            default:
                break
        }
    }
}

extension ProductSearchViewController: UITextFieldDelegate {
    
    // This method is called when Return/Done is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CGFloat {
    
    static let closedSearchWidth: CGFloat = 68
    
}
