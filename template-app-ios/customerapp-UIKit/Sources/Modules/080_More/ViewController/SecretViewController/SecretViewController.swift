import Combine
import Foundation
import UIKit

import MustacheCombine
import MustacheServices

final class SecretViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var feature1Switch: UISwitch!
    @IBOutlet weak var feature1ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var feature2Switch: UISwitch!
    @IBOutlet weak var feature2ActivityIndicator: UIActivityIndicatorView!

    // MARK: ViewModel

    @Injected(\.secretViewModelType)
    private var viewModel: any SecretViewModelType

    // MARK: Coordinator

    // MARK: Delegate

    // MARK: Cancellable
        
    private var cancellables = Set<AnyCancellable>()

    // MARK: UI State Variables (Avoid if possible)

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.configureBindings()
        
    }
    
    // MARK: Configure
    
    private func configure() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color

        // Title aligned with SwiftUI/Mixed (Strings.More.Label.secret)
        self.title = Strings.More.Label.secret

        // Apply text color
        self.label.text = String(data: self.viewModel.data, encoding: .utf8)
        self.label.textColor = Colors.Foreground.default.color

        // Brand color for switches
        self.feature1Switch.onTintColor = Colors.Background.brand.color
        self.feature2Switch.onTintColor = Colors.Background.brand.color

        self.feature1ActivityIndicator.color = Colors.Foreground.brand.color
        self.feature2ActivityIndicator.color = Colors.Foreground.brand.color
    }
    
    private func configureBindings() {
        self.viewModel.featureFlagsPublisher
            .sink { [weak self] flags in
                self?.feature1Switch.isOn = flags.contains(.feature1)
                self?.feature2Switch.isOn = flags.contains(.feature2)
            }
            .store(in: &self.cancellables)
        
    }

    // MARK: @IBActions

    @IBAction func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func toggleFeature(_ sender: UISwitch) { Task {
        guard let feature = FeatureFlag(sender.tag) else { return }
        sender.isEnabled = false
        do {
            if sender.isOn {
                
                defer { self.feature1ActivityIndicator.stopAnimating() }
                
                self.feature1ActivityIndicator.startAnimating()
                try await self.viewModel.enable(flag: feature)
                
            } else {
                
                defer { self.feature2ActivityIndicator.stopAnimating() }
                
                self.feature2ActivityIndicator.startAnimating()
                try await self.viewModel.disable(flag: feature)
                
            }
        } catch {
            sender.isOn = !sender.isOn
            self.alert(error: error)
        }
        sender.isEnabled = true
    }}

    // MARK: Override UIViewController functions

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions

#if DEBUG
#Preview("SecretViewController", traits: .fixedLayout(width: 402, height: 874)) {
    Container.shared.secretViewModelType.register { MainActor.assumeIsolated { PreviewSecretViewModel() } }

    let viewController = AppStoryboard.viewController(class: SecretViewController.self)
    return UINavigationController(rootViewController: viewController)
}
#endif
