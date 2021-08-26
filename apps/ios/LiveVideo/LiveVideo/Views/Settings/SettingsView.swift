//
//  Copyright (C) 2021 Twilio, Inc.
//

import InAppSettingsKit
import SwiftUI
import UIKit

struct SettingsView: UIViewControllerRepresentable {
    @Binding var shouldShowSettings: Bool
    @EnvironmentObject var authManager: AuthManager

    func makeUIViewController(context: Context) -> UINavigationController {
        UserDefaultsManager().sync()

        let settingsViewController = IASKAppSettingsViewController()
        settingsViewController.delegate = context.coordinator

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
            settingsView.shouldShowSettings = false
        }
        
        func settingsViewController(
            _ settingsViewController: IASKAppSettingsViewController,
            buttonTappedFor specifier: IASKSpecifier
        ) {
            switch specifier.key {
            case "SignOut":
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
                    self.settingsView.shouldShowSettings = false
                    
                    // Without async the screen transitions to hide settings and show sign in were not animated
                    DispatchQueue.main.async {
                        self.settingsView.authManager.signOut()
                    }
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
