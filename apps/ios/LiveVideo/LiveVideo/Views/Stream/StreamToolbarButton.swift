//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamToolbarButton: View {
    struct Role {
        let imageForegroundColor: Color
        
        static let `default` = Role(imageForegroundColor: .videoToolbarText)
        static let destructive = Role(imageForegroundColor: .destructive)
    }
    
    let title: String
    let image: Image
    let action: () -> Void
    let role: Role
    
    init(_ title: String, image: Image, role: Role = .default, action: @escaping () -> Void = { }) {
        self.title = title
        self.image = image
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 4) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(role.imageForegroundColor)
                    .frame(width: 24, height: 24, alignment: .bottom)
                Text(title)
                    .font(.system(size: 10))
            }
            .padding(.top, 7)
            .frame(minWidth: 50)
            .foregroundColor(.videoToolbarText)
        }
    }
}

struct StreamToolbarButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StreamToolbarButton("Default", image: Image(systemName: "mic.slash.fill"))
                .previewDisplayName("Default")
            StreamToolbarButton("Destructive", image: Image(systemName: "arrow.left.circle.fill"), role: .destructive)
                .previewDisplayName("Destructive")
        }
        .previewLayout(.sizeThatFits)
    }
}
