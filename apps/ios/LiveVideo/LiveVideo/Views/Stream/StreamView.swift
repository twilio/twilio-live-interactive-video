//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var viewModel: StreamViewModel
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
    @EnvironmentObject var participantsViewModel: ParticipantsViewModel
    @EnvironmentObject var speakerGridViewModel: SpeakerGridViewModel
    @EnvironmentObject var presentationLayoutViewModel: PresentationLayoutViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var isShowingParticipants = false
    private let app = UIApplication.shared
    private let spacing: CGFloat = 6
    
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
                            .padding(.bottom, spacing)

                        HStack(spacing: 0) {
                            switch streamManager.config.role {
                            case .host, .speaker:
                                if presentationLayoutViewModel.isPresenting {
                                    PresentationLayoutView(spacing: spacing, role: streamManager.config.role)
                                } else {
                                    SpeakerGridView(spacing: spacing, role: streamManager.config.role)
                                }
                            case .viewer:
                                SwiftUIPlayerView(player: $streamManager.player)
                            }
                            
                            if !isPortraitOrientation && !speakerGridViewModel.offscreenSpeakers.isEmpty {
                                OffscreenSpeakersView()
                                    .frame(width: 100)
                                    .padding([.leading, .bottom], spacing)
                            }
                        }
                        
                        if isPortraitOrientation && !speakerGridViewModel.offscreenSpeakers.isEmpty {
                            OffscreenSpeakersView()
                                .padding(.bottom, spacing)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading.isZero ? spacing : geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing.isZero ? spacing : geometry.safeAreaInsets.trailing)
                    .padding(.top, geometry.safeAreaInsets.top.isZero ? 3 : 0)
                    
                    StreamToolbar {
                        StreamToolbarButton(
                            image: Image(systemName: "arrow.left"),
                            role: .destructive
                        ) {
                            switch streamManager.config.role {
                            case .host:
                                viewModel.alertIdentifier = .streamWillEndIfHostLeaves
                            case .speaker, .viewer:
                                leaveStream()
                            }
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
                        case .viewer:
                            StreamToolbarButton(
                                image: Image(systemName: "hand.raised"),
                                role: viewModel.isHandRaised ? .highlight : .default
                            ) {
                                viewModel.isHandRaised.toggle()
                            }
                        }

                        StreamToolbarButton(
                            image: Image(systemName: "person.2"),
                            shouldShowBadge: streamManager.config.role != .viewer && participantsViewModel.haveNewRaisedHand
                        ) {
                            isShowingParticipants = true
                        }

                        if streamManager.config.role == .speaker {
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
        .alert(item: $viewModel.alertIdentifier) { alertIdentifier in
            switch alertIdentifier {
            case .fatalError:
                return Alert(error: viewModel.error!) {
                    presentationMode.wrappedValue.dismiss()
                }
            case .informativeError:
                return Alert(error: viewModel.error!)
            case .receivedSpeakerInvite:
                return Alert(
                    title: Text("It’s your time to shine! ✨"),
                    message: Text("The host has invited you to join as a Speaker. Your audio and video will be shared."),
                    primaryButton: .default(Text("Join now")) {
                        streamManager.changeRole(to: .speaker)
                    },
                    secondaryButton: .destructive(Text("Never mind")) {
                        viewModel.isHandRaised = false
                    }
                )
            case .recordingIsInProgress:
                return Alert(
                    title: Text("Recording Is in Progress"),
                    dismissButton: .default(Text("OK"))
                )
            case .speakerMovedToViewersByHost:
                return Alert(
                    title: Text("Moved to viewers"),
                    message: Text("You have been moved to viewers by the host."),
                    dismissButton: .default(Text("OK"))
                )
            case .streamEndedByHost:
                return Alert(
                    title: Text("Event is no longer available"),
                    message: Text("This event has been ended by the host."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            case .streamWillEndIfHostLeaves:
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("This will end the event for everyone."),
                    primaryButton: .destructive(Text("End event")) {
                        leaveStream()
                    },
                    secondaryButton: .cancel(Text("Never mind"))
                )
            case .viewerConnected:
                return Alert(
                    title: Text("Welcome!"),
                    message: Text("You are now in the audience as a Viewer. Raise your hand anytime to join the Speakers and chime in!"),
                    dismissButton: .default(Text("Got it!"))
                )
            }
        }
    }
    
    private func leaveStream() {
        streamManager.disconnect()
        presentationMode.wrappedValue.dismiss()
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
            .environmentObject(PresentationLayoutViewModel.stub())

            StreamView()
                .previewDisplayName("Offscreen Speakers")
                .environmentObject(StreamManager(config: .stub(role: .speaker)))
                .environmentObject(SpeakerGridViewModel.stub(offscreenSpeakerCount: 10))
                .environmentObject(PresentationLayoutViewModel.stub())

            StreamView()
                .previewDisplayName("Presentation")
                .environmentObject(StreamManager(config: .stub(role: .speaker)))
                .environmentObject(SpeakerGridViewModel.stub())
                .environmentObject(PresentationLayoutViewModel.stub(isPresenting: true))

            Group {
                StreamView()
                    .previewDisplayName("Viewer")
                    .environmentObject(StreamManager(config: .stub(role: .viewer)))
                StreamView()
                    .previewDisplayName("Joining")
                    .environmentObject(StreamManager(config: .stub(role: .viewer), state: .connecting))
            }
            .environmentObject(SpeakerGridViewModel())
            .environmentObject(PresentationLayoutViewModel.stub())
        }
        .environmentObject(SpeakerSettingsManager())
        .environmentObject(ParticipantsViewModel())
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
    static func stub(
        streamName: String = "Demo",
        userIdentity: String = "Alice",
        shouldRecord: Bool? = nil,
        role: Role = .host
    ) -> Self {
        StreamConfig(
            streamName: streamName,
            userIdentity: userIdentity,
            shouldRecord: shouldRecord,
            role: role
        )
    }
}
