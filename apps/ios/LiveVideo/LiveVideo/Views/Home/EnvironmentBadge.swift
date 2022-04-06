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
        Group {
            EnvironmentBadge()
                .environmentObject(AppSettingsManager.stub(environment: .stage))
            EnvironmentBadge()
                .environmentObject(AppSettingsManager.stub(environment: .dev))
        }
        .previewLayout(.sizeThatFits)
    }
}
