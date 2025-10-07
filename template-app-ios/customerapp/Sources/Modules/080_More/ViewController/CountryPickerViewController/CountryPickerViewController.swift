import Foundation
import Combine

import MustacheServices
import MustacheUIKit

class CountryPickerViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: ViewModel
    
    // MARK: Coordinator
    
    var coordinator: CoordinatorType!
    
    // MARK: Delegate
    
    weak var delegate: CountryPickerDelegate?
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    private var dataSource: UICollectionViewDiffableDataSource<Section, Country>!
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureCollectionView()
        self.configureDataSource()
        self.configureBindings()
    }
    
    // MARK: Configure
    
    private func configureView() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color

        self.navigationItem.titleView = self.searchBar
        self.searchBar.searchTextField.placeholder = Strings.Profile.Country.Searchfield.placeholder
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewCompositionalLayout() { sectionIndex, layoutEnvironment in
            let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        self.collectionView.collectionViewLayout = layout
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Country> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.flag
            content.secondaryText = item.localized

            // Apply text hierarchy
            content.textProperties.color = Colors.Foreground.default.color
            content.secondaryTextProperties.color = Colors.Foreground.muted.color

            cell.contentConfiguration = content
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, Country>(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
    }
    
    private func configureBindings() {
        
        NotificationCenter.default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: self.searchBar.searchTextField)
            .map { ($0.object as? UISearchTextField)?.text }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0 ?? "" }
            .prepend("")
            .sink { [weak self] (searchText: String) in
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Country>()
                snapshot.appendSections([.main])

                if searchText.isEmpty {
                    snapshot.appendItems(Country.countries)
                } else {
                    let countries = Country.countries.filter { $0.localized.lowercased().contains(searchText.lowercased()) }
                    snapshot.appendItems(countries)
                }
                
                self?.dataSource.apply(snapshot, animatingDifferences: true)
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

extension CountryPickerViewController: UICollectionViewDelegate {
 
    enum Section {
        case main
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let country = self.dataSource.itemIdentifier(for: indexPath) else { return }
        self.delegate?.didSelect(country)
        self.dismiss(animated: true, completion: nil)
    }
    
}

protocol CountryPickerDelegate: NSObjectProtocol {
    func didSelect(_ country: Country)
}
    

