//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name = ""

    var body: some View {
        ZStack {
            Color.formBackground.ignoresSafeArea()
            VStack {
                HStack {
                    Text("Welcome to Twilio Live Events!")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                .padding(.top, 30)

                TextField("Full name", text: $name)
                    .textFieldStyle(FormTextFieldStyle())
                    .padding(.top, 30)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)

                Button("Continue") {
                    authManager.signIn(userIdentity: name)
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !name.isEmpty))
                .padding(.top, 30)
                .disabled(name.isEmpty)

                Spacer()
            }
            .padding(40)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
