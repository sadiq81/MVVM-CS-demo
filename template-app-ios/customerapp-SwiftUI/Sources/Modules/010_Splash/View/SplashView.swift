import AVKit
import SwiftUI

import MustacheServices
import NavigatorUI

struct SplashView: View {

    // MARK: - Navigator

    @Environment(\.navigator)
    private var navigator: Navigator

    // MARK: - ViewModel

    @InjectedObject(\.splashViewModel)
    private var viewModel

    // MARK: - State

    @State private var player: AVQueuePlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var hasStarted: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Image(uiImage: Images.Splash.background.image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if let player = self.player {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            guard !self.hasStarted else { return }
            self.hasStarted = true
            self.configureVideo()
            self.startSplashSequence()
        }
        .onDisappear {
            self.player?.pause()
        }
        .statusBar(hidden: false)
        .preferredColorScheme(.dark)
    }

    // MARK: - Methods

    private func configureVideo() {
        // Skip video when rendering snapshots/tests so the splash shows the
        // dark brand background consistently across targets.
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }

        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

        let playerItem = AVPlayerItem(url: Files.Video.splashVideoMp4.url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true

        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        self.player = queuePlayer
        queuePlayer.play()
    }

    private func startSplashSequence() {
        Task {
            await self.viewModel.refresh()
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            self.player?.pause()
            self.navigator.send(AppEvent.splashCompleted)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("SplashView") {
    Container.shared.userService.register { PreviewUserService() }
    Container.shared.onboardingService.register { PreviewOnboardingService() }
    return NavigationStack {
        SplashView()
    }
}
#endif
