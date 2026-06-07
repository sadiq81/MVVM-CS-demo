import Combine
import Foundation
import UIKit

import MustacheCombine
import MustacheServices
import MustacheUIKit

final class FilterSearchViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateBodyLabel: UILabel!
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: ViewModel

    @Injected(\.filterSearchViewModelType)
    private var viewModel: any FilterSearchViewModelType

    // MARK: Coordinator

    // MARK: Delegate

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: UI State Variables (Avoid if possible)

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private var isDirty: Bool = false {
        didSet {
            self.gradientView.isHidden = !self.isDirty
            self.collectionView.contentInset = .init(top: 0, left: 0, bottom: self.isDirty ? self.gradientView.bounds.height : 0, right: 0)
        }
    }

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        self.configureCollectionViewLayout()
        self.configureBindings()
    }

    // MARK: Configure

    private func configureView() {
        self.gradientView.isHidden = true
        self.isModalInPresentation = true

        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.collectionView.backgroundColor = .clear
        self.emptyStateView.backgroundColor = .clear

        // Gradient: transparent → background color (alpha fade, not black)
        self.gradientView.startColor = Colors.Background.default.color.withAlphaComponent(0)
        self.gradientView.endColor = Colors.Background.default.color

        let clearButton = UIBarButtonItem(title: Strings.Product.Filter.clearFilters, style: .plain, target: self, action: #selector(clearSelections))
        self.navigationItem.leftBarButtonItem = clearButton

        let closeButton = UIBarButtonItem(image: UIImage(systemName: Images.System.close), style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem = closeButton

        // Search icon tint
        if let searchButton = self.searchTextField.superview?.subviews.compactMap({ $0 as? UIButton }).first {
            searchButton.tintColor = Colors.Foreground.muted.color
        }

        // Text hierarchy - title default, body muted
        self.emptyStateTitleLabel.configure(textStyle: .title1, text: Strings.Product.Filter.EmptyView.title, color: .default)
        self.emptyStateBodyLabel.configure(textStyle: .body, text: Strings.Product.Filter.EmptyView.body, color: .muted)

        self.searchTextField.configure(textStyle: .body, placeholder: Strings.Product.Search.placehoder)

        self.saveButton.configure(style: .primary, text: Strings.Product.Filter.Button.title)
    }

    private func configureCollectionViewLayout() {
        self.collectionView.register(nib: ProductFilterCollectionViewCell.self)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        self.collectionView.collectionViewLayout = layout
    }

    private func configureBindings() {

        self.dataSource = .init(collectionView: self.collectionView) { [weak self] (collectionView, indexPath, content) -> UICollectionViewCell? in
            guard let self else { return nil }

            let cell = collectionView.dequeue(cell: ProductFilterCollectionViewCell.self, for: indexPath)
            let isSelected = self.viewModel.isSelected(filter: content.value)
            cell.configure(filter: content.value, isSelected: isSelected)

            cell.filterSwitch.removeAction(identifiedBy: .toggle, for: .valueChanged)
            cell.filterSwitch.addAction(.init(identifier: .toggle, handler: { [weak self] action in
                guard let isOn = (action.sender as? UISwitch)?.isOn else { return }
                self?.didToggleSwitch(for: content.value, isOn: isOn)
            }), for: .valueChanged)

            return cell
        }

        Publishers.CombineLatest(self.searchTextField.textPublisher().prepend(""),
                                 self.viewModel.filterPublisher)
            .map({ (searchText, filters) -> [any ProductFilter] in
                guard !searchText.isEmpty else { return filters }
                let filtered = filters.filter { $0.localization.contains(searchText) }
                return filtered
            })
            .handleEvents(receiveOutput: { [weak self] filters in
                self?.emptyStateView.isHidden = !filters.isEmpty
            })
            .sink { [weak self] filters in

                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

                snapshot.appendSections([.main])
                let items = filters.map { Item.item($0) }
                snapshot.appendItems(items)

                self?.dataSource.apply(snapshot)
            }
            .store(in: &self.cancellables)

    }

    // MARK: @IBActions

    @objc func close() {
        self.dismiss(animated: true)
    }

    @objc func clearSelections() {
        self.viewModel.clear()
        self.searchTextField.text = ""
        self.searchTextField.sendActions(for: .valueChanged)
        self.isDirty = self.viewModel.isDirty

        var snapshot = self.dataSource.snapshot()
        snapshot.reloadSections(snapshot.sectionIdentifiers)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    @IBAction func saveAndApply(_ sender: Any) {
        self.viewModel.save()
        self.dismiss(animated: true)
    }

    // MARK: Override UIViewController functions

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: Extensions
extension FilterSearchViewController {

    func didToggleSwitch(for filter: any ProductFilter, isOn: Bool) {
        self.viewModel.toggle(filter: filter, isSelected: isOn)
        self.isDirty = self.viewModel.isDirty
    }

}

extension FilterSearchViewController {

    enum Section: String, Hashable, Sendable {
        case main
    }

    enum Item: Hashable, @unchecked Sendable {
        case item(any ProductFilter)

        var value: any ProductFilter { // This ok since we only have the one type
            switch self {
                case .item(let filter): return filter
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (rhs, lhs) {
                case (.item(let lhs), .item(let rhs)):
                    return lhs.localization == rhs.localization // This means we cant mix 2 types of filters since they might be called the same
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
                case .item(let filter):
                    filter.hash(into: &hasher)
            }

        }
    }

}

fileprivate extension UIAction.Identifier {
    static let toggle = UIAction.Identifier("\(#file)-\(#function)")
}

#if DEBUG
#Preview("FilterSearchViewController") {
    Container.shared.filterSearchViewModelType.register { MainActor.assumeIsolated { PreviewFilterSearchViewModel() } }
    Container.shared.filtersService.register { PreviewFiltersService() }

    let viewController = AppStoryboard.viewController(class: FilterSearchViewController.self)
    return UINavigationController(rootViewController: viewController)
}
#endif
