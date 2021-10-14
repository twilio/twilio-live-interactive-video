//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var raisedHandsStore: RaisedHandsStore
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var api: API
    @Environment(\.presentationMode) var presentationMode
    @State private var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    @State private var showError = false
    @State private var showSpeakerInviteConfirmation = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Viewers")) {
                    ForEach(raisedHandsStore.raisedHands) { participant in
                        HStack {
                            Text("\(participant.userIdentity) 🖐")
                                .alert(isPresented: $showSpeakerInviteConfirmation) {
                                    Alert(
                                        title: Text("Invitation sent"),
                                        message: Text("You invited \(participant.userIdentity) to be a speaker. They’ll be able to share audio and video."),
                                        dismissButton: .default(Text("Got it!"))
                                    )
                                }
                            Spacer()
                            
                            if streamManager.config.role == .host {
                                Button("Invite to speak") {
                                    let request = SendSpeakerInviteRequest(
                                        userIdentity: participant.userIdentity,
                                        roomSID: streamManager.roomSID!
                                    )

                                    // TODO: Need view model to show error
                                    api.request(request)
                                    showSpeakerInviteConfirmation = true
                                }
                                .foregroundColor(.backgroundPrimary)
                                .alert(isPresented: $showError) {
                                    Alert(error: error!) {
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
            raisedHandsStore.newRaisedHands.removeAll()
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
