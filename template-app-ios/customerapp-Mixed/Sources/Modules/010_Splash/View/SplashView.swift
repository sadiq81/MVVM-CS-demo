import AVKit
import SwiftUI

import MustacheServices
import MustacheUIKit

struct SplashView: View {

    // MARK: - Coordinator

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    // MARK: - ViewModel

    @Injected(\.splashScreenViewModel)
    private var viewModel: any SplashScreenViewModelType

    // MARK: - State

    @State private var player: AVQueuePlayer?
    @State private var playerLooper: AVPlayerLooper?

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
        .onAppear {
            self.configureVideo()
            self.configureSplashSequence()
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

        // Configure audio session
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

        // Create player with looping video
        let playerItem = AVPlayerItem(url: Files.Video.splashVideoMp4.url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true

        // Setup looper (must be retained)
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        self.player = queuePlayer

        // Start playback
        queuePlayer.play()
    }

    private func configureSplashSequence() {
        Task {
            // Refresh app data
            await self.viewModel.refresh()

            // Wait for minimum splash duration
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)

            // Pause video
            self.player?.pause()

            // Transition to next screen
            try? self.coordinator.transition(to: AppTransition.splashCompleted)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
#endif
