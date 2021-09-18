//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @EnvironmentObject var speakerStore: SpeakerStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Namespace private var animation
    
    let columns = [
        GridItem(.flexible())
    ]
    
    let landscapeColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if speakerStore.speakers.count == 0 {
                Spacer()
            } else {
                if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                    GeometryReader { geometry in
                        LazyVGrid(columns: speakerStore.speakers.count < 4 ? columns : landscapeColumns, spacing: 8) {
                            ForEach($speakerStore.speakers, id: \.self) { $speaker in
                                VideoViewChrome(speaker: $speaker)
                                    .frame(height: (geometry.size.height / rowCount()) - 8)
                                    .matchedGeometryEffect(id: speaker.identity, in: animation)
                            }
                        }
                        .animation(.spring())
                    }
                    .padding(.horizontal, 4)
                } else {
                    GeometryReader { geometry in
                        LazyVGrid(columns: landscapeColumns, spacing: 4) {
                            ForEach($speakerStore.speakers, id: \.self) { $speaker in
                                VideoViewChrome(speaker: $speaker)
                                    .frame(height: geometry.size.height - 4)
                                    .matchedGeometryEffect(id: speaker.identity, in: animation)
                            }
                        }
                        .animation(.spring())
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private func rowCount() -> CGFloat {
        let speakerCount: Double = Double(speakerStore.speakers.count)
        let columnCount: Double = speakerCount < 4 ? 1 : 2
        
        return CGFloat(ceil(speakerCount / columnCount))
        
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
