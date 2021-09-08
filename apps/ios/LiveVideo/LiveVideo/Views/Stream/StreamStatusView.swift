//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamStatusView: View {
    let streamName: String
    @Binding var isLoading: Bool
    
    var body: some View {
        HStack {
            if !isLoading {
                LiveBadge()
            }

            Spacer(minLength: 20)
            Text(streamName)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .lineLimit(1)
        }
        .background(Color.backgroundBrandStronger)
    }
}

struct StreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StreamStatusView(streamName: "Room name", isLoading: .constant(true))
                .previewDisplayName("Loading")
            StreamStatusView(streamName: "Short room name", isLoading: .constant(false))
                .previewDisplayName("Short Room Name")
            StreamStatusView(streamName: "A very long room name that doesn't fit completely", isLoading: .constant(false))
                .previewDisplayName("Long Room Name")
        }
        .previewLayout(.sizeThatFits)
    }
}
