import Combine
import Foundation
import MustacheFoundation
import MustacheServices
import MustacheUIKit
import MustacheCombine

import UIKit

class DashboardViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: ViewModel

    @LazyInjected
    var viewModel: DashboardViewModelType

    // MARK: Coordinator

    var coordinator: CoordinatorType!

    // MARK: Delegate

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: UI State Variables

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var refreshControl = UIRefreshControl()

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
        // Set background color using design system
        self.view.backgroundColor = Colors.Background.default.color
        collectionView.backgroundColor = Colors.Background.default.color

        self.refreshControl.addTarget(self, action: #selector(DashboardViewController.refresh), for: .valueChanged)

        self.collectionView.refreshControl = self.refreshControl
        self.collectionView.delegate = self

    }

    private func configureCollectionViewLayout() {

        self.collectionView.register(supplementaryNib: HeaderLabelReusableView.self, type: .header)

        self.collectionView.register(nib: RoundedCollectionViewCell.self)

        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self else { return nil }
            let content = self.dataSource?.itemIdentifier(for: IndexPath(item: 0, section: sectionIndex))

            switch content {

                case .user: // One item fill all of the screen

                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2.125/3.375))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    // Use design system spacing
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: Spacing.Common.cardSpacing,
                        leading: Spacing.Common.screenMargin,
                        bottom: Spacing.Common.sectionSpacing,
                        trailing: Spacing.Common.screenMargin
                    )

                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top)
                    section.boundarySupplementaryItems = [sectionHeader]

                    return section

                case .comment: // Two items fill all of the screen

                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: Spacing.Common.screenMargin,
                        bottom: 0,
                        trailing: Spacing.Scale.sm / 2
                    )

                    let itemSize2 = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                    let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)
                    item2.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: Spacing.Scale.sm / 2,
                        bottom: 0,
                        trailing: Spacing.Common.screenMargin
                    )

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item2])

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = .init(
                        top: Spacing.Common.cardSpacing,
                        leading: 0,
                        bottom: Spacing.Common.sectionSpacing,
                        trailing: 0
                    )
                    section.orthogonalScrollingBehavior = .groupPaging

                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top)
                    section.boundarySupplementaryItems = [sectionHeader]

                    return section

                case .post: // 1 item + peek of the next item

                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: Spacing.Common.screenMargin,
                        bottom: 0,
                        trailing: Spacing.Scale.sm
                    )

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(0.4))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: Spacing.Common.cardSpacing,
                        leading: 0,
                        bottom: Spacing.Common.sectionSpacing,
                        trailing: 0
                    )

                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top)
                    section.boundarySupplementaryItems = [sectionHeader]

                    section.visibleItemsInvalidationHandler = { (items, offset, environment) in
                        
                    }
                    
                    return section

                case .album: // 2 items + peek of the next item

                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(0.4))
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = Spacing.Common.cardSpacing
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: Spacing.Common.cardSpacing,
                        leading: Spacing.Common.screenMargin,
                        bottom: Spacing.Common.sectionSpacing,
                        trailing: Spacing.Common.screenMargin
                    )
                    section.orthogonalScrollingBehavior = .groupPaging

                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(43))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top)
                    section.boundarySupplementaryItems = [sectionHeader]

                    return section

                case .todo: // 3 items

                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)

                    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item, item])
                    group.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: Spacing.Common.screenMargin,
                        bottom: 0,
                        trailing: Spacing.Common.screenMargin
                    )
                    group.interItemSpacing = .fixed(Spacing.Scale.sm)

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(
                        top: Spacing.Common.cardSpacing,
                        leading: 0,
                        bottom: Spacing.Common.sectionSpacing,
                        trailing: 0
                    )
                    section.orthogonalScrollingBehavior = .groupPagingCentered

                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(43))
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                    elementKind: UICollectionView.elementKindSectionHeader,
                                                                                    alignment: .top)
                    section.boundarySupplementaryItems = [sectionHeader]

                    return section

                default:
                    return nil
            }
        }

        self.collectionView.collectionViewLayout = layout
    }

    private func configureCollectionViewDataSource() {
        
        self.dataSource = .init(collectionView: self.collectionView) { (collectionView, indexPath, content) -> UICollectionViewCell? in
          
            switch content {

                case .user(let user):
                    let cell = collectionView.dequeue(cell: RoundedCollectionViewCell.self, for: indexPath)
                    cell.label.configure(textStyle: .shortBody, text: user.firstName)
                    return cell
                case .comment(let comment):
                    let cell = collectionView.dequeue(cell: RoundedCollectionViewCell.self, for: indexPath)
                    cell.label.configure(textStyle: .shortBody, text: comment.email)
                    return cell
                case .post(let post):
                    let cell = collectionView.dequeue(cell: RoundedCollectionViewCell.self, for: indexPath)
                    cell.label.configure(textStyle: .emphasizedBody, text: post.title)
                    return cell
                case .album(let album):
                    let cell = collectionView.dequeue(cell: RoundedCollectionViewCell.self, for: indexPath)
                    cell.label.configure(textStyle: .body, text: album.title)
                    return cell
                case .todo(let todo):
                    let cell = collectionView.dequeue(cell: RoundedCollectionViewCell.self, for: indexPath)
                    cell.label.configure(textStyle: .body, text: todo.title)
                    return cell
            }
        }

        self.dataSource?.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, _: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self else { return nil }
            let reusableView = collectionView.dequeue(supplementaryView: HeaderLabelReusableView.self, type: .header, for: indexPath)
            let content = self.dataSource?.itemIdentifier(for: indexPath)

            // Use proper text hierarchy - section headers should be muted
            switch content {
                case .user:
                    reusableView.label.configure(textStyle: .headline, text: "Continue", color: .muted  )
                case .comment:
                    reusableView.label.configure(textStyle: .headline, text: "Comments", color: .muted)
                case .post:
                    reusableView.label.configure(textStyle: .headline, text: "Posts", color: .muted)
                case .album:
                    reusableView.label.configure(textStyle: .headline, text: "Albums", color: .muted)
                case .todo:
                    reusableView.label.configure(textStyle: .headline, text: "Todos", color: .muted)
                default:
                    break
            }

            return reusableView
        }

    }

    private func configureBindings() {

        self.viewModel.dashboardPublisher
            .receive(on: RunLoop.main)
            .compactMap({ $0 })
            .combineLatest(self.viewModel.userPublisher.compactMap({ $0 }))
            .sink { [weak self] (dashboard: DashboardModel, user: UserModel) in

                self?.refreshControl.endRefreshing()

                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

                snapshot.appendSections([.user(user)])
                snapshot.appendItems([.user(user)])

                if dashboard.comments.hasElements {
                    snapshot.appendSections([.comments(dashboard.comments)])
                    let items = dashboard.comments.map { Item.comment($0) }
                    snapshot.appendItems(items)
                }

                if dashboard.posts.hasElements {
                    snapshot.appendSections([.posts(dashboard.posts)])
                    let items = dashboard.posts.map { Item.post($0) }
                    snapshot.appendItems(items)
                }

                if dashboard.albums.hasElements {
                    snapshot.appendSections([.albums(dashboard.albums)])
                    let items = dashboard.albums.map { Item.album($0) }
                    snapshot.appendItems(items)
                }

                if dashboard.todos.hasElements {
                    snapshot.appendSections([.todos(dashboard.todos)])
                    let items = dashboard.todos.map { Item.todo($0) }
                    snapshot.appendItems(items)
                }

                self?.dataSource?.apply(snapshot)
            }
            .store(in: &self.cancellables)

    }

    // MARK: @IBActions

    @objc private func refresh() { Task {
        try await self.viewModel.refresh()
    }}

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions
extension DashboardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let content = self.dataSource?.itemIdentifier(for: indexPath)
        switch content {
            case .user:
                break
            default:
                break
        }
    }

}

extension DashboardViewController {

    enum Section: Hashable {

        case user(UserModel)
        case comments([CommentModel])
        case posts([PostModel])
        case albums([AlbumModel])
        case todos([TodoModel])

        static func == (lhs: Section, rhs: Section) -> Bool {
            switch (rhs, lhs) {
                case (.user(let lhs), .user(let rhs)):
                    return lhs == rhs
                case (.comments(let lhs), .comments(let rhs)):
                    return lhs == rhs
                case (.posts(let lhs), .posts(let rhs)):
                    return lhs == rhs
                case (.albums(let lhs), .albums(let rhs)):
                    return lhs == rhs
                case (.todos(let lhs), .todos(let rhs)):
                    return lhs == rhs
                default:
                    return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
                case .user(let user):
                    user.hash(into: &hasher)
                case .comments(let comments):
                    comments.hash(into: &hasher)
                case .posts(let posts):
                    posts.hash(into: &hasher)
                case .albums(let albums):
                    albums.hash(into: &hasher)
                case .todos(let todos):
                    todos.hash(into: &hasher)
            }

        }

    }

    enum Item: Hashable {

        case user(UserModel)
        case comment(CommentModel)
        case post(PostModel)
        case album(AlbumModel)
        case todo(TodoModel)

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (rhs, lhs) {
                case (.user(let lhs), .user(let rhs)):
                    return lhs == rhs
                case (.comment(let lhs), .comment(let rhs)):
                    return lhs == rhs
                case (.post(let lhs), .post(let rhs)):
                    return lhs == rhs
                case (.album(let lhs), .album(let rhs)):
                    return lhs == rhs
                case (.todo(let lhs), .todo(let rhs)):
                    return lhs == rhs
                default:
                    return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
                case .user(let user):
                    user.hash(into: &hasher)
                case .comment(let comment):
                    comment.hash(into: &hasher)
                case .post(let post):
                    post.hash(into: &hasher)
                case .album(let album):
                    album.hash(into: &hasher)
                case .todo(let todo):
                    todo.hash(into: &hasher)
            }

        }

    }

}
