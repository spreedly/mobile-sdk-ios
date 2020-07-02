//
// Created by Eli Thompson on 5/4/20.
//

import XCTest
@testable import CoreSdk

class SpreedlyErrorTests: XCTestCase {
    func testMessageAppearsInStringDescription() throws {
        let errorJson = "{ \"errors\":[{\"key\":\"key\", \"message\":\"crazy error\"}] }"
        if let data = errorJson.data(using: .utf8) {
            let trans = try Transaction.unwrapFrom(data: data)
            XCTAssertEqual(trans.message, "crazy error")
        } else {
            XCTFail("unexpected json error")
        }
    }
}
