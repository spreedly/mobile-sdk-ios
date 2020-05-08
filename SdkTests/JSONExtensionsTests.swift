//
// Created by Eli Thompson on 5/8/20.
//

import Foundation
import XCTest
@testable import Sdk

class JsonExtensionTests : XCTestCase {
    func testDecodeJsonWhenNotJsonShouldThrow() {
        let notJson = "<ul><li>list item</li></ul>"
        let data = notJson.data(using: .utf8)!
        XCTAssertThrowsError(try data.decodeJson()) { error in
            XCTAssertEqual(error as? JSONError, .expectedObject)
        }
    }

    func testDecodeWhenNotJsonObjectShouldThrow() {
        let validJson = """
                        "I'm just a string"
                        """
        let data = validJson.data(using: .utf8)!
        XCTAssertThrowsError(try data.decodeJson()) { error in
            XCTAssertEqual(error as? JSONError, .expectedObject)
        }
    }

    func testDecodeWhenValidJsonObjectShouldDecode() throws {
        let validJson = """
                        {"key": "value"}
                        """
        let data = validJson.data(using: .utf8)!
        let decodedObject = try data.decodeJson()
        XCTAssertEqual("value", try decodedObject.string(for: "key"))
    }
}
