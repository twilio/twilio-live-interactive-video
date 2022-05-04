//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatHeaderView: View {
    let author: String
    let isAuthorYou: Bool
    let date: Date
    
    var body: some View {
        HStack {
            Text("\(author)\(isAuthorYou ? " (You)" : "")")
                .lineLimit(1)
            Spacer()
            Text(date, style: .time)
        }
        .foregroundColor(.textWeak)
    }
}

struct ChatHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatHeaderView(author: "Alice", isAuthorYou: true, date: Date())
                .previewDisplayName("You")
            ChatHeaderView(author: "Alice", isAuthorYou: false, date: Date())
                .previewDisplayName("Not you")
            ChatHeaderView(author: "A really long name that does not fit on one line", isAuthorYou: false, date: Date())
                .previewDisplayName("Long name")
        }
        .previewLayout(.sizeThatFits)
    }
}
