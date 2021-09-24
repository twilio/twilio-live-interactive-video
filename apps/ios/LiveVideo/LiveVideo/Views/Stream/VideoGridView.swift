//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @EnvironmentObject var speakerStore: SpeakerStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    private let spacing: CGFloat = 4
    
    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private var rowCount: CGFloat {
        if isPortraitOrientation { // TODO: Clean up math
            let speakerCount: Double = Double(speakerStore.speakers.count)
            let columnCount: Double = speakerCount < 4 ? 1 : 2
            
            return CGFloat(ceil(speakerCount / columnCount))
        } else {
            return 1
        }
    }
    
    private var columnCount: Int {
        if isPortraitOrientation {
            return speakerStore.speakers.count < 4 ? 1 : 2
        } else {
            return speakerStore.speakers.count
        }
    }
    
    private var columns: [GridItem] {
        [GridItem](repeating: GridItem(.flexible()), count: columnCount)
    }
    
    var body: some View {
        VStack {
            if speakerStore.speakers.count == 0 {
                Spacer()
            } else {
                GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach($speakerStore.speakers, id: \.self) { $speaker in
                            VideoViewChrome(speaker: $speaker)
                                .frame(height: geometry.size.height / rowCount - spacing)
                        }
                    }
                }
                .padding(.horizontal, spacing)
            }
        }
    }
}

struct VideoGridView_Previews: PreviewProvider {
    static func makeSpeakerStore(_ speakers: Int) -> SpeakerStore {
        let speakerStore = SpeakerStore()
        
        let theRange: [Int] = Array(1...speakers)
        
        speakerStore.speakers = theRange.map { Speaker(identity: "Participant \($0)") }
        return speakerStore
    }

    static var previews: some View {
        Group {
            ForEach((1...6), id: \.self) {
                VideoGridView()
                    .environmentObject(makeSpeakerStore($0))
            }
            .frame(width: 400, height: 700)

            ForEach((1...6), id: \.self) {
                VideoGridView()
                    .environmentObject(makeSpeakerStore($0))
            }
            .frame(width: 700, height: 400)
        }
        .previewLayout(.sizeThatFits)
    }
}
