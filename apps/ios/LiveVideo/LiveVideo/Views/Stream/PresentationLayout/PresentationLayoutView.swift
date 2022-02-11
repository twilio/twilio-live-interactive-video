//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct PresentationLayoutView: View {
    @EnvironmentObject var viewModel: PresentationLayoutViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let spacing: CGFloat

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    PresentationStatusView(presenterDisplayName: viewModel.presenter.displayName)
                    SpeakerVideoView(speaker: $viewModel.dominantSpeaker)

                    if isPortraitOrientation {
                        PresentationVideoView(videoTrack: $viewModel.presenter.presentationTrack)
                    }
                }
                // For landscape orientation only use 30% of the width for status and speaker video
                .frame(width: isPortraitOrientation ? nil : geometry.size.width * 0.3)
                
                if !isPortraitOrientation {
                    PresentationVideoView(videoTrack: $viewModel.presenter.presentationTrack)
                }
            }
            .padding(.bottom, spacing)
        }
    }
}

struct PresentationLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PresentationLayoutView(spacing: 6)
                .frame(width: 300, height: 600)
            PresentationLayoutView(spacing: 6)
                .frame(width: 600, height: 300)
        }
        .environmentObject(PresentationLayoutViewModel.stub())
        .previewLayout(.sizeThatFits)
    }
}

extension PresentationLayoutViewModel {
    static func stub(
        dominantSpeaker: SpeakerVideoViewModel = SpeakerVideoViewModel(),
        presenterIdentity: String = "Tom",
        presenterDisplayName: String = "Tom"
    ) -> PresentationLayoutViewModel {
        let viewModel = PresentationLayoutViewModel()
        viewModel.dominantSpeaker = dominantSpeaker
        viewModel.presenter = Presenter(displayName: presenterDisplayName)
        return viewModel
    }
}
