import UIKit
import SwiftUI
internal import AVFoundation

struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> VideoLayerView {
        let view = VideoLayerView()
        view.playerLayer.player = self.player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoLayerView, context: Context) {}
}

final class VideoLayerView: UIView {
    
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { self.layer as! AVPlayerLayer }
}
