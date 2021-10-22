//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct CardButtonLabel: View {
    let title: String
    let image: Image
    let imageColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
                .shadow(color: .shadowLow, radius: 8, x: 0, y: 2)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.borderWeaker, lineWidth: 1)
            HStack {
                ZStack {
                    imageColor
                        .opacity(0.08)
                        .clipShape(Circle())
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                        .foregroundColor(imageColor)
                }
                .frame(width: 40, height: 40)
                
                Text(title)
                    .foregroundColor(.textWeak)
                    .fontWeight(.bold)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.backgroundPrimary)
                    .font(.system(size: 20, weight: .medium))
                    .padding(.trailing, 8)
            }
            .padding(16)

        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct CardButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button(action: { }) {
                CardButtonLabel(
                    title: "Title",
                    image: Image(systemName: "plus.square"),
                    imageColor: .backgroundSuccess
                )
            }
            Button(action: { }) {
                CardButtonLabel(
                    title: "A very long title that is truncated",
                    image: Image(systemName: "plus.square"),
                    imageColor: .backgroundSuccess
                )
            }
        }
        
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
