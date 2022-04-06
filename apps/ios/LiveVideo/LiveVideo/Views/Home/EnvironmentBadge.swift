//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct EnvironmentBadge: View {
    @Binding var environment: TwilioEnvironment
    
    var body: some View {
        HStack {
            Spacer()
            Text(environment.rawValue.capitalized)
                .font(.title2.bold())
                .padding(7)
                .background(Color.orange)
                .cornerRadius(6)
            Spacer()
        }
    }
}

struct EnvironmentBadge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EnvironmentBadge(environment: .constant(.stage))
            EnvironmentBadge(environment: .constant(.dev))
        }
        .previewLayout(.sizeThatFits)
    }
}
