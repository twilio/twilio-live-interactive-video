//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct EnterStreamNameView: View {
    private struct ViewModel {
        let title: String
        let tip: String
        let shouldSelectRole: Bool
    }
    
    @EnvironmentObject var flowModel: StreamConfigFlowModel
    @State private var streamName = ""
    @State private var isShowingSelectRole = false

    private var viewModel: ViewModel {
        switch flowModel.parameters.role {
        case .host:
            return ViewModel(
                title: "Create new event",
                tip: "Tip: give your event a name that’s related to the topic you’ll be talking about.",
                shouldSelectRole: false
            )
        case .none, .viewer, .speaker:
            return ViewModel(
                title: "Join event",
                tip: "Enter the event name.",
                shouldSelectRole: true
            )
        }
    }

    var body: some View {
        NavigationView {
            FormStack {
                Text(viewModel.tip)
                    .modifier(TipStyle())

                TextField("Event name", text: $streamName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                VStack {
                    NavigationLink(destination: SelectRoleView(), isActive: $isShowingSelectRole) {
                        EmptyView()
                    }

                    Button("Continue") {
                        flowModel.parameters.streamName = streamName
                        
                        if viewModel.shouldSelectRole {
                            isShowingSelectRole = true
                        } else {
                            flowModel.isShowing = false
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: !streamName.isEmpty))
                    .disabled(streamName.isEmpty)
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
