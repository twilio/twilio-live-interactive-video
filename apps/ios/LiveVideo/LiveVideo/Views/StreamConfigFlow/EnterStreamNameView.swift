//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct EnterStreamNameView: View {
    private struct ViewModel {
        let title: String
        let tip: String
        let shouldShowRecordOption: Bool
        let shouldSelectRole: Bool
    }
    
    @EnvironmentObject var flowModel: StreamConfigFlowModel
    @EnvironmentObject var authManager: AuthManager
    @State private var streamName = ""
    @State private var isShowingSelectRole = false
    @State private var shouldRecord = false

    private var viewModel: ViewModel {
        switch flowModel.parameters.role {
        case .host:
            return ViewModel(
                title: "Create new event",
                tip: "Give your event a name that’s related to the topic you’ll be talking about.",
                shouldShowRecordOption: true,
                shouldSelectRole: false
            )
        case .none, .viewer, .speaker:
            return ViewModel(
                title: "Join event",
                tip: "Enter the event name.",
                shouldShowRecordOption: false,
                shouldSelectRole: true
            )
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text(viewModel.tip)
                ) {
                    TextField("Event name", text: $streamName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if viewModel.shouldShowRecordOption {
                    Section(header: Text("Recording")) {
                        Toggle("Record event", isOn: $shouldRecord)
                    }
                }
                
                Section(
                    footer:
                        VStack {
                            NavigationLink(destination: SelectRoleView(), isActive: $isShowingSelectRole) {
                                EmptyView()
                            }
                            
                            Button("Continue") {
                                flowModel.parameters.streamName = streamName
                                flowModel.parameters.userIdentity = authManager.userIdentity
                                flowModel.parameters.shouldRecord = shouldRecord
                                
                                if viewModel.shouldSelectRole {
                                    isShowingSelectRole = true
                                } else {
                                    flowModel.isShowing = false
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle(isEnabled: !streamName.isEmpty))
                            .disabled(streamName.isEmpty)
                            .padding(.horizontal, -20)
                        }
                ) {
                    /// Using the footer to have more control over style
                }
            }
            .navigationBarTitle(viewModel.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        flowModel.isShowing = false
                    }
                }
            }
        }
    }
}

struct EnterStreamNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterStreamNameView()
            .previewDisplayName("Create")
            .environmentObject(StreamConfigFlowModel.stub(role: .host))
        EnterStreamNameView()
            .previewDisplayName("Join")
            .environmentObject(StreamConfigFlowModel.stub(role: nil))
    }
}

extension StreamConfigFlowModel {
    static func stub(streamName: String? = nil, role: StreamConfig.Role? = nil) -> StreamConfigFlowModel {
        let flowModel = StreamConfigFlowModel()
        flowModel.parameters.streamName = streamName
        flowModel.parameters.role = role
        return flowModel
    }
}
