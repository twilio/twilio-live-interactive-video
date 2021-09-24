//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @EnvironmentObject var speakerStore: SpeakerStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Namespace private var animation
    
    var body: some View {
        VStack {
            if speakerStore.speakers.count == 0 {
                Spacer()
            } else {
                GeometryReader { geometry in
                    LazyVGrid(columns: goodColumns(), spacing: 8) {
                        ForEach($speakerStore.speakers, id: \.self) { $speaker in
                            VideoViewChrome(speaker: $speaker)
                                .frame(height: (geometry.size.height / rowCount()) - 8)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func goodColumns() -> [GridItem] {
        if verticalSizeClass == .regular && horizontalSizeClass == .compact {
            // Portrait
            if speakerStore.speakers.count < 4 {
                return [GridItem(.flexible())]
            } else {
                return [GridItem(.flexible()), GridItem(.flexible())]
            }
        } else {
            // Landscape
            return [GridItem](repeating: GridItem(.flexible()), count: speakerStore.speakers.count)
        }
    }
    
    private func rowCount() -> CGFloat {
        if verticalSizeClass == .regular && horizontalSizeClass == .compact {
            // Portrait
            let speakerCount: Double = Double(speakerStore.speakers.count)
            let columnCount: Double = speakerCount < 4 ? 1 : 2
            
            return CGFloat(ceil(speakerCount / columnCount))
        } else {
            // Landscape
            return 1
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
