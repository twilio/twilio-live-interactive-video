//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name = ""

    var body: some View {
        FormStack {
            HStack {
                Text("Welcome to Twilio Live Events!")
                    .font(.title2)
                    .bold()
                Spacer()
            }

            TextField("Full name", text: $name)
                .textFieldStyle(FormTextFieldStyle())
                .autocapitalization(.words)
                .disableAutocorrection(true)

            Button("Continue") {
                authManager.signIn(userIdentity: name)
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: !name.isEmpty))
            .disabled(name.isEmpty)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
