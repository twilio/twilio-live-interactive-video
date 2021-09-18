//
//  Copyright (C) 2019 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension Notification.Name {
    static let roomDidConnect = Notification.Name("roomDidConnect")
    static let roomDidFailToConnect = Notification.Name("roomDidFailToConnect")
    static let roomDidDisconnect = Notification.Name("roomDidDisconnect")
    static let remoteParticipantDidConnect = Notification.Name("remoteParticipantDidConnect")
    static let remoteParticipantDidDisconnect = Notification.Name("remoteParticipantDidDisconnect")

    static let remoteParticipantDidChangeMic = Notification.Name("remoteParticipantDidChangeMic")
    static let remoteParticipantDidChangeCameraTrack = Notification.Name("remoteParticipantDidChangeCameraTrack")
    static let remoteParticipantDidChangeDominantSpeaker = Notification.Name("remoteParticipantDidChangeDominantSpeaker")

    static let localParticipantDidChangeMic = Notification.Name("localParticipantDidChangeMic")
    static let localParticipantDidChangeCameraTrack = Notification.Name("localParticipantDidChangeCameraTrack")

}