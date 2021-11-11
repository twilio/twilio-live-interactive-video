//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import TwilioLivePlayer

struct SwiftUIPlayerView: UIViewRepresentable {
    @Binding var player: Player?

    func makeUIView(context: Context) -> PlayerView {
        PlayerView()
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        guard player?.playerView !== uiView else {
            /// If `playerView` is already set don't set it again. This prevents the view from filckering sometimes.
            return
        }
        
        player?.playerView = uiView
    }
}
