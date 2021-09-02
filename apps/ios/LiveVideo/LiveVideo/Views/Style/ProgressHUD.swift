//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ProgressHUD: View {
    let label: String
    
    var body: some View {
        ZStack {
            Color.videoGridBackground
                .opacity(0.8)
            VStack(spacing: 40) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .scaleEffect(2)
                if let label = label {
                    Text(label)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct ProgressHUD_Previews: PreviewProvider {
    static var previews: some View {
        ProgressHUD(label: "Label")
    }
}
