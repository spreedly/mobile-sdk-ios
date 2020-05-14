//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import XCTest
import RxSwift
@testable import Sdk

class SecureStringTest: XCTestCase {

    func testCreateFromClientWithoutContent() {
        let secureString = createSpreedlyClient(envKey: "", envSecret: "").createSecureString()
        XCTAssertNotNil(secureString)
    }

    func testCreateFromClientWithContent() {
        let secureString = createSpreedlyClient(envKey: "", envSecret: "").createSecureString(from: "abc")
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

    func testClear() {
        let secureString = SpreedlySecureOpaqueStringImpl(from: "abcdef")
        secureString.clear()
        XCTAssertEqual(secureString.internalToString(), "")
    }

    func testToJson() throws {
        let secureString = SpreedlySecureOpaqueStringImpl(from: "abc")
        let data = try JSONEncoder().encode(secureString)
        XCTAssertEqual(String(data: data, encoding: .utf8), "\"abc\"")
    }
}

class DictionaryExtensionsTests: XCTestCase {
    class AlternateImpl: SpreedlySecureOpaqueString {
        func clear() {
            // empty
        }

        func append(_ string: String) {
            // empty
        }

        func removeLastCharacter() {
            // empty
        }
    }
    func testSetOpaqueStringWhenNotMainImplShouldThrow() throws {
        var json: [String: Any] = [:]
        XCTAssertThrowsError(try json.setOpaqueString("key", AlternateImpl())) { error in 
            XCTAssertEqual(SpreedlySecurityError.invalidOpaqueString, error as? SpreedlySecurityError)
        }
    }

    func testWhenIsMainImplShouldSet() throws {
        var json: [String: Any] = [:]
        try json.setOpaqueString("secure", SpreedlySecureOpaqueStringImpl.init(from: "string"))
        XCTAssertEqual("string", json["secure"] as? String)
    }
}
