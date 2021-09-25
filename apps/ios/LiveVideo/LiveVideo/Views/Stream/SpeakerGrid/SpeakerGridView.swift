//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SpeakerGridView: View {
    @EnvironmentObject var viewModel: SpeakerGridViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    private let spacing: CGFloat = 4

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private var rowCount: Int {
        if isPortraitOrientation {
            return (viewModel.speakers.count + viewModel.speakers.count % columnCount) / columnCount
        } else {
            return 1
        }
    }
    
    private var columnCount: Int {
        if isPortraitOrientation {
            return viewModel.speakers.count < 4 ? 1 : 2
        } else {
            return viewModel.speakers.count
        }
    }
    
    private var columns: [GridItem] {
        [GridItem](
            repeating: GridItem(.flexible(), spacing: spacing),
            count: columnCount
        )
    }
    
    var body: some View {
        VStack {
            if viewModel.speakers.isEmpty {
                Spacer()
            } else {
                GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach($viewModel.speakers, id: \.self) { $speaker in
                            SpeakerVideoView(speaker: $speaker)
                                .frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
                        }
                    }
                }
                .padding(.horizontal, spacing)
            }
        }
    }
}

struct SpeakerGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach((1...6), id: \.self) {
                SpeakerGridView()
                    .environmentObject(SpeakerGridViewModel(speakerCount: $0))
            }
            .frame(width: 400, height: 700)

            ForEach((1...6), id: \.self) {
                SpeakerGridView()
                    .environmentObject(SpeakerGridViewModel(speakerCount: $0))
            }
            .frame(width: 700, height: 300)
        }
        .previewLayout(.sizeThatFits)
    }
}

extension SpeakerGridViewModel {
    convenience init(speakerCount: Int) {
        self.init()
        speakers = Array(1...speakerCount).map { SpeakerVideoViewModel(identity: "Speaker \($0)") }
    }
}
