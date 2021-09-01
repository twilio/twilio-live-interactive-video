//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct LiveBadge: View {
    var body: some View {
        ZStack {
            HStack(spacing: 4) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 12)
                Text("Live")
                    .font(.system(size: 13))
            }
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], 8)
        }
        .foregroundColor(.black)
        .background(Color.liveBadgeBackground)
        .cornerRadius(2)
    }
}

struct LiveBadge_Previews: PreviewProvider {
    static var previews: some View {
        LiveBadge()
    }
}
