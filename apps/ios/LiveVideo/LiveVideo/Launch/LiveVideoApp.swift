//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

@main
struct LiveVideoApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var streamViewModel = StreamViewModel()
    @StateObject private var participantsViewModel = ParticipantsViewModel()
    @StateObject private var streamManager = StreamManager()
    @StateObject private var speakerSettingsManager = SpeakerSettingsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()
    @StateObject private var presentationViewModel = PresentationViewModel()
    @StateObject private var api = API()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamViewModel)
                .environmentObject(participantsViewModel)
                .environmentObject(streamManager)
                .environmentObject(speakerGridViewModel)
                .environmentObject(presentationViewModel)
                .environmentObject(speakerSettingsManager)
                .environmentObject(api)
                .onAppear {
                    authManager.configure(api: api)
                    let localParticipant = LocalParticipantManager(authManager: authManager)
                    let roomManager = RoomManager()
                    roomManager.configure(localParticipant: localParticipant)
                    let userDocument = SyncUserDocument()
                    let speakersMap = SyncUsersMap()
                    let raisedHandsMap = SyncUsersMap()
                    let viewersMap = SyncUsersMap()
                    let syncManager = SyncManager(
                        speakersMap: speakersMap,
                        viewersMap: viewersMap,
                        raisedHandsMap: raisedHandsMap,
                        userDocument: userDocument
                    )
                    streamManager.configure(
                        roomManager: roomManager,
                        playerManager: PlayerManager(),
                        syncManager: syncManager,
                        api: api
                    )
                    streamViewModel.configure(
                        streamManager: streamManager,
                        speakerSettingsManager: speakerSettingsManager,
                        api: api,
                        userDocument: userDocument
                    )
                    participantsViewModel.configure(
                        streamManager: streamManager,
                        api: api,
                        roomManager: roomManager,
                        speakersMap: speakersMap,
                        viewersMap: viewersMap,
                        raisedHandsMap: raisedHandsMap
                    )
                    speakerSettingsManager.configure(roomManager: roomManager)
                    speakerGridViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, api: api)
                    presentationViewModel.configure(roomManager: roomManager, speakersMap: speakersMap)
                }
        }
    }
}
