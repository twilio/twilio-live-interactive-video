//
//  Copyright (C) 2021 Twilio, Inc.
//

struct PasscodeComponents {
    let passcode: String
    let appID: String
    let serverlessID: String
    private let shortPasscodeLength = 6
    private let appIDLength = 4
    private let serverlessIDMinLength = 4
    
    init(string: String) throws {
        guard string.count >= shortPasscodeLength + appIDLength + serverlessIDMinLength else {
            throw LiveVideoError.passcodeIncorrect
        }
        
        passcode = string

        let appIDStartIndex = string.index(string.startIndex, offsetBy: shortPasscodeLength)
        let appIDEndIndex = string.index(appIDStartIndex, offsetBy: appIDLength - 1)
        appID = String(string[appIDStartIndex...appIDEndIndex])

        let serverlessIDStartIndex = string.index(after: appIDEndIndex)
        serverlessID = String(string[serverlessIDStartIndex...])
    }
}
