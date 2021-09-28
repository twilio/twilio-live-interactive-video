//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdate previousCoordinateSpace: UICoordinateSpace,
        interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
        traitCollection previousTraitCollection: UITraitCollection
    ) {
        // So the camera handles orientation changes correctly
        UserInterfaceTracker.sceneInterfaceOrientationDidChange(windowScene)
    }
}
