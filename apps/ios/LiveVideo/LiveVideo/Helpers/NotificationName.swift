//
//  Copyright (C) 2019 Twilio, Inc.
//

import Foundation

extension Notification.Name {
    static let localParticipantDidChange = Notification.Name("LocalParticipantDidChange")
    static let remoteParticipantDidConnect = Notification.Name("RemoteParticipantDidConnect")
    static let remoteParticipantDidDisconnect = Notification.Name("RemoteParticipantDidDisconnect")
    static let remoteParticipantDidChange = Notification.Name("RemoteParticipantDidChange")
    static let roomDidConnect = Notification.Name("RoomDidConnect")
    static let roomDidDisconnectWithError = Notification.Name("RoomDidDisconnectWithError")
}
