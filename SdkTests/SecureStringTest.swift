//
// Created by Stefan Rusek on 4/30/20.
//

import Foundation
import XCTest
@testable import Sdk

class SecureStringTest: XCTestCase {
    func testCreate() {
        let ss = SpreedlySecureOpaqueStringImpl(from: "abc")
        XCTAssertEqual(ss.internalToString(), "abc")
    }

    func testAppend() {
        let ss = SpreedlySecureOpaqueStringImpl()
        ss.append(string: "a")
        ss.append(string: "b")
        ss.append(string: "c")
        XCTAssertEqual(ss.internalToString(), "abc")
    }

    func testRemove() {
        let ss = SpreedlySecureOpaqueStringImpl(from: "abcdef")
        ss.removeLastCharacter()
        ss.removeLastCharacter()
        ss.removeLastCharacter()
        XCTAssertEqual(ss.internalToString(), "abc")
    }

    func testToJson() {
        let ss = SpreedlySecureOpaqueStringImpl(from: "abc")
        let data = try! JSONEncoder().encode(ss);
        XCTAssertEqual(String(data: data, encoding: .utf8), "\"abc\"")
    }
}
