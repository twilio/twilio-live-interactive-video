//
//  Copyright (C) 2021 Twilio, Inc.
//

import Nimble
import Quick
@testable import LiveVideo

class PasscodeComponentsSpec: QuickSpec {
    override func spec() {
        var sut: PasscodeComponents?
        
        describe("init") {
            context("when string length is 13") {
                it("throws passcodeIncorrect error") {
                    expect({ try PasscodeComponents(string: "256984") }).to(throwError(LiveVideoError.passcodeIncorrect))
                }
            }

            context("when string length is 14") {
                beforeEach {
                    sut = try? PasscodeComponents(string: "65897412385467")
                }
                
                it("sets passcode to entire string") {
                    expect(sut?.passcode).to(equal("65897412385467"))
                }
                
                it("sets appID to characters at indices 6 to 9") {
                    expect(sut?.appID).to(equal("1238"))
                }
                
                it("sets serverlessID to last 4 characters") {
                    expect(sut?.serverlessID).to(equal("5467"))
                }
            }
            
            context("when string length is 20") {
                beforeEach {
                    sut = try? PasscodeComponents(string: "59846823174859632894")
                }
                
                it("sets passcode to entire string") {
                    expect(sut?.passcode).to(equal("59846823174859632894"))
                }
                
                it("sets appID to characters at indices 6 to 9") {
                    expect(sut?.appID).to(equal("2317"))
                }
                
                it("sets serverlessID to last 10 characters") {
                    expect(sut?.serverlessID).to(equal("4859632894"))
                }
            }
        }
    }
}
