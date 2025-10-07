
import MustacheFoundation
import MustacheServices
import MustacheUIKit
import MustacheCombine

// TODO: Rename to FavoriteProductsViewController
class ProductsViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var tabContainer: UIView!
    @IBOutlet weak var selectedTab: UIView!

    @IBOutlet var amButtonNormal: UIButton!
    @IBOutlet var amButtonSelected: UIButton!
    @IBOutlet var nzButtonNormal: UIButton!
    @IBOutlet var nzButtonSelected: UIButton!

    @IBOutlet weak var selectedTabLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var maskedButtonLeftConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateButton: UIButton!

    // MARK: ViewModel

    @Injected
    var viewModel: ProductsViewModelType

    // MARK: Coordinator

    var coordinator: CoordinatorType!

    // MARK: Delegate

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: UI State Variables

    var refreshControl = UIRefreshControl()
    var dataSource: UICollectionViewDiffableDataSource<Section, ProductModel>!

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configure()
        self.configureCollectionViewLayout()
        self.configureCollectionViewDataSource()
        self.configureBindings()
    }

    // MARK: Configure

    private func configure() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.collectionView.backgroundColor = Colors.Background.default.color

        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
        self.collectionView.delegate = self

        // Empty state
        self.emptyStateTitleLabel.configure(textStyle: .title1, text: Strings.Product.Details.EmptyView.title, color: .default)
        self.emptyStateButton.configure(style: .primary, text: Strings.Product.Details.EmptyView.button)

    }

    private func configureCollectionViewLayout() {

        self.collectionView.register(nib: ProductCollectionViewCell.self)
        self.collectionView.register(supplementaryView: HeaderCell.self, type: .header)
        self.collectionView.register(supplementaryView: UICollectionReusableView.self, type: .footer)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Spacing.Common.screenMargin,
            bottom: 0,
            trailing: Spacing.Common.screenMargin
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Spacing.Common.cardSpacing
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        sectionHeader.pinToVisibleBounds = true

        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(16))
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]

        let layout = UICollectionViewCompositionalLayout(section: section)

        self.collectionView.collectionViewLayout = layout
    }

    private func configureCollectionViewDataSource() {

        self.dataSource = .init(collectionView: self.collectionView) { (collectionView, indexPath, content) -> UICollectionViewCell? in
            let cell = collectionView.dequeue(cell: ProductCollectionViewCell.self, for: indexPath)
            cell.configure(with: content)
            return cell
        }

        self.dataSource?.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self else { return nil }

            if kind == UICollectionView.elementKindSectionHeader {

                let content = self.dataSource?.itemIdentifier(for: indexPath)
                let reusableView = collectionView.dequeue(supplementaryView: HeaderCell.self, type: .header, for: indexPath)
                reusableView.label.text = content?.brand
                return reusableView

            } else {
                let footer = collectionView.dequeue(supplementaryView: UICollectionReusableView.self, type: .footer, for: indexPath)
                return footer
            }

        }

    }

    private func configureBindings() {

        self.viewModel.productsPublisher
            .handleEvents(receiveOutput: { [weak self] models in
                self?.emptyStateView.isHidden = !models.isEmpty
            })
            .receive(on: RunLoop.main)
            .sink { [weak self] products in

                self?.refreshControl.endRefreshing()

                var snapshot = NSDiffableDataSourceSnapshot<Section, ProductModel>()

                if !products.isEmpty {
                    snapshot.appendSections([.products(products)])
                    snapshot.appendItems(products)
                }

                self?.dataSource?.apply(snapshot)
            }
            .store(in: &self.cancellables)

        self.viewModel.publisher(for: .am)
            .map { count in
                if count >= 1 {
                    return Strings.Product.Segment.Am.button(count)
                } else {
                    return Strings.Product.Segment.Am.buttonEmpty
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.amButtonNormal.configure(style: .tertiary, text: title)
                self?.amButtonSelected.configure(style: .primary, text: title)
            }
            .store(in: &self.cancellables)

        self.viewModel.publisher(for: .nz)
            .map { count in
                if count >= 1 {
                    return Strings.Product.Segment.Nz.button(count)
                } else {
                    return Strings.Product.Segment.Nz.buttonEmpty
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.nzButtonNormal.configure(style: .tertiary, text: title)
                self?.nzButtonSelected.configure(style: .primary, text: title)
            }
            .store(in: &self.cancellables)
    }

    // MARK: @IBActions

    @IBAction private func selectedTab(_ sender: UIButton) {

        guard let state = SegmentState(rawValue: sender.tag),
              state != self.viewModel.segmentSubjects.value
        else { return }
        self.viewModel.segmentSubjects.value = state

        UIView.Animator(duration: 0.3)
            .animations { [weak self] in
                guard let self else { return }
                self.maskedButtonLeftConstraint.constant = -sender.tag.cgfloat * sender.frame.width
                self.selectedTabLeftConstraint.constant = sender.frame.minX
                self.view.layoutIfNeeded()
            }
            .animate()
    }

    @objc private func refresh() { Task {
        self.refreshControl.endRefreshing()
    }}
    
    @IBAction private func selectefavorites() {
        try? self.coordinator.transition(to: TabBarTransition.search)
    }

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions

extension ProductsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath) else { return }
        try? self.coordinator.transition(to: ProductTransition.details(itemIdentifier))
    }

}

extension ProductsViewController {

    enum Section: Hashable {

        case products([ProductModel])

        static func == (lhs: Section, rhs: Section) -> Bool {
            switch (rhs, lhs) {
                case (.products(let lhs), .products(let rhs)):
                    return lhs == rhs
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
                case .products(let products):
                    products.hash(into: &hasher)
            }

        }

    }

}
