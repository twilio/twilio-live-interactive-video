//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct EnvironmentBadge: View {
    @EnvironmentObject var appSettingsManager: AppSettingsManager

    var body: some View {
        HStack {
            Spacer()
            Text(appSettingsManager.environment.rawValue.uppercased())// capitalized)
                .font(.title2.bold())
                .padding(7)
                .foregroundColor(.white)
                .background(appSettingsManager.environment.backgroundColor)
                .cornerRadius(6)
            Spacer()
        }
    }
}

private extension TwilioEnvironment {
    var backgroundColor: Color {
        switch self {
        case .prod: return .red
        case .stage: return .orange
        case .dev: return .green
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
