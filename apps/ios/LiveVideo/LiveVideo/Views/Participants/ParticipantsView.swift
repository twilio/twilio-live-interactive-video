//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var viewModel: ParticipantsViewModel
    @EnvironmentObject var viewersViewModel: ViewersViewModel
    @EnvironmentObject var streamManager: StreamManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Viewers (\(viewersViewModel.viewerCount))")) {
                    ForEach(viewersViewModel.viewersWithRaisedHand) { viewer in
                        HStack {
                            Text("\(viewer.userIdentity) 🖐")
                                .alert(isPresented: $viewModel.showSpeakerInviteSent) {
                                    Alert(
                                        title: Text("Invitation sent"),
                                        message: Text("You invited \(viewer.userIdentity) to be a speaker. They’ll be able to share audio and video."),
                                        dismissButton: .default(Text("Got it!"))
                                    )
                                }
                            Spacer()
                            
                            if streamManager.config.role == .host {
                                Button("Invite to speak") {
                                    viewModel.sendSpeakerInvite(userIdentity: viewer.userIdentity)
                                }
                                .foregroundColor(.backgroundPrimary)
                                .alert(isPresented: $viewModel.showError) {
                                    Alert(error: viewModel.error!) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ForEach(viewersViewModel.viewersWithoutRaisedHand) { viewer in
                        HStack {
                            Text(viewer.userIdentity)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .animation(.default)
            .navigationTitle("Participants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewersViewModel.haveNewRaisedHand = false
        }
    }
}

struct ParticipantsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            ParticipantsView()
                .previewDisplayName("Host")
                .environmentObject(ViewersViewModel.stub(withRaisedHand: ["Alice"], withoutRaisedHand: ["Bob"]))
                .environmentObject(StreamManager(config: .stub(role: .host)))
            ParticipantsView()
                .previewDisplayName("Speaker")
                .environmentObject(ViewersViewModel.stub(withRaisedHand: ["Alice"], withoutRaisedHand: ["Bob"]))
                .environmentObject(StreamManager(config: .stub(role: .speaker)))
            ParticipantsView()
                .previewDisplayName("No Viewers")
                .environmentObject(ViewersViewModel())
                .environmentObject(StreamManager())
        }
        .environmentObject(ParticipantsViewModel())
    }
}

private extension ViewersViewModel {
    static func stub(withRaisedHand: [String] = [], withoutRaisedHand: [String] = []) -> ViewersViewModel {
        let viewModel = ViewersViewModel()
        viewModel.viewersWithRaisedHand = withRaisedHand.map { ViewersViewModel.Viewer(userIdentity: $0) }
        viewModel.viewersWithoutRaisedHand = withoutRaisedHand.map { ViewersViewModel.Viewer(userIdentity: $0) }
        viewModel.viewerCount = withRaisedHand.count + withoutRaisedHand.count
        return viewModel
    }
}

private extension ViewersViewModel.Viewer {
    init(userIdentity: String) {
        self.userIdentity = userIdentity
    }
}
