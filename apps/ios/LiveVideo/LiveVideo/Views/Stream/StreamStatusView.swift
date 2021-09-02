//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamStatusView: View {
    let roomName: String
    
    var body: some View {
        HStack {
            LiveBadge()
            Spacer(minLength: 20)
            Text(roomName)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .lineLimit(1)
        }
        .background(Color.videoGridBackground)
    }
}

struct StreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        StreamStatusView(roomName: "Short room name")
            .previewLayout(.sizeThatFits)
        StreamStatusView(roomName: "A very long room name that doesn't fit completely")
            .previewLayout(.sizeThatFits)
    }
}
