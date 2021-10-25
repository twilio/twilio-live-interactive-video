//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

//struct CardButtonLabel: View {
//    let title: String
//    let image: Image
//    let imageColor: Color
//    var detail: String?
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 4)
//                .foregroundColor(.white)
//                .shadow(color: .shadowLow, radius: 8, x: 0, y: 2)
//            RoundedRectangle(cornerRadius: 4)
//                .stroke(Color.borderWeaker, lineWidth: 1)
//
//            VStack {
//                HStack {
//                    ZStack {
//                        imageColor
//                            .opacity(0.08)
//                            .clipShape(Circle())
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .padding(10)
//                            .foregroundColor(imageColor)
//                    }
//                    .frame(width: 40, height: 40)
//
//                    Text(title)
//                        .foregroundColor(.textWeak)
//                        .fontWeight(.bold)
//                        .lineLimit(1)
//
//                    Spacer()
//                    Image(systemName: "arrow.right")
//                        .foregroundColor(.backgroundPrimary)
//                        .font(.system(size: 20, weight: .medium))
//                        .padding(.trailing, 8)
//                }
//                .padding(16)
//
//                if let detail = detail {
//                    Text(detail)
//                        .multilineTextAlignment(.leading)
//                }
//
//            }
//
//
//        }
//        .fixedSize(horizontal: false, vertical: true)
//    }
//}

struct CardButtonLabel: View {
    let title: String
    let image: Image
    var imageColor = Color.backgroundPrimary
    var detail: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
                .shadow(color: .shadowLow, radius: 8, x: 0, y: 2)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.borderWeaker, lineWidth: 1)
            
            HStack(alignment: .imageTitleAlignmentGuide) {
                ZStack {
                    imageColor
                        .opacity(0.08)
                        .clipShape(Circle())
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                        .foregroundColor(imageColor)
                        .alignmentGuide(.imageTitleAlignmentGuide) { context in
                            context[VerticalAlignment.center]
                        }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .fontWeight(.bold)
                        .alignmentGuide(.imageTitleAlignmentGuide) { context in
                            context[VerticalAlignment.center]
                        }
                        .multilineTextAlignment(.leading)

                    if let detail = detail {
                        Text(detail)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 13))
                    }
                }
                .foregroundColor(.textWeak)

                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.backgroundPrimary)
                    .font(.system(size: 20, weight: .medium))
                    .padding(.trailing, 8)
                    .alignmentGuide(.imageTitleAlignmentGuide) { context in
                        context[VerticalAlignment.center]
                    }
            }
            .padding(16)

        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// https://developer.apple.com/documentation/swiftui/aligning-views-across-stacks
extension VerticalAlignment {
    /// A custom alignment for image titles.
    private struct ImageTitleAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[VerticalAlignment.bottom]
        }
    }

    /// A guide for aligning titles.
    static let imageTitleAlignmentGuide = VerticalAlignment(
        ImageTitleAlignment.self
    )
}

struct CardButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button(action: { }) {
                CardButtonLabel(
                    title: "Title",
                    image: Image(systemName: "mic")
                )
            }
            .previewDisplayName("Default Image Color")
            
            Button(action: { }) {
                CardButtonLabel(
                    title: "Title",
                    image: Image(systemName: "plus.square"),
                    imageColor: .backgroundSuccess
                )
            }
            .previewDisplayName("Custom Image Color")

            Button(action: { }) {
                CardButtonLabel(
                    title: String(repeating: "Title ", count: 10),
                    image: Image(systemName: "mic")
                )
            }
            .previewDisplayName("Long Title")

            Button(action: { }) {
                CardButtonLabel(
                    title: "Title",
                    image: Image(systemName: "mic"),
                    detail: String(repeating: "Detail ", count: 20)
                )
            }
            .previewDisplayName("Detail")

            Button(action: { }) {
                CardButtonLabel(
                    title: String(repeating: "Title ", count: 10),
                    image: Image(systemName: "mic"),
                    detail: String(repeating: "Detail ", count: 20)
                )
            }
            .previewDisplayName("Long Title with Detail")
        }
        
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
