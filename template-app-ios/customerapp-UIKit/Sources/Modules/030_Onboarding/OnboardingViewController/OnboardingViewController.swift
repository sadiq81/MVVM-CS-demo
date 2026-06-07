import Combine
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: ViewModel
    
    @Injected(\.onboardingViewModel)
    private var viewModel: any OnboardingViewModelType

    @Injected(\.loggingService)
    var loggingService: any LoggingServiceType
    
    // MARK: Coordinator
    
    var coordinator: (any CoordinatorType)!
    
    // MARK: Delegate
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Section, OnboardingStep>!
    
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

        // Page control with brand color for active page, muted for inactive
        self.pageControl.numberOfPages = self.viewModel.onboardingSteps.count
        self.pageControl.currentPageIndicatorTintColor = Colors.Foreground.brand.color
        self.pageControl.pageIndicatorTintColor = Colors.Foreground.muted.color

        self.nextButton.configure(style: .primary, text: Strings.Onboarding.Button.title)
    }
    
    private func configureCollectionViewLayout() {
        
        self.collectionView.register(nib: OnboardingCollectionViewCell.self)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
            
        }, configuration: configuration)
        
        self.collectionView.collectionViewLayout = layout
        self.collectionView.delegate = self
    }
    
    private func configureCollectionViewDataSource() {
        
        self.dataSource = .init(collectionView: self.collectionView) { (collectionView, indexPath, content) -> UICollectionViewCell? in
            let cell = collectionView.dequeue(cell: OnboardingCollectionViewCell.self, for: indexPath)
            cell.configure(with: content)
            return cell
        }
        
    }
    
    private func configureBindings() {
        
        let steps = self.viewModel.onboardingSteps
        
        guard steps.hasElements else {
            try? self.coordinator.stop()
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, OnboardingStep>()
        snapshot.appendSections([.main])
        snapshot.appendItems(steps)
        self.dataSource?.apply(snapshot)
        
    }
    
    // MARK: @IBActions
    
    @IBAction func next() { Task {
        
        guard let indexPath = self.collectionView.indexPathsForVisibleItems.first,
              let content = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        self.nextButton.isBusy = true
        switch content {
            case .camera:
                let allowed = try await self.viewModel.requestCameraPermissions()
                try await self.viewModel.updateOnboardingStates(step: .camera, state: allowed ? .completed : .skipped)
            case .location:
                let allowed = try await self.viewModel.requestLocationPermissions()
                try await self.viewModel.updateOnboardingStates(step: .location, state: allowed ? .completed : .skipped)
            case .notification:
                let allowed = try await self.viewModel.requestNotificationPermissions()
                try await self.viewModel.updateOnboardingStates(step: .notification, state: allowed ? .completed : .skipped)
        }
        self.nextButton.isBusy = false
        
        let next = IndexPath(item: indexPath.item + 1, section: 0)
        if let _ = self.dataSource.itemIdentifier(for: next) {
            self.pageControl.currentPage = next.item
            self.collectionView.scrollToItem(at: next, at: .centeredHorizontally, animated: true)
        } else {
            try? self.coordinator.stop()
        }
        
    }}
    
    // MARK: Override UIViewController functions
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}
// MARK: Extensions

extension OnboardingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? OnboardingCollectionViewCell else { return }
        if #available(iOS 18.0, *) {
            cell.imageView.addSymbolEffect(.appear, options: .repeat(.continuous))
        }
    }
    
    
}

fileprivate enum Section: Hashable {
    case main
}

#if DEBUG
#Preview("OnboardingViewController") {
    Container.shared.onboardingViewModel.register { PreviewOnboardingViewModel() }
    Container.shared.loggingService.register { PreviewLoggingService() }

    let viewController = AppStoryboard.viewController(class: OnboardingViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif
