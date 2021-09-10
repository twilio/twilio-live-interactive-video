//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct VideoGridView: View {
    @Binding var participants: [RoomParticipant]
    
    var body: some View {
        VStack {
            if participants.count == 0 {
                Spacer()
            } else {
                ForEach($participants, id: \.self) { $participant in
                    ZStack {
                        SwiftUIVideoView(videoTrack: $participant.cameraTrack)
                        Text(participant.identity)
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}

struct VideoGridView_Previews: PreviewProvider {
    static var previews: some View {
        VideoGridView(participants: .constant([
            RoomParticipant(participant: LocalParticipant(identity:  "foo")),
            RoomParticipant(participant: LocalParticipant(identity:  "bar"))
        ]))
            .frame(height: 500)
            .previewLayout(.sizeThatFits)
    }
}






class RoomParticipant: ObservableObject, Identifiable, Hashable {
    static func == (lhs: RoomParticipant, rhs: RoomParticipant) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    @Published var cameraTrack: VideoTrack?
    let identity: String
    var id: String { identity }
    
    init(participant: Participant) {
        cameraTrack = participant.cameraTrack
        identity = participant.identity
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
        case let .didRemoveRemoteParticipants(participants):
            roomParticipants.removeAll { $0.identity == participants[0].identity } // fix for multiple items
        case let .didUpdateParticipants(participants):
            
            
            break // update(participants: participants)
        }
    }
}
