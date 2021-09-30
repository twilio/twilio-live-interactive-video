//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var config: StreamConfig!
    private let app = UIApplication.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBrandStronger.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        StreamStatusView(streamName: config.streamName, streamState: $streamManager.state)
                            .padding([.horizontal, .bottom], 6)
                        
                        switch config.role {
                        case .host, .speaker:
                            SpeakerGridView()
                        case .viewer:
                            SwiftUIPlayerView(player: $streamManager.player)
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing)
                    
                    StreamToolbar {
                        switch config.role {
                        case .host, .speaker:
                            StreamToolbarButton(
                                "Leave",
                                image: Image(systemName: "arrow.left"),
                                role: .destructive
                            ) {
                                streamManager.disconnect()
                                presentationMode.wrappedValue.dismiss()
                            }
                            StreamToolbarButton(
                                speakerSettingsManager.isMicOn ? "Mute" : "Unmute",
                                image: Image(systemName: speakerSettingsManager.isMicOn ? "mic.slash" : "mic"),
                                role: .default
                            ) {
                                speakerSettingsManager.isMicOn.toggle()
                            }
                            StreamToolbarButton(
                                speakerSettingsManager.isCameraOn ? "Stop Video" : "Start Video",
                                image: Image(systemName: speakerSettingsManager.isCameraOn ? "video.slash" : "video"),
                                role: .default
                            ) {
                                speakerSettingsManager.isCameraOn.toggle()
                            }
                        case .viewer:
                            StreamToolbarButton(
                                "Leave",
                                image: Image(systemName: "arrow.left"),
                                role: .destructive
                            ) {
                                streamManager.disconnect()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    
                    // For toolbar bottom that is below safe area
                    Color.background
                        .frame(height: geometry.safeAreaInsets.bottom)
                }
                .edgesIgnoringSafeArea([.horizontal, .bottom]) // So toolbar sides and bottom extend beyond safe area

                if streamManager.state == .connecting {
                    ProgressHUD(title: "Joining live event! 🎉")
                }
            }
        }
        .onAppear {
            app.isIdleTimerDisabled = true
            streamManager.connect(config: config)
        }
        .onDisappear {
            app.isIdleTimerDisabled = false
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
        return Group {
            StreamView(config: .constant(StreamConfig(role: .host)))
                .previewDisplayName("Speaker")
                .environmentObject(StreamManager())
                .environmentObject(SpeakerGridViewModel(speakerCount: 6))

            Group {
                StreamView(config: .constant(StreamConfig(role: .viewer)))
                    .previewDisplayName("Viewer")
                    .environmentObject(StreamManager())
                StreamView(config: .constant(StreamConfig(role: .viewer)))
                    .previewDisplayName("Joining")
                    .environmentObject(StreamManager(state: .connecting))
            }
            .environmentObject(SpeakerGridViewModel())
        }
        .environmentObject(SpeakerSettingsManager())
    }
}

private extension StreamManager {
    convenience init(state: StreamManager.State = .connected) {
        self.init(api: nil, playerManager: nil)
        self.state = state
    }
}

private extension StreamConfig {
    init(role: Role) {
        streamName = "Demo"
        userIdentity = "Alice"
        self.role = role
    }
}
