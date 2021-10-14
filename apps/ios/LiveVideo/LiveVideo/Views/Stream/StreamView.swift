//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
    @EnvironmentObject var raisedHandsStore: RaisedHandsStore
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingParticipants = false
    private let app = UIApplication.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBrandStronger.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        StreamStatusView(streamName: streamManager.config.streamName, streamState: $streamManager.state)
                            .padding([.horizontal, .bottom], 6)
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

                        switch streamManager.config.role {
                        case .host, .speaker:
                            SpeakerGridView()
                        case .viewer:
                            SwiftUIPlayerView(player: $streamManager.player)
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing)
                    
                    StreamToolbar {
                        StreamToolbarButton(
                            image: Image(systemName: "arrow.left"),
                            role: .destructive
                        ) {
                            streamManager.disconnect()
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        switch streamManager.config.role {
                        case .host, .speaker:
                            StreamToolbarButton(
                                image: Image(systemName: speakerSettingsManager.isMicOn ? "mic" : "mic.slash"),
                                role: .default
                            ) {
                                speakerSettingsManager.isMicOn.toggle()
                            }
                            StreamToolbarButton(
                                image: Image(systemName: speakerSettingsManager.isCameraOn ? "video" : "video.slash"),
                                role: .default
                            ) {
                                speakerSettingsManager.isCameraOn.toggle()
                            }
                            StreamToolbarButton(
                                image: Image(systemName: "person.2"),
                                role: .default,
                                shouldShowBadge: !raisedHandsStore.newRaisedHands.isEmpty
                            ) {
                                isShowingParticipants = true
                            }
                            
                            if streamManager.config.role != .host {
                                Menu {
                                    Button("Move to Viewers") {
                                        streamManager.moveToViewers()
                                    }
                                } label: {
                                    StreamToolbarButton(
                                        image: Image(systemName: "ellipsis"),
                                        role: .default
                                    ) {

                                    }
                                }
                            }
                        case .viewer:
                            StreamToolbarButton(
                                image: Image(systemName: streamManager.isHandRaised ? "hand.raised" : "hand.raised.slash"),
                                role: .default
                            ) {
                                streamManager.isHandRaised.toggle()
                            }
                            .alert(isPresented: $streamManager.haveSpeakerInvite) {
                                Alert(
                                    title: Text("It’s your time to shine! ✨"),
                                    message: Text("The host has invited you to join as a Speaker. Your audio and video will be shared."),
                                    primaryButton: .default(Text("Join now")) { streamManager.moveToSpeakers() },
                                    secondaryButton: .destructive(Text("Never mind")) // TODO: Call raised hands API
                                )
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
                } else if streamManager.state == .changingRole {
                    ProgressHUD()
                }
            }
        }
        .onAppear {
            app.isIdleTimerDisabled = true
            streamManager.connect()
        }
        .onDisappear {
            app.isIdleTimerDisabled = false
        }
        .sheet(isPresented: $isShowingParticipants) {
            ParticipantsView()
        }
    }
}

//struct StreamView_Previews: PreviewProvider {
//    static var previews: some View {
//        return Group {
//            StreamView(config: .constant(StreamConfig(role: .host)))
//                .previewDisplayName("Speaker")
//                .environmentObject(StreamManager())
//                .environmentObject(SpeakerGridViewModel(speakerCount: 6))
//
//            Group {
//                StreamView(config: .constant(StreamConfig(role: .viewer)))
//                    .previewDisplayName("Viewer")
//                    .environmentObject(StreamManager())
//                StreamView(config: .constant(StreamConfig(role: .viewer)))
//                    .previewDisplayName("Joining")
//                    .environmentObject(StreamManager(state: .connecting))
//            }
//            .environmentObject(SpeakerGridViewModel())
//        }
//        .environmentObject(SpeakerSettingsManager())
//    }
//}

private extension StreamManager {
    convenience init(state: StreamManager.State = .connected) {
        self.init()
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
