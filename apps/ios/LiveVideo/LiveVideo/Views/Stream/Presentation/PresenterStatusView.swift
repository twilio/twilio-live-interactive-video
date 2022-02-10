//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct PresenterStatusView: View {
    let presenterDisplayName: String
    
    var body: some View {
        ZStack {
            Color.backgroundBrand
            Text(presenterDisplayName + " is presenting.")
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .bold))
                .padding(8)
        }
        .cornerRadius(4)
        .fixedSize(horizontal: false, vertical: true)

    }
}

struct PresenterStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PresenterStatusView(presenterDisplayName: "Alice")
    }
}
