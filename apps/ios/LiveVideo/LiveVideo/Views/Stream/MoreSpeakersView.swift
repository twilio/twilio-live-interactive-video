//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct MoreSpeakersView: View {
    @EnvironmentObject var viewModel: SpeakerGridViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundBrand
                .cornerRadius(4)
            Text("+ \(viewModel.offscreenSpeakers.count) more")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(17)
        }
    }
}

struct MoreSpeakersView_Previews: PreviewProvider {
    static var previews: some View {
        MoreSpeakersView()
            .environmentObject(SpeakerGridViewModel(speakerCount: 10))
            .previewLayout(.sizeThatFits)
            .fixedSize(horizontal: false, vertical: true)
    }
}
