//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @EnvironmentObject var speakerStore: SpeakerStore

    let columns = [
        GridItem(.flexible())
    ]

    var body: some View {
        VStack {
            if speakerStore.speakers.count == 0 {
                Spacer()
            } else {
                GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach($speakerStore.speakers, id: \.self) { $speaker in
                            VideoViewChrome(speaker: $speaker)
                                .frame(height: (geometry.size.height / CGFloat(speakerStore.speakers.count) - 4))
                        }
                    }
                    .animation(.interactiveSpring())
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

//struct VideoGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoGridView(participants: .constant([
//            RoomParticipant(participant: LocalParticipant(identity:  "foo")),
//            RoomParticipant(participant: LocalParticipant(identity:  "bar"))
//        ]))
//            .frame(height: 500)
//            .previewLayout(.sizeThatFits)
//    }
//}
