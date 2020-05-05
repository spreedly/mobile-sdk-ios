//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import Sdk

class SpreedlyErrorTests: XCTestCase {
    func testMessageAppearsInStringDescription() {
        let message = "I'm afraid I can't do that."
        let err = SpreedlyError(message: message)
        XCTAssert("\(err)".contains(message))
    }
}
