//
//  Copyright (C) 2022 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class SyncStreamDocument: NSObject, SyncObjectConnecting, ObservableObject {
    struct DocumentData {
        struct Recording {
            let isRecording: Bool
            let error: String?
        }
        
        let recording: Recording
        
        init(data: [String: Any]) throws {
            guard
                let recording = data["recording"] as? [String: Any],
                let isRecording = recording["is_recording"] as? Bool
            else {
                throw LiveVideoError.syncObjectDecodeError
            }

            let error = recording["error"] as? String
            
            self.recording = Recording(isRecording: isRecording, error: error)
        }
    }
        
    @Published var isRecording = false
    
    /// Record errors are informative and do not end the stream, so provide a special path to handle them. It would be nice to have
    /// a single path for all errors but that would require a significant refactor and probably make other code more complex.
    @Published var recordError: Error?

    var errorHandler: ((Error) -> Void)?
    private var document: TWSDocument?
    
    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
        guard let options = TWSOpenOptions.open(withSidOrUniqueName: "stream") else { return }
        
        client.openDocument(with: options, delegate: self) { [weak self] result, document in
            guard let document = document else {
                completion(result.error!)
                return
            }
            
            self?.document = document

            do {
                try self?.update(data: document.data)
            } catch {
                completion(error)
            }
            
            completion(nil)
        }
    }
    
    func disconnect() {
        document = nil
        isRecording = false
        recordError = nil
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        errorHandler?(error)
    }
    
    private func update(data: [String: Any], previousData: [String: Any]? = nil) throws {
        let data = try DocumentData(data: data)

        isRecording = data.recording.isRecording
        
        if let error = data.recording.error {
            var isNewError = false
            
            if let previousData = previousData {
                if try DocumentData(data: previousData).recording.error == nil {
                    isNewError = true
                }
            } else {
                isNewError = true
            }
            
            if isNewError {
                recordError = LiveVideoError.recordError(message: error)
            }
        }
    }
}

extension SyncStreamDocument: TWSDocumentDelegate {
    func onDocument(
        _ document: TWSDocument,
        updated data: [String: Any],
        previousData: [String: Any],
        eventContext: TWSEventContext
    ) {
        do {
            try update(data: data, previousData: previousData)
        } catch {
            handleError(error)
        }
    }
    
    func onDocument(_ document: TWSDocument, errorOccurred error: TWSError) {
        handleError(error)
    }
}

