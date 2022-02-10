//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct PresentationView: View {
    @EnvironmentObject var viewModel: PresentationViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        VStack {
            if viewModel.presenterDisplayName != nil {
                Text(viewModel.presenterDisplayName! + " is presenting.")
                    .foregroundColor(.white)
                    .background(Color.blue)
            }
            
            ForEach($viewModel.dominantSpeaker, id: \.self) { $speaker in
                SpeakerVideoView(speaker: $speaker)
            }
            
            
//            if viewModel.dominantSpeaker != nil {
////                SpeakerVideoView(speaker: Binding($viewModel.dominantSpeaker)!)
//                SpeakerVideoView(speaker: $viewModel.dominantSpeaker!)
//            }
            
            SwiftUIVideoView(videoTrack: $viewModel.presentationTrack, shouldMirror: .constant(false))
        }
    }
}

struct PresentationView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationView()
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
