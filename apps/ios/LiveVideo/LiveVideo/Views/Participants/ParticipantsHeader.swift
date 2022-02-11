//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(.black)
    }
}

struct ParticipantsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantsHeader(title: "Speakers")
            .previewLayout(.sizeThatFits)
    }
}
