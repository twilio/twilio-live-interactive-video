//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SpeakerGridView: View {
    @EnvironmentObject var viewModel: SpeakerGridViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let spacing: CGFloat
    let role: StreamConfig.Role

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    // Will have to make these more complex
    private var rowCount: Int {
        return (viewModel.pages[0].speakers.count + viewModel.pages[0].speakers.count % columnCount) / columnCount
        
//        if isPortraitOrientation {
//            return (viewModel.onscreenSpeakers.count + viewModel.onscreenSpeakers.count % columnCount) / columnCount
//        } else {
//            return viewModel.onscreenSpeakers.count < 5 ? 1 : 2
//        }
    }
    
    private var columnCount: Int {
//        if isPortraitOrientation {
            return viewModel.pages[0].speakers.count < 4 ? 1 : 2
//        } else {
//            return (viewModel.onscreenSpeakers.count + viewModel.onscreenSpeakers.count % rowCount) / rowCount
//        }
    }
    
    private func columns(pageIndex: Int) -> [GridItem] {
        [GridItem](
            repeating: GridItem(.flexible(), spacing: spacing),
            count: pageIndex == .zero ? columnCount : 2
        )
    }
    
    var body: some View {
        VStack {
            if viewModel.pages.isEmpty {
                Spacer()
            } else {
                TabView {
                    ForEach($viewModel.pages, id: \.self) { $page in
                        GeometryReader { geometry in
                            LazyVGrid(columns: columns(pageIndex: page.identifier), spacing: spacing) {
                                ForEach($page.speakers, id: \.self) { $speaker in
                                    SpeakerVideoView(speaker: $speaker, showHostControls: role == .host)
                                        .frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
                                }
                            }
                            .padding(.horizontal, spacing)
                        }
                        .padding(.bottom, 40)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
    }
}

struct SpeakerGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach((1...6), id: \.self) {
                SpeakerGridView(spacing: 6, role: .speaker)
                    .environmentObject(SpeakerGridViewModel.stub(onscreenSpeakerCount: $0))
            }
            .frame(width: 400, height: 700)

            ForEach((1...6), id: \.self) {
                SpeakerGridView(spacing: 6, role: .speaker)
                    .environmentObject(SpeakerGridViewModel.stub(onscreenSpeakerCount: $0))
            }
            .frame(width: 700, height: 300)
        }
        .previewLayout(.sizeThatFits)
    }
}

extension SpeakerGridViewModel {
    static func stub(onscreenSpeakerCount: Int = 6, offscreenSpeakerCount: Int = 0) -> SpeakerGridViewModel {
        let viewModel = SpeakerGridViewModel()

        viewModel.onscreenSpeakers = Array(1...onscreenSpeakerCount)
            .map { SpeakerVideoViewModel(identity: "Speaker \($0)") }
        
        if offscreenSpeakerCount > 1 {
            viewModel.offscreenSpeakers = Array(1...offscreenSpeakerCount)
                .map { SpeakerVideoViewModel(identity: "Offscreen \($0)") }
        }
        
        return viewModel
    }
}
