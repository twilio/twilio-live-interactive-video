//
//  Copyright (C) 2021 Twilio, Inc.
//

import AVFoundation
import TwilioPlayer

protocol PlayerManagerDelegate: AnyObject {
    func playerManagerDidConnect(_ playerManager: PlayerManager)
    func playerManager(_ playerManager: PlayerManager, didDisconnectWithError error: Error)
}

class PlayerManager: NSObject {
    weak var delegate: PlayerManagerDelegate?
    private(set) var player: Player?
    private let audioSession = AVAudioSession.sharedInstance()
    private var accessToken: String!
    
    func configure(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func connect() {
        if player != nil {
            play()
        } else {
            player = Player.connect(accessToken: accessToken, delegate: self)
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func disconnect() {
        player?.pause()
        player = nil
    }

    private func play() {
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            handleError(error)
            return
        }
        
        player?.play()
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        delegate?.playerManager(self, didDisconnectWithError: error)
    }
}

extension PlayerManager: PlayerDelegate {
    func playerDidFailWithError(player: Player, error: Error) {
        handleError(error)
    }

    func playerDidChangePlayerState(player: Player, playerState state: Player.State) {
        switch state {
        case .ready:
            play()
            delegate?.playerManagerDidConnect(self)
        case .ended:
            // Use ended state to detect when the host ends the stream so that the user receives the entire
            // stream and does not miss the last 2 seconds because of delay.
            handleError(LiveVideoError.streamEndedByHost)
        case .idle, .buffering, .playing:
            break
        @unknown default:
            break
        }
    }
    
    func playerWillRebuffer(player: Player) {
        print("Player will rebuffer.")
    }
}
