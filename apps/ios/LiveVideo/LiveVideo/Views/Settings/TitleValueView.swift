//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct TitleValueView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct TitleValueView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TitleValueView(title: "Title", value: "Value")
        }
    }
}
