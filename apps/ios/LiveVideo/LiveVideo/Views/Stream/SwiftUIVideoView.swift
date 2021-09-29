//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import TwilioVideo

/// A SwiftUI video view that is automatically removed from the video track when the view is no longer in use.
struct SwiftUIVideoView: UIViewRepresentable {
    @Binding var videoTrack: VideoTrack?
    @Binding var shouldMirror: Bool

    func makeUIView(context: Context) -> VideoTrackStoringVideoView {
        let videoView = VideoTrackStoringVideoView()
        videoView.contentMode = .scaleAspectFill
        return videoView
    }

    func updateUIView(_ uiView: VideoTrackStoringVideoView, context: Context) {
        uiView.videoTrack = videoTrack
        uiView.shouldMirror = shouldMirror
    }
    
    static func dismantleUIView(_ uiView: VideoTrackStoringVideoView, coordinator: ()) {
        uiView.videoTrack?.removeRenderer(uiView)
    }
}

/// A `VideoView` that stores a reference to the `VideoTrack` it renders.
///
/// This makes it easy to update view state when the `VideoTrack` changes. Just set the `VideoTrack` and the
/// view will handle`addRenderer` and `removeRenderer` automatically.
///
/// It also provides a `VideoTrack` reference to `SwiftUIVideoView` so that `SwiftUIVideoView` can
/// remove the `VideoView` from the `VideoTrack` when `dismantleUIView` is called.`
class VideoTrackStoringVideoView: VideoView {
    var videoTrack: VideoTrack? {
        didSet {
            if let videoTrack = videoTrack {
                if !videoTrack.isRendered(by: self) {
                    videoTrack.addRenderer(self)
                }
            } else {
                oldValue?.removeRenderer(self)
            }
        }
    }
}

private extension VideoTrack {
    func isRendered(by renderer: VideoRenderer) -> Bool {
        renderers.first { $0 === renderer } != nil
    }
}
