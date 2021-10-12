//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var raisedHandsStore: RaisedHandsStore
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(raisedHandsStore.raisedHands) { participant in
                HStack {
                    Text("\(participant.userIdentity) 🖐")
                    Spacer()
                    Button("Invite to speak") {
                        print("Invite to speak tapped")
                        
                        streamManager.sendSpeakerInvite(userIdentity: participant.userIdentity)
                    }
                    .foregroundColor(.backgroundPrimary)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Participants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
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
