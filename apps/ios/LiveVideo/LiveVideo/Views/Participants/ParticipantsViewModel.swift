//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

class ParticipantsViewModel: ObservableObject {
    @Published var showError = false
    @Published var showSpeakerInviteSent = false
    private(set) var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private var api: API!
    private var roomManager: RoomManager!
    
    
    func configure(api: API, roomManager: RoomManager) {
        self.api = api
        self.roomManager = roomManager
    }
    
    func sendSpeakerInvite(userIdentity: String) {
        let request = SendSpeakerInviteRequest(userIdentity: userIdentity, roomSID: roomManager.roomSID!)

        api.request(request) { [weak self] result in
            switch result {
            case .success:
                self?.showSpeakerInviteSent = true
            case let .failure(error):
                self?.error = error
            }
        }
    }
}
