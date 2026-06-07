import Combine
import UIKit

import MustacheCombine
import MustacheFoundation
import MustacheServices
import MustacheUIKit

final class FavoritesViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateIconImageView: UIImageView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateButton: UIButton!

    // MARK: ViewModel

    @Injected(\.favoritesViewModelType)
    private var viewModel: any FavoritesViewModelType

    // MARK: Coordinator

    var coordinator: (any CoordinatorType)!

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
        self.view.backgroundColor = Colors.Background.default.color
        self.collectionView.backgroundColor = Colors.Background.default.color

        // Segmented control — brand color for selected segment
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.selectedSegmentTintColor = Colors.Background.brand.color
        self.segmentedControl.setTitleTextAttributes([.foregroundColor: Colors.Foreground.light.color], for: .selected)
        self.segmentedControl.setTitleTextAttributes([.foregroundColor: Colors.Foreground.default.color], for: .normal)
        self.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
        self.collectionView.delegate = self

        // Empty state — icon tint set in code, not storyboard
        self.emptyStateIconImageView.tintColor = Colors.Foreground.muted.color
        self.emptyStateTitleLabel.configure(textStyle: .emphasizedTitle2, text: Strings.Product.Details.EmptyView.title, color: .default)
        self.emptyStateTitleLabel.textAlignment = .center
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
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Spacing.large, bottom: 0, trailing: Spacing.large)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Spacing.medium
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

        self.viewModel.favoritesPublisher
            .handleEvents(receiveOutput: { [weak self] models in
                self?.emptyStateView.isHidden = !models.isEmpty
            })
            .receive(on: RunLoop.main)
            .sink { [weak self] products in

                self?.refreshControl.endRefreshing()

                var snapshot = NSDiffableDataSourceSnapshot<Section, ProductModel>()

                if !products.isEmpty {
                    snapshot.appendSections([.favorites(products)])
                    snapshot.appendItems(products)
                }

                self?.dataSource?.apply(snapshot)
            }
            .store(in: &self.cancellables)

        self.viewModel.publisher(for: .am)
            .map { count in
                count >= 1 ? Strings.Product.Segment.Am.button(count) : Strings.Product.Segment.Am.buttonEmpty
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.segmentedControl.setTitle(title, forSegmentAt: 0)
            }
            .store(in: &self.cancellables)

        self.viewModel.publisher(for: .nz)
            .map { count in
                count >= 1 ? Strings.Product.Segment.Nz.button(count) : Strings.Product.Segment.Nz.buttonEmpty
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.segmentedControl.setTitle(title, forSegmentAt: 1)
            }
            .store(in: &self.cancellables)
    }

    // MARK: Actions

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        guard let state = SegmentState(rawValue: sender.selectedSegmentIndex) else { return }
        self.viewModel.segmentSubjects.value = state
    }

    @objc private func refresh() { Task {
        self.refreshControl.endRefreshing()
    }}

    @IBAction private func selecteFavorites() {
        try? self.coordinator.transition(to: TabBarTransition.search)
    }

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath) else { return }
        try? self.coordinator.transition(to: FavoriteTransition.details(itemIdentifier))
    }

}

extension FavoritesViewController {

    enum Section: Hashable {

        case favorites([ProductModel])

        static func == (lhs: Section, rhs: Section) -> Bool {
            switch (rhs, lhs) {
                case (.favorites(let lhs), .favorites(let rhs)):
                    return lhs == rhs
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
                case .favorites(let favorites):
                    favorites.hash(into: &hasher)
            }

        }

    }

}

#if DEBUG
#Preview("FavoritesViewController", traits: .fixedLayout(width: 402, height: 874)) {
    Container.shared.favoritesViewModelType.register { MainActor.assumeIsolated { PreviewFavoritesViewModel() } }

    let viewController = AppStoryboard.viewController(class: FavoritesViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif
