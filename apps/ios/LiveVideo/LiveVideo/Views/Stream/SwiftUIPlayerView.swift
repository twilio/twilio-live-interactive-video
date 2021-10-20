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
        player?.playerView = uiView
    }
}
