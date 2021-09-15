//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoViewChrome: View {
    @Binding var speaker: Speaker
    
    var body: some View {
        ZStack {
            Color.backgroundStronger
            SwiftUIVideoView(videoTrack: $speaker.cameraTrack)
            VStack {
                Spacer()
                HStack {
                    Text(speaker.identity)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.backgroundBrandStronger.opacity(0.7))
                        .cornerRadius(2)
                        .font(.system(size: 14))
                    Spacer()
                }
                .padding(4)
            }
        }
        .cornerRadius(3)
    }
}

struct VideoViewChrome_Previews: PreviewProvider {
    static var previews: some View {
        VideoViewChrome(speaker: .constant(Speaker(identity: "Alice")))
            .previewLayout(.sizeThatFits)
            .padding()
            .aspectRatio(1, contentMode: .fit)
    }
}
