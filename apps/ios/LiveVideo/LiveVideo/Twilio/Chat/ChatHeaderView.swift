//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatHeaderView: View {
    let author: String
    let date: Date
    
    var body: some View {
        HStack {
            Text(author)
            Spacer()
            Text(date, style: .time)
        }
        .foregroundColor(.textWeak)
    }
}

struct ChatHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHeaderView(author: "Alice", date: Date())
            .previewLayout(.sizeThatFits)
    }
}
