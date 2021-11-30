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
    @StateObject private var api = API()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamViewModel)
                .environmentObject(participantsViewModel)
                .environmentObject(streamManager)
                .environmentObject(speakerGridViewModel)
                .environmentObject(speakerSettingsManager)
                .environmentObject(api)
                .onAppear {
                    authManager.configure(api: api)
                    let localParticipant = LocalParticipantManager(authManager: authManager)
                    let roomManager = RoomManager()
                    roomManager.configure(localParticipant: localParticipant)
                    let viewerStore = ViewerStore()
                    let speakersStore = SyncUsersStore()
                    let raisedHandsStore = SyncUsersStore()
                    let viewersStore = SyncUsersStore()
                    let syncManager = SyncManager(
                        speakersStore: speakersStore,
                        viewersStore: viewersStore,
                        raisedHandsStore: raisedHandsStore,
                        viewerStore: viewerStore
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
                        viewerStore: viewerStore
                    )
                    participantsViewModel.configure(
                        streamManager: streamManager,
                        api: api,
                        roomManager: roomManager,
                        speakersStore: speakersStore,
                        viewersStore: viewersStore,
                        raisedHandsStore: raisedHandsStore
                    )
                    speakerSettingsManager.configure(roomManager: roomManager)
                    speakerGridViewModel.configure(roomManager: roomManager, speakersStore: speakersStore)
                }
        }
    }
}
