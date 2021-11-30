//
//  Copyright (C) 2021 Twilio, Inc.
//

struct PasscodeComponents {
    let passcode: String
    let appID: String?
    let serverlessID: String
    
    init(string: String) throws {
        passcode = string
        let shortPasscodeLength = 6
        let appIDLength = 4
        let serverlessIDMinLength = 4
        let newFormatMinLength = shortPasscodeLength + appIDLength + serverlessIDMinLength
        let oldFormatMinLength = shortPasscodeLength + serverlessIDMinLength

        if string.count >= newFormatMinLength {
            let appIDStartIndex = string.index(string.startIndex, offsetBy: shortPasscodeLength)
            let appIDEndIndex = string.index(appIDStartIndex, offsetBy: appIDLength - 1)
            appID = String(string[appIDStartIndex...appIDEndIndex])
            let serverlessIDStartIndex = string.index(after: appIDEndIndex)
            serverlessID = String(string[serverlessIDStartIndex...])
        } else if string.count >= oldFormatMinLength {
            appID = nil
            let serverlessIDStartIndex = string.index(string.startIndex, offsetBy: shortPasscodeLength)
            serverlessID = String(string[serverlessIDStartIndex...])
        } else {
            throw LiveVideoError.passcodeIncorrect
        }
    }
}
