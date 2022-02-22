//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SpeakerVideoView: View {
    @EnvironmentObject var hostControlsManager: HostControlsManager
    @Binding var speaker: SpeakerVideoViewModel
    let showHostControls: Bool
    
    var body: some View {
        ZStack {
            Color.backgroundStronger
            Text(speaker.displayName)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
                .padding()

            if speaker.cameraTrack != nil {
                SwiftUIVideoView(videoTrack: $speaker.cameraTrack, shouldMirror: $speaker.shouldMirrorCameraVideo)
            }
            
            if speaker.isVideoTrackSwitchedOff {
                Color.red
                    .opacity(0.5)
            }

            VStack {
                HStack {
                    Spacer()
                    
                    if speaker.isMuted {
                        Image(systemName: "mic.slash")
                            .foregroundColor(.white)
                            .padding(9)
                            .background(Color.backgroundBrandStronger.opacity(0.4))
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Text(speaker.displayName)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.backgroundBrandStronger.opacity(0.7))
                        .cornerRadius(2)
                        .font(.system(size: 14))
                    Spacer()

                    if showHostControls && !speaker.isYou {
                        Menu(
                            content: {
                                if !speaker.isMuted {
                                    Button(
                                        action: { hostControlsManager.muteSpeaker(identity: speaker.identity) },
                                        label: { Label("Mute", systemImage: "mic.slash") }
                                    )
                                }
                                Button(
                                    action: { hostControlsManager.removeSpeaker(identity: speaker.identity) },
                                    label: { Label("Move to viewers", systemImage: "minus.circle") }
                                )
                            },
                            label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .heavy))
                                    .frame(minWidth: 44, minHeight: 44)
                            }
                        )
                    }
                }
                .padding(4)
            }

            VStack {
                if speaker.isDominantSpeaker {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.borderSuccessWeak, lineWidth: 4)
                }
            }
        }
        .cornerRadius(3)
    }
}

struct SpeakerVideoView_Previews: PreviewProvider {
    static var previews: some View {
        let longIdentity = String(repeating: "Long ", count: 20)
        
        Group {
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel()), showHostControls: true)
                .previewDisplayName("Not muted")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(identity: longIdentity)), showHostControls: true)
                .previewDisplayName("Long identity")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(identity: longIdentity)), showHostControls: false)
                .previewDisplayName("Long identity without host controls")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(isMuted: true)), showHostControls: true)
                .previewDisplayName("Muted")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(isDominantSpeaker: true)), showHostControls: true)
                .previewDisplayName("Dominant speaker")
        }
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

import TwilioVideo

extension SpeakerVideoViewModel {
    init(
        identity: String = "Alice",
        displayName: String? = nil,
        isYou: Bool = false,
        isMuted: Bool = false,
        isDominantSpeaker: Bool = false,
        dominantSpeakerTimestamp: Date = .distantPast,
        cameraTrack: VideoTrack? = nil,
        shouldMirrorCameraVideo: Bool = false
    ) {
        self.identity = identity
        self.displayName = displayName ?? identity
        self.isYou = isYou
        self.isMuted = isMuted
        self.isDominantSpeaker = isDominantSpeaker
        self.dominantSpeakerStartTime = dominantSpeakerTimestamp
        self.cameraTrack = cameraTrack
        self.shouldMirrorCameraVideo = shouldMirrorCameraVideo
    }
}
