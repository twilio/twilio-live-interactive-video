//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var raisedHandsStore: RaisedHandsStore
    @EnvironmentObject var api: API
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Viewers")) {
                    ForEach(raisedHandsStore.raisedHands) { participant in
                        HStack {
                            Text("\(participant.userIdentity) 🖐")
                            Spacer()
                            Button("Invite to speak") {
                                let request = SendSpeakerInviteRequest(
                                    userIdentity: participant.userIdentity,
                                    roomName: "",
                                    roomSID: ""
                                )
                                
                                api.request(request) // TODO: Maybe display error
                            }
                            .foregroundColor(.backgroundPrimary)
                        }
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
