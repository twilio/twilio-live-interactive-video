//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import TwilioVideo

struct SwiftUIVideoView: UIViewRepresentable {
    @Binding var videoTrack: VideoTrack?
    @Binding var shouldMirror: Bool

    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        view.contentMode = .scaleAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoView, context: Context) {
        if let videoTrack = videoTrack {
            if videoTrack.renderers.first(where: { $0 === uiView }) == nil {
                videoTrack.addRenderer(uiView)
            }
        } else {
            videoTrack?.removeRenderer(uiView)
        }
        
        uiView.shouldMirror = shouldMirror
    }
}
