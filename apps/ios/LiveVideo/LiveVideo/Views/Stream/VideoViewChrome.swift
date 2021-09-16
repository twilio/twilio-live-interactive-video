//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoViewChrome: View {
    @Binding var speaker: Speaker
    
    var body: some View {
        ZStack {
            Color.backgroundStronger
            Text(speaker.displayName)
                .lineLimit(2)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 20)

            // TODO: Really need to check this
            if speaker.cameraTrack != nil {
                SwiftUIVideoView(videoTrack: $speaker.cameraTrack, shouldMirror: $speaker.shouldMirrorCameraVideo)
            }

            VStack {
                HStack {
                    Spacer()
                    Group {
                        if speaker.isMuted {
                            Image(systemName: "mic.slash")
                                .foregroundColor(.white)
                                .padding(9)
                                .background(Color.backgroundBrandStronger.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(8)
                }
                Spacer()
                HStack {
                    Text(speaker.displayName)
                        .lineLimit(1)
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
        Group {
            VideoViewChrome(speaker: .constant(Speaker(identity: "Alice", shouldMirrorCameraVideo: false, isMuted: false, displayName: "Alice")))
                .previewDisplayName("Note Muted")
            VideoViewChrome(speaker: .constant(Speaker(identity: "A really long identity that is struncated or multiple lines and maxes out", shouldMirrorCameraVideo: false, isMuted: false, displayName: "Alice")))
                .previewDisplayName("Long Identity")
            VideoViewChrome(speaker: .constant(Speaker(identity: "Alice", shouldMirrorCameraVideo: false, isMuted: true, displayName: "Alice")))
                .previewDisplayName("Muted")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .aspectRatio(1, contentMode: .fit)
    }
}
