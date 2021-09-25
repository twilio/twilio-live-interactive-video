//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var localParticipantViewModel: LocalParticipantViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var config: StreamConfig!
    private let app = UIApplication.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBrandStronger.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        StreamStatusView(streamName: config.streamName, isLoading: $streamManager.isLoading)
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
                                localParticipantViewModel.isMicOn ? "Mute" : "Unmute",
                                image: Image(systemName: localParticipantViewModel.isMicOn ? "mic.slash" : "mic"),
                                role: .default
                            ) {
                                localParticipantViewModel.isMicOn.toggle()
                            }
                            StreamToolbarButton(
                                localParticipantViewModel.isCameraOn ? "Stop Video" : "Start Video",
                                image: Image(systemName: localParticipantViewModel.isCameraOn ? "video.slash" : "video"),
                                role: .default
                            ) {
                                localParticipantViewModel.isCameraOn.toggle()
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

                if streamManager.isLoading {
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
                    .environmentObject(StreamManager(isLoading: true))
            }
            .environmentObject(SpeakerGridViewModel())
        }
        .environmentObject(LocalParticipantViewModel())
    }
}

private extension StreamManager {
    convenience init(isLoading: Bool = false) {
        self.init(api: nil, playerManager: nil)
        self.isLoading = isLoading
    }
}

private extension StreamConfig {
    init(role: Role) {
        self.init(streamName: "Demo", userIdentity: "Alice", role: role)
    }
}
