//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var viewModel: StreamViewModel
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
    @EnvironmentObject var raisedHandsStore: RaisedHandsStore
    @EnvironmentObject var speakerGridViewModel: SpeakerGridViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var isShowingParticipants = false
    private let app = UIApplication.shared
    private let gridSpacing: CGFloat = 6
    
    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBrandStronger.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        StreamStatusView(streamName: streamManager.config.streamName, streamState: $streamManager.state)
                            .padding(.bottom, gridSpacing)
                            .alert(isPresented: $viewModel.showError) {
                                if let error = viewModel.error as? LiveVideoError, error.isStreamEndedByHostError {
                                    return Alert(
                                        title: Text("Event is no longer available"),
                                        message: Text("This event has been ended by the host."),
                                        dismissButton: .default(Text("OK")) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    )
                                } else {
                                    return Alert(error: viewModel.error!) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }

                        HStack(spacing: 0) {
                            switch streamManager.config.role {
                            case .host, .speaker:
                                SpeakerGridView(spacing: gridSpacing)
                            case .viewer:
                                SwiftUIPlayerView(player: $streamManager.player)
                            }
                            
                            if !isPortraitOrientation && !speakerGridViewModel.offscreenSpeakers.isEmpty {
                                OffscreenSpeakersView()
                                    .frame(width: 100)
                                    .padding([.leading, .bottom], gridSpacing)
                            }
                        }
                        
                        if isPortraitOrientation && !speakerGridViewModel.offscreenSpeakers.isEmpty {
                            OffscreenSpeakersView()
                                .padding(.bottom, gridSpacing)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading.isZero ? gridSpacing : geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing.isZero ? gridSpacing : geometry.safeAreaInsets.trailing)
                    .padding(.top, geometry.safeAreaInsets.top.isZero ? 3 : 0)
                    
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
                                image: Image(systemName: speakerSettingsManager.isMicOn ? "mic" : "mic.slash")
                            ) {
                                speakerSettingsManager.isMicOn.toggle()
                            }
                            StreamToolbarButton(
                                image: Image(systemName: speakerSettingsManager.isCameraOn ? "video" : "video.slash")
                            ) {
                                speakerSettingsManager.isCameraOn.toggle()
                            }
                            StreamToolbarButton(
                                image: Image(systemName: "person.2"),
                                shouldShowBadge: raisedHandsStore.haveNew
                            ) {
                                isShowingParticipants = true
                            }
                            
                            if streamManager.config.role != .host {
                                Menu {
                                    Button("Move to Viewers") {
                                        streamManager.changeRole(to: .viewer)
                                    }
                                } label: {
                                    StreamToolbarButton(
                                        image: Image(systemName: "ellipsis")
                                    ) {

                                    }
                                }
                            }
                        case .viewer:
                            StreamToolbarButton(
                                image: Image(systemName: "hand.raised"),
                                role: viewModel.isHandRaised ? .highlight : .default
                            ) {
                                viewModel.isHandRaised.toggle()
                            }
                            .alert(isPresented: $viewModel.haveSpeakerInvite) {
                                Alert(
                                    title: Text("It’s your time to shine! ✨"),
                                    message: Text("The host has invited you to join as a Speaker. Your audio and video will be shared."),
                                    primaryButton: .default(Text("Join now")) { streamManager.changeRole(to: .speaker) },
                                    secondaryButton: .destructive(Text("Never mind")) { viewModel.isHandRaised = false }
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

struct StreamView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                StreamView()
                    .previewDisplayName("Host")
                    .environmentObject(StreamManager(config: .stub(role: .host)))
                StreamView()
                    .previewDisplayName("Speaker")
                    .environmentObject(StreamManager(config: .stub(role: .speaker)))
            }
            .environmentObject(SpeakerGridViewModel.stub())

            StreamView()
                .previewDisplayName("Offscreen Speakers")
                .environmentObject(StreamManager(config: .stub(role: .speaker)))
                .environmentObject(SpeakerGridViewModel.stub(offscreenSpeakerCount: 10))
            
            Group {
                StreamView()
                    .previewDisplayName("Viewer")
                    .environmentObject(StreamManager(config: .stub(role: .viewer)))
                StreamView()
                    .previewDisplayName("Joining")
                    .environmentObject(StreamManager(config: .stub(role: .viewer), state: .connecting))
            }
            .environmentObject(SpeakerGridViewModel())
        }
        .environmentObject(SpeakerSettingsManager())
        .environmentObject(RaisedHandsStore())
        .environmentObject(StreamViewModel())
    }
}

extension StreamManager {
    convenience init(config: StreamConfig = .stub(), state: StreamManager.State = .connected) {
        self.init()
        self.config = config
        self.state = state
    }
}

extension StreamConfig {
    static func stub(streamName: String = "Demo", userIdentity: String = "Alice", role: Role = .host) -> Self {
        StreamConfig(streamName: streamName, userIdentity: userIdentity, role: role)
    }
}
