//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamStatusView: View {
    @EnvironmentObject var streamDocument: SyncStreamDocument
    let streamName: String
    @Binding var streamState: StreamManager.State
    
    var body: some View {
        HStack {
            if streamState == .connected {
                LiveBadge()

                if streamDocument.isRecording {
                    RecordingBadge()
                }
            }

            Spacer(minLength: 20)
            Text(streamName)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .lineLimit(1)
        }
        .background(Color.backgroundBrandStronger)
    }
}

struct StreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let streamNames = ["Short room name", "Long room name that is truncated because it does not fit"]
        let streamStates: [StreamManager.State] = [.connecting, .connected]
        
        ForEach([false, true], id: \.self) { isRecording in
            ForEach(streamStates, id: \.self) { streamState in
                ForEach(streamNames, id: \.self) { streamName in
                    StreamStatusView(streamName: streamName, streamState: .constant(streamState))
                        .environmentObject(SyncStreamDocument.stub(isRecording: isRecording))
                        .frame(width: 400)
                        .background(Color.backgroundStronger)
                        .previewLayout(.sizeThatFits)
                }
            }
        }
    }
}

extension SyncStreamDocument {
    static func stub(isRecording: Bool = false) -> SyncStreamDocument {
        let streamDocument = SyncStreamDocument()
        streamDocument.isRecording = isRecording
        return streamDocument
    }
}
