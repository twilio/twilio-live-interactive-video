//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct EnvironmentBadge: View {
    @EnvironmentObject var appSettingsManager: AppSettingsManager

    var body: some View {
        HStack {
            Spacer()
            Text(appSettingsManager.environment.rawValue.capitalized)
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
        ForEach(TwilioEnvironment.allCases, id: \.self) { environment in
            EnvironmentBadge()
                .environmentObject(AppSettingsManager.stub(environment: environment))
                .previewLayout(.sizeThatFits)
        }
    }
}
