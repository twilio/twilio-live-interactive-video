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
        VStack(spacing: spacing) {
            if viewModel.presenterDisplayName != nil {
                ZStack {
                    Color.backgroundBrand
                    Text(viewModel.presenterDisplayName! + " is presenting.")
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .bold))
                        .padding(8)
                }
                .cornerRadius(4)
                .fixedSize(horizontal: false, vertical: true)
            }
            
            ForEach($viewModel.dominantSpeaker, id: \.self) { $speaker in
                SpeakerVideoView(speaker: $speaker)
            }
            
            ZStack {
                Color.black
                SwiftUIVideoView(videoTrack: $viewModel.presentationTrack, shouldMirror: .constant(false), fill: false)
            }
            .cornerRadius(4)



        }
        .padding(.bottom, spacing)
    }

    //            if viewModel.dominantSpeaker != nil {
    ////                SpeakerVideoView(speaker: Binding($viewModel.dominantSpeaker)!)
    //                SpeakerVideoView(speaker: $viewModel.dominantSpeaker!)
    //            }
}

struct PresentationView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationView(spacing: 6)
            .environmentObject(PresentationViewModel.stub())
            .frame(width: 400, height: 700)
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
