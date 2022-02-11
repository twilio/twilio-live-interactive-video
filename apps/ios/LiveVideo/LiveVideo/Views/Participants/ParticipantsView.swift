//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var viewModel: ParticipantsViewModel
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: ParticipantsHeader(title: "Speakers (\(viewModel.speakers.count))")) {
                    ForEach(viewModel.speakers) { speaker in
                        HStack {
                            Text(speaker.displayName)
                            Spacer()
                        }
                    }
                }
                Section(header: ParticipantsHeader(title: "Viewers (\(viewModel.viewerCount))")) {
                    ForEach(viewModel.viewersWithRaisedHand) { viewer in
                        HStack {
                            Text("\(viewer.identity) 👋")
                                .alert(isPresented: $viewModel.showSpeakerInviteSent) {
                                    Alert(
                                        title: Text("Invitation sent"),
                                        message: Text("You invited \(viewer.identity) to be a speaker. They’ll be able to share audio and video."),
                                        dismissButton: .default(Text("Got it!"))
                                    )
                                }
                            Spacer()
                            
                            if streamManager.config.role == .host {
                                Button("Invite to speak") {
                                    viewModel.sendSpeakerInvite(userIdentity: viewer.identity)
                                }
                                .foregroundColor(.backgroundPrimary)
                                .alert(isPresented: $viewModel.showError) {
                                    Alert(error: viewModel.error!) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ForEach(viewModel.viewersWithoutRaisedHand) { viewer in
                        HStack {
                            Text(viewer.identity)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .animation(.default)
            .navigationTitle("Participants (\(viewModel.speakers.count + viewModel.viewerCount))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.haveNewRaisedHand = false
        }
    }
}

struct ParticipantsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            ParticipantsView()
                .previewDisplayName("Host")
                .environmentObject(
                    ParticipantsViewModel.stub(
                        speakers: ["Sam"],
                        viewersWithRaisedHand: ["Alice"],
                        viewersWithoutRaisedHand: ["Bob"]
                    )
                )
                .environmentObject(StreamManager(config: .stub(role: .host)))
            ParticipantsView()
                .previewDisplayName("Speaker")
                .environmentObject(
                    ParticipantsViewModel.stub(
                        speakers: ["Sam"],
                        viewersWithRaisedHand: ["Alice"],
                        viewersWithoutRaisedHand: ["Bob"]
                    )
                )
                .environmentObject(StreamManager(config: .stub(role: .speaker)))
            ParticipantsView()
                .previewDisplayName("No Viewers")
                .environmentObject(ParticipantsViewModel.stub(speakers: ["Sam"]))
                .environmentObject(StreamManager())
        }
    }
}

private extension ParticipantsViewModel {
    static func stub(
        speakers: [String] = [],
        viewersWithRaisedHand: [String] = [],
        viewersWithoutRaisedHand: [String] = []
    ) -> ParticipantsViewModel {
        let viewModel = ParticipantsViewModel()
        viewModel.speakers = speakers.map { SyncUsersMap.User(identity: $0) }
        viewModel.viewersWithRaisedHand = viewersWithRaisedHand.map { SyncUsersMap.User(identity: $0) }
        viewModel.viewersWithoutRaisedHand = viewersWithoutRaisedHand.map { SyncUsersMap.User(identity: $0) }
        viewModel.viewerCount = viewersWithRaisedHand.count + viewersWithoutRaisedHand.count
        return viewModel
    }
}

private extension SyncUsersMap.User {
    init(identity: String, isHost: Bool = false) {
        self.identity = identity
        self.isHost = isHost
    }
}
