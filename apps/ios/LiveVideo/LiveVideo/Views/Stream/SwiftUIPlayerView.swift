//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI
import TwilioPlayer

struct SwiftUIPlayerView: UIViewRepresentable {
    @Binding var player: Player?

    func makeUIView(context: Context) -> PlayerView {
        TwilioPlayer.PlayerView()
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = player
    }
}
