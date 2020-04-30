//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import XCTest
import RxSwift
@testable import Sdk

class SecureStringTest: XCTestCase {
    func testCreateFromClient() {
        let secureString = createSpreedlyClient(env: "", secret: "").createSecureString(from: "abc")
        XCTAssertNotNil(secureString)
    }

    func testCreate() {
        let secureString = SpreedlySecureOpaqueStringImpl(from: "abc")
        XCTAssertEqual(secureString.internalToString(), "abc")
    }

    func testAppend() {
        let secureString = SpreedlySecureOpaqueStringImpl()
        secureString.append("a")
        secureString.append("b")
        secureString.append("c")
        XCTAssertEqual(secureString.internalToString(), "abc")
    }

    func testRemove() {
        let secureString = SpreedlySecureOpaqueStringImpl(from: "abcdef")
        secureString.removeLastCharacter()
        secureString.removeLastCharacter()
        secureString.removeLastCharacter()
        XCTAssertEqual(secureString.internalToString(), "abc")
    }

    func testToJson() throws {
        let secureString = SpreedlySecureOpaqueStringImpl(from: "abc")
        let data = try JSONEncoder().encode(secureString)
        XCTAssertEqual(String(data: data, encoding: .utf8), "\"abc\"")
    }
}
