//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var config: StreamConfig!

    var body: some View {
        ZStack {
            Color.videoGridBackground.ignoresSafeArea()
            SwiftUIPlayerView(player: $streamManager.player)
            VStack {
                Spacer()
                Button("Leave") {
                    streamManager.disconnect()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .padding(40)
            }
        }
        .onAppear {
            streamManager.connect(config: config)
        }
        .alert(isPresented: $streamManager.showError) {
            if let error = streamManager.error as? LiveVideoError, error.isStreamEndedByHostError {
                return Alert(
                    title: Text("Event is no longer available"),
                    message: Text("This event has been ended by the host."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            } else {
                return Alert(error: streamManager.error!) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct StreamView_Previews: PreviewProvider {
    static var previews: some View {
        StreamView(config: .constant(StreamConfig(roomName: "", userIdentity: "")))
            .environmentObject(StreamManager())
    }
}
