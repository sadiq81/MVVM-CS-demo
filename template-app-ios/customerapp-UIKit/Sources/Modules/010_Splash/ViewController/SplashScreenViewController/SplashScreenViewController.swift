import AVFoundation
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

final class SplashScreenViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var playerView: UIView!
    fileprivate var player: AVQueuePlayer!
    fileprivate var playerLayer: AVPlayerLayer!
    fileprivate var playerLooper: AVPlayerLooper!

    // MARK: ViewModel

    @Injected(\.splashScreenViewModel)
    private var viewModel: any SplashScreenViewModelType

    // MARK: Coordinator

    var coordinator: (any CoordinatorType)!

    // MARK: Delegate

    // MARK: Cancellable

    // MARK: UI State Variables (Avoid if possible)

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureVideo()
        self.configureBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player?.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player?.pause()
    }

    // MARK: Configure

    private func configureView() {
        self.view.backgroundColor = Colors.Background.dark.color
    }

    private func configureVideo() {

        // Skip video when rendering snapshots/tests so the splash shows the
        // dark brand background consistently across targets.
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }

        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

        let playerItem = AVPlayerItem(url: Files.Video.splashVideoMp4.url)

        self.player = AVQueuePlayer()
        self.player.isMuted = true
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = .resizeAspectFill
        self.playerView.layer.insertSublayer(self.playerLayer, at: 0)

        self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
        self.player.play()
    }

    private func configureBindings() { Task {
        
        // Refresh relevant app data
        await self.viewModel.refresh()
        try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        self.player?.pause()
        try? self.coordinator.transition(to: AppTransition.splashCompleted)
    }}

    // MARK: @IBActions

    // MARK: Override UIViewController functions

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.playerLayer?.frame = self.playerView.bounds
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions

#if DEBUG
#Preview("SplashScreenViewController") {
    
    Container.shared.splashScreenViewModel.register { PreviewSplashScreenViewModel() }

    let viewController = AppStoryboard.viewController(class: SplashScreenViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif

