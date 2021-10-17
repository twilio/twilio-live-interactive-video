//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var viewModel: ParticipantsViewModel
    @EnvironmentObject var raisedHandsStore: RaisedHandsStore
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Viewers")) {
                    ForEach(raisedHandsStore.raisedHands) { participant in
                        HStack {
                            Text("\(participant.userIdentity) 🖐")
                                .alert(isPresented: $viewModel.showSpeakerInviteSent) {
                                    Alert(
                                        title: Text("Invitation sent"),
                                        message: Text("You invited \(participant.userIdentity) to be a speaker. They’ll be able to share audio and video."),
                                        dismissButton: .default(Text("Got it!"))
                                    )
                                }
                            Spacer()
                            
                            if streamManager.config.role == .host {
                                Button("Invite to speak") {
                                    viewModel.sendSpeakerInvite(userIdentity: participant.userIdentity)
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
                }
            }
            .listStyle(.plain)
            .navigationTitle("Participants")
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
            raisedHandsStore.haveNew = false
        }
    }
}

struct ParticipantsView_Previews: PreviewProvider {
    static var previews: some View {
        let raisedHandsStore = RaisedHandsStore()
        raisedHandsStore.raisedHands = [RaisedHandsStore.RaisedHand()]
        
        return ParticipantsView()
            .environmentObject(raisedHandsStore)
    }
}

private extension RaisedHandsStore.RaisedHand {
    init(userIdentity: String = "Alice") {
        self.userIdentity = userIdentity
    }
}
