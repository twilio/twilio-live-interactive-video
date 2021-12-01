//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct PasscodeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var passcode = ""
    @Binding var name: String
    @State private var showLoader = false
    @State private var error: Error?
    @State private var isShowingError = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            FormStack {
                Text("This is a number you or someone on your team was sent during setup.")
                    .foregroundColor(.textWeak)
                
                TextField("Passcode", text: $passcode)
                    .textFieldStyle(FormTextFieldStyle()) // TODO: Use number pad
                    .autocapitalization(.words)
                    .disableAutocorrection(true)

                Button("Continue") {
                    showLoader = true
                    authManager.signIn(userIdentity: name, passcode: passcode) { result in
                        showLoader = false
                        
                        switch result {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                        case let .failure(error):
                            self.error = error
                            isShowingError = true
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !passcode.isEmpty))
                .disabled(passcode.isEmpty)
            }

            if showLoader {
                ProgressHUD()
            }
        }
        .navigationTitle("Enter passcode")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isShowingError) {
            Alert(error: error!) {

            }
        }
    }
}

struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasscodeView(name: .constant(""))
        }
    }
}
