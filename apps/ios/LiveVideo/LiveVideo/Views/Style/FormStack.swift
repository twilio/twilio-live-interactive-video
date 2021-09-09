//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct FormStack<Content>: View where Content: View {
    private let spacing: CGFloat
    private let content: () -> Content
    
    init(spacing: CGFloat = 30, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: spacing) {
                content()
                Spacer()
            }
            .padding(40)
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormStack {
            TextField("Text field", text: .constant(""))
                .textFieldStyle(FormTextFieldStyle())
            Button("Button") {

            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
