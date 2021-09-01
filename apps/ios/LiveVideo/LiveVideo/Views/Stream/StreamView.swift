//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var config: StreamConfig!
    
    init(config: Binding<StreamConfig?>) {
        self._config = config
        UIToolbar.appearance().barTintColor = UIColor(named: "FormBackgroundColor")
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.videoGridBackground.ignoresSafeArea()
                VStack(spacing: 6) {
                    HStack {
                        ZStack {
                            HStack(spacing: 4) {
                                Image(systemName: "dot.radiowaves.left.and.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 12)
                                Text("Live")
                                    .font(.system(size: 13))
                            }
                            .padding([.top, .bottom], 4)
                            .padding([.leading, .trailing], 8)
                        }
                        .foregroundColor(.black)
                        .background(Color.liveBadgeBackground)
                        .cornerRadius(2)
                        Spacer()
                        Text("Room name")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    SwiftUIPlayerView(player: $streamManager.player)
//                    Color.purple
                }
                .padding(6)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button(action: {
                        print("Edit button was tapped")
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.destructive)
                                .frame(width: 24, height: 24, alignment: .bottom)
                            Text("Leave")
                                .font(.system(size: 10))
                        }
                    }
                    .foregroundColor(.videoToolbarText)
                    Spacer()
                }
            }
            .onAppear {
                streamManager.connect(config: config)
            }
//            .alert(isPresented: $streamManager.showError) {
//                if let error = streamManager.error as? LiveVideoError, error.isStreamEndedByHostError {
//                    return Alert(
//                        title: Text("Event is no longer available"),
//                        message: Text("This event has been ended by the host."),
//                        dismissButton: .default(Text("OK")) {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                    )
//                } else {
//                    return Alert(error: streamManager.error!) {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//            }
        }
    }
}

struct StreamView_Previews: PreviewProvider {
    static var previews: some View {
        StreamView(config: .constant(StreamConfig(roomName: "", userIdentity: "")))
            .environmentObject(StreamManager())
    }
}
