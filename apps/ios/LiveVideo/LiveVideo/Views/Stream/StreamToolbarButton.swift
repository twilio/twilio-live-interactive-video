//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamToolbarButton: View {
    struct Role {
        let imageForegroundColor: Color
        let imageBackgroundColor: Color
        
        static let `default` = Role(
            imageForegroundColor: .backgroundStrongest,
            imageBackgroundColor: .backgroundStrong
        )
        static let destructive = Role(
            imageForegroundColor: .white,
            imageBackgroundColor: .backgroundDestructive
        )
    }
    
    let title: String
    let image: Image
    let role: Role
    let action: () -> Void
    
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
                ZStack {
                    role.imageBackgroundColor
                        .clipShape(Circle())
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(6)
                        .foregroundColor(role.imageForegroundColor)
                }
                .frame(width: 27, height: 27)

                Text(title)
                    .font(.system(size: 10))
            }
            .padding(.top, 7)
            .frame(width: 60)
            .foregroundColor(.backgroundStrongest)
        }
    }
}

struct StreamToolbarButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StreamToolbarButton("Default", image: Image(systemName: "mic.slash"))
                .previewDisplayName("Default")
            StreamToolbarButton("Destructive", image: Image(systemName: "arrow.left"), role: .destructive)
                .previewDisplayName("Destructive")
        }
        .previewLayout(.sizeThatFits)
    }
}
