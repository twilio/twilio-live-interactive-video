//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamToolbar<Content>: View where Content: View {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
        .background(Color.background)
    }
}

struct StreamToolbar_Previews: PreviewProvider {
    static var previews: some View {
        StreamToolbar {
            StreamToolbarButton("Destructive", image: Image(systemName: "arrow.left.circle.fill"), role: .destructive)
            StreamToolbarButton("Default", image: Image(systemName: "mic.slash.fill"))
        }
        .previewLayout(.sizeThatFits)
    }
}
