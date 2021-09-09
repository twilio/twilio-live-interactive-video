//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @Binding var participants: [RoomParticipant]
    
    var body: some View {
        VStack {
            ForEach(participants, id: \.self) { participant in
                SwiftUIVideoView(videoTrack: participant.cameraTrack)
            }
            
            ForEach(participants) { participant in
                SwiftUIVideoView(videoTrack: participant.cameraTrack)
            }
        }
    }
}

struct VideoGridView_Previews: PreviewProvider {
    static var previews: some View {
        VideoGridView(participants: .constant([]))
            .frame(height: 500)
            .previewLayout(.sizeThatFits)
    }
}






class RoomParticipant: ObservableObject {
    @Published var cameraTrack: VideoTrack?
    
    init(participant: Participant) {
        cameraTrack = participant.cameraTrack
    }
}


class StreamViewModel: ObservableObject {
    @Published var roomParticipants: [RoomParticipant] = []
    private let notificationCenter = NotificationCenter.default
    
    init() {
        notificationCenter.addObserver(self, selector: #selector(handleRoomUpdate(_:)), name: .roomUpdate, object: nil)
    }
    
    @objc private func handleRoomUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? RoomManager.Update else { return }
        
        switch payload {
        case .didStartConnecting, .didConnect, .didFailToConnect, .didDisconnect: break
        case let .didAddRemoteParticipants(participants):
            roomParticipants.append(contentsOf: participants.map { RoomParticipant(participant: $0) })
        case let .didRemoveRemoteParticipants(participants): break // delete(participants: participants)
        case let .didUpdateParticipants(participants): break // update(participants: participants)
        }
    }
}
