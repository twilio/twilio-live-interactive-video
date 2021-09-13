//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import TwilioVideo

struct SwiftUIVideoView: UIViewRepresentable {
    @Binding var videoTrack: VideoTrack?

    func makeUIView(context: Context) -> VideoView {
        VideoView()
    }

    func updateUIView(_ uiView: VideoView, context: Context) {
        guard let videoTrack = videoTrack else {
            return
        }

        if videoTrack.renderers.isEmpty {
            videoTrack.addRenderer(uiView) // TODO: Remove renderer
        }
    }
}
