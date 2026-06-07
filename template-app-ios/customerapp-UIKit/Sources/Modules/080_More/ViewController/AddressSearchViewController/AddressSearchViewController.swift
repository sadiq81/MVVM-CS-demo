import Combine
import Foundation
import UIKit

import MustacheServices
import MustacheUIKit

final class AddressSearchViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: ViewModel
    
    @Injected(\.addressSearchViewModelType)
    private var viewModel: any AddressSearchViewModelType
    
    // MARK: Coordinator
    
    var coordinator: (any CoordinatorType)!
    
    // MARK: Delegate
    
    weak var delegate: AddressSearchDelegate?
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    private var dataSource: UICollectionViewDiffableDataSource<Section, AddressSuggestionModel>!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureCollectionView()
        self.configureCollectionViewLayout()
        self.configureDataSource()
        self.configureBindings()
    }
    
    // MARK: Configure
    
    private func configureView() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.collectionView.backgroundColor = Colors.Background.surface.color

        self.navigationItem.titleView = self.searchBar
        self.searchBar.searchTextField.placeholder = Strings.Profile.Address.Searchfield.placeholder
    }
    
    private func configureCollectionView() {
        
        self.collectionView.layer.cornerRadius = Constants.Rounding.medium
        self.collectionView.layer.masksToBounds = true
        self.collectionView.register(nib: AddressSuggestionCell.self)
    }
    
    private func configureCollectionViewLayout() {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(AddressSuggestionCell.height))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        self.collectionView.collectionViewLayout = layout
    }
    
    private func configureDataSource() {
        
        self.dataSource = .init(collectionView: self.collectionView) { (collectionView, indexPath, content) -> UICollectionViewCell? in
            let cell = collectionView.dequeue(cell: AddressSuggestionCell.self, for: indexPath)
            cell.configure(with: content)
            return cell
        }
        
    }
    
    private func configureBindings() {
        
        self.collectionView.delegate = self
        
        NotificationCenter.default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: self.searchBar.searchTextField)
            .map { ($0.object as? UISearchTextField)?.text }
            .removeDuplicates()
            .map { $0 ?? "" }
            .prepend("")
            .sink(receiveValue: { [weak self] text in
                self?.viewModel.addressSearchTextSubject.value = text
            })
            .store(in: &self.cancellables)
        
        self.viewModel.addressSuggestionsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (suggestions: [AddressSuggestionModel]) in
                
                if suggestions.count == 1,
                    let first = suggestions.first,
                    first.type == .address,
                    first.suggestionText == self?.searchBar.text {
                    self?.delegate?.didSelect(first)
                    self?.dismiss(animated: true)
                    return
                }
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, AddressSuggestionModel>()
                snapshot.appendSections([.main])
                snapshot.appendItems(suggestions)
                self?.dataSource?.apply(snapshot)
                
            }
            .store(in: &self.cancellables)
        
    }
    
    // MARK: @IBActions
    
    // MARK: Override UIViewController functions
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}
// MARK: Extensions

extension AddressSearchViewController: UICollectionViewDelegate {
 
    enum Section {
        case main
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = self.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch itemIdentifier.type {
            case .streetName:
                self.searchBar.text = itemIdentifier.suggestionText
                self.set(caretpos: itemIdentifier.caretPosition)
                self.viewModel.addressSearchTextSubject.value = itemIdentifier.suggestionText

            case .accessAddress:
                self.searchBar.text = itemIdentifier.suggestionText
                self.set(caretpos: itemIdentifier.caretPosition)
                self.viewModel.addressSearchTextSubject.value = itemIdentifier.suggestionText

            case .address:
                self.delegate?.didSelect(itemIdentifier)
                self.dismiss(animated: true)
                
            case .unknown:
                break
        }
    }
    
    func set(caretpos: Int) {
        let textField = self.searchBar.searchTextField
        // Move cursor to a specific position
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: caretpos) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
}

@MainActor
protocol AddressSearchDelegate: NSObjectProtocol {
    func didSelect(_ suggestion: AddressSuggestionModel)
}

#if DEBUG
#Preview("AddressSearchViewController") {
    Container.shared.addressSearchViewModelType.register { MainActor.assumeIsolated { PreviewAddressSearchViewModel() } }

    let viewController = AppStoryboard.viewController(class: AddressSearchViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif

