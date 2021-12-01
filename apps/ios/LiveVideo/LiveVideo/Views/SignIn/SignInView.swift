//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SignInView: View {
    @State private var name = ""
    @State private var isShowingDetailView = false

    var body: some View {
        NavigationView {
            FormStack {
                Image("RedTwilioLogo")
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome to:")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.textWeak)
                    
                    // Had to force a new line because it was wrapping too early. It looked like it was trying to
                    // make both lines similar width which is not what UX design was going for.
                    Text("Twilio Live Video\nEvents")
                        .modifier(TitleStyle())
                }
                
                Text("What's your name?")
                    .modifier(TipStyle())

                TextField("Full name", text: $name)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.words)
                    .disableAutocorrection(true)

                NavigationLink(destination: PasscodeView(name: $name), isActive: $isShowingDetailView) {
                    EmptyView()
                }
                
                Button("Continue") {
                    isShowingDetailView = true
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !name.isEmpty))
                .disabled(name.isEmpty)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
