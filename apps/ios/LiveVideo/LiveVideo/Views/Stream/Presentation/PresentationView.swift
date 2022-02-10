//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct PresentationView: View {
    @EnvironmentObject var viewModel: PresentationViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let spacing: CGFloat

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            VStack(spacing: spacing) {
                if let presenterDisplayName = viewModel.presenterDisplayName {
                    PresenterStatusView(presenterDisplayName: presenterDisplayName)
                }
                
                ForEach($viewModel.dominantSpeaker, id: \.self) { $speaker in
                    SpeakerVideoView(speaker: $speaker)
                        
                }

                if isPortraitOrientation {
                    PresentationVideoView(videoTrack: $viewModel.presentationTrack)
                }
            }
            .frame(maxWidth: isPortraitOrientation ? nil : 200)
            
            if !isPortraitOrientation {
                PresentationVideoView(videoTrack: $viewModel.presentationTrack)
            }
        }
        .padding(.bottom, spacing)
    }
}

struct PresentationView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationView(spacing: 6)
            .environmentObject(PresentationViewModel.stub())
            .frame(width: 300, height: 700)
            .previewLayout(.sizeThatFits)
    }
}

extension PresentationViewModel {
    static func stub(
        dominantSpeaker: SpeakerVideoViewModel = SpeakerVideoViewModel(),
        presenterIdentity: String = "Tom",
        presenterDisplayName: String = "Tom"
    ) -> PresentationViewModel {
        let viewModel = PresentationViewModel()
        viewModel.dominantSpeaker = [dominantSpeaker]
        viewModel.presenterIdentity = presenterIdentity
        viewModel.presenterDisplayName = presenterDisplayName
        return viewModel
    }
}
