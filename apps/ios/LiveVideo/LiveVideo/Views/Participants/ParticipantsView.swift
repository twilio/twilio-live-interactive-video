//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var mapManager: SyncRaisedHandsMapManager
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(mapManager.raisedHands) { participant in
                HStack {
                    Text("\(participant.name) 🖐")
                    Spacer()
                    Button("Invite to speak") {
                        print("Invite to speak tapped")
                        
                        streamManager.sendSpeakerInvite(userIdentity: participant.name)
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
        let mapManager = SyncRaisedHandsMapManager()
        mapManager.raisedHands = [RaisedHand(name: "Bob")]
        
        return ParticipantsView()
            .environmentObject(mapManager)
    }
}
