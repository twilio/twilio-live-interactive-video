//
//  Copyright (C) 2021 Twilio, Inc.
//

import InAppSettingsKit
import SwiftUI
import UIKit

struct SettingsView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var signOut: Bool

    func makeUIViewController(context: Context) -> UINavigationController {
        signOut = false
        UserDefaultsManager().sync()

        let settingsViewController = IASKAppSettingsViewController()
        settingsViewController.delegate = context.coordinator
        settingsViewController.neverShowPrivacySettings = true

        let navigationController = UINavigationController()
        navigationController.viewControllers = [settingsViewController]

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(settingsView: self)
    }

    class Coordinator: NSObject, IASKSettingsDelegate {
        private let settingsView: SettingsView

        init(settingsView: SettingsView) {
            self.settingsView = settingsView
        }
        
        func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {
            settingsView.presentationMode.wrappedValue.dismiss()
        }
        
        func settingsViewController(
            _ settingsViewController: IASKAppSettingsViewController,
            buttonTappedFor specifier: IASKSpecifier
        ) {
            switch specifier.key {
            case "SignOut":
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
                    self.settingsView.signOut = true
                    self.settingsView.presentationMode.wrappedValue.dismiss()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                [signOutAction, cancelAction].forEach { alertController.addAction($0) }
                settingsViewController.present(alertController, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}
