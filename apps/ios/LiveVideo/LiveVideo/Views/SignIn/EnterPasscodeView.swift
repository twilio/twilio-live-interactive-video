//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct EnterPasscodeView: View {
    let userIdentity: String
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @State private var passcode = ""
    @State private var isShowingLoader = false
    @State private var isShowingError = false
    @State private var error: Error?

    var body: some View {
        ZStack {
            FormStack {
                Text("This is a number you or someone on your team was sent during setup.")
                    .foregroundColor(.textWeak)
                
                SecureField("Passcode", text: $passcode)
                    .textFieldStyle(FormTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Button("Continue") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isShowingLoader = true
                    
                    authManager.signIn(userIdentity: userIdentity, passcode: passcode) { result in
                        isShowingLoader = false
                        
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

            if isShowingLoader {
                ProgressHUD()
            }
        }
        .navigationTitle("Enter passcode")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $isShowingError) {
            Alert(error: error!)
        }
    }
}

struct EnterPasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnterPasscodeView(userIdentity: "")
        }
    }
}
