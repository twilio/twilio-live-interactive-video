//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct RecordingBadge: View {
    @State private var isBright = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .frame(width: 12)
                .foregroundColor(isBright ? .recordingDotBright : .recordingDotDark)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        isBright.toggle()
                    }
                }
            
            Text("Recording")
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
        .frame(height: 14)
        .padding(6)
        .background(Color.white.opacity(0.25))
        .cornerRadius(3)
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct RecordingBadge_Previews: PreviewProvider {
    static var previews: some View {
        RecordingBadge()
            .padding()
            .background(Color.backgroundBrandStronger)
            .previewLayout(.sizeThatFits)
    }
}
