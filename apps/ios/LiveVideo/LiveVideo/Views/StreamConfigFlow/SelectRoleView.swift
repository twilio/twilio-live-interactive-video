//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SelectRoleView: View {
    @EnvironmentObject var flowModel: StreamConfigFlowModel

    var body: some View {
        FormStack {
            Text("Do you plan on chatting up the room or are you more of the quiet, mysterious audience type?")
                .modifier(TipStyle())

            Button(
                action: {
                    flowModel.parameters.role = .speaker
                    flowModel.isShowing = false
                },
                label: {
                    CardButtonLabel(
                        title: "Join as speaker",
                        image: Image(systemName: "mic"),
                        detail: "Your audio and video will be shared by default."
                    )
                }
            )

            Button(
                action: {
                    flowModel.parameters.role = .viewer
                    flowModel.isShowing = false
                },
                label: {
                    CardButtonLabel(
                        title: "Join as viewer",
                        image: Image(systemName: "eyes"),
                        detail: "Your audio and video will not be shareable. To share, you’ll have to raise your hand and the host will accept or deny."
                    )
                }
            )
        }
        .navigationBarTitle("Speaker or viewer?", displayMode: .inline)
    }
}

struct SelectRoleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectRoleView()
        }
    }
}
