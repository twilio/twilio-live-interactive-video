//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @Binding var videoTrack: VideoTrack?
    
    var body: some View {
        SwiftUIVideoView(videoTrack: $videoTrack)
    }
}

struct VideoGridView_Previews: PreviewProvider {
    static var previews: some View {
        VideoGridView(videoTrack: .constant(nil))
    }
}
