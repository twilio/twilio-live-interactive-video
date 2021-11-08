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
    @StateObject private var viewersViewModel = ViewersViewModel()
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
                .environmentObject(viewersViewModel)
                .environmentObject(api)
                .onAppear {
                    let localParticipant = LocalParticipantManager(authManager: authManager)
                    let roomManager = RoomManager()
                    roomManager.configure(localParticipant: localParticipant)
                    let viewerStore = ViewerStore()
                    let raisedHandsStore = RaisedHandsStore()
                    let viewersStore = ViewersStore()
                    let syncManager = SyncManager(
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
                    participantsViewModel.configure(api: api, roomManager: roomManager)
                    speakerSettingsManager.configure(localParticipant: localParticipant)
                    speakerGridViewModel.configure(roomManager: roomManager)
                    viewersViewModel.configure(
                        streamManager: streamManager,
                        viewersStore: viewersStore,
                        raisedHandsStore: raisedHandsStore
                    )
                }
        }
    }
}
