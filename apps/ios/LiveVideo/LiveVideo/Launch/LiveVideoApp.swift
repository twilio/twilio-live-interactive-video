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
    @StateObject private var hostControlsManager = HostControlsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()
    @StateObject private var presentationLayoutViewModel = PresentationLayoutViewModel()
    @StateObject private var api = API()
    @StateObject private var streamDocument = SyncStreamDocument()
    @StateObject private var appSettingsManager = AppSettingsManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamViewModel)
                .environmentObject(participantsViewModel)
                .environmentObject(streamManager)
                .environmentObject(speakerGridViewModel)
                .environmentObject(presentationLayoutViewModel)
                .environmentObject(speakerSettingsManager)
                .environmentObject(hostControlsManager)
                .environmentObject(api)
                .environmentObject(streamDocument)
                .environmentObject(appSettingsManager)
                .onAppear {
                    authManager.configure(api: api, appSettingsManager: appSettingsManager)
                    let localParticipant = LocalParticipantManager(authManager: authManager)
                    let roomManager = RoomManager()
                    roomManager.configure(localParticipant: localParticipant)
                    let userDocument = SyncUserDocument()
                    let speakersMap = SyncUsersMap(uniqueName: "speakers")
                    let raisedHandsMap = SyncUsersMap(uniqueName: "raised_hands")
                    let viewersMap = SyncUsersMap(uniqueName: "viewers")
                    let speakerVideoViewModelFactory = SpeakerVideoViewModelFactory()
                    let syncManager = SyncManager(
                        speakersMap: speakersMap,
                        viewersMap: viewersMap,
                        raisedHandsMap: raisedHandsMap,
                        userDocument: userDocument,
                        streamDocument: streamDocument,
                        appSettingsManager: appSettingsManager
                    )
                    streamManager.configure(
                        roomManager: roomManager,
                        playerManager: PlayerManager(),
                        syncManager: syncManager,
                        api: api,
                        appSettingsManager: appSettingsManager
                    )
                    streamViewModel.configure(
                        streamManager: streamManager,
                        speakerSettingsManager: speakerSettingsManager,
                        api: api,
                        userDocument: userDocument,
                        streamDocument: streamDocument
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
                    hostControlsManager.configure(roomManager: roomManager, api: api)
                    speakerVideoViewModelFactory.configure(speakersMap: speakersMap)
                    speakerGridViewModel.configure(
                        roomManager: roomManager,
                        speakersMap: speakersMap,
                        speakerVideoViewModelFactory: speakerVideoViewModelFactory
                    )
                    presentationLayoutViewModel.configure(
                        roomManager: roomManager,
                        speakersMap: speakersMap,
                        speakerVideoViewModelFactory: speakerVideoViewModelFactory
                    )
                }
        }
    }
}
