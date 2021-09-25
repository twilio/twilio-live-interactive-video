//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import TwilioVideo

struct SwiftUIVideoView: UIViewRepresentable {
    @Binding var videoTrack: VideoTrack?
    @Binding var shouldMirror: Bool

    func makeUIView(context: Context) -> VideoView {
        let videoView = VideoView()
        videoView.contentMode = .scaleAspectFill
        return videoView
    }

    func updateUIView(_ uiView: VideoView, context: Context) {
        if let videoTrack = videoTrack {
            if !videoTrack.isRendered(by: uiView) {
                videoTrack.addRenderer(uiView)
            }
        } else {
            videoTrack?.removeRenderer(uiView)
        }
        
        uiView.shouldMirror = shouldMirror
    }
}

private extension VideoTrack {
    func isRendered(by renderer: VideoRenderer) -> Bool {
        renderers.first { $0 === renderer } != nil
    }
}
