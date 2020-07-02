//
// Created by Eli Thompson on 6/15/20.
//

import Foundation
import XCTest
@testable import SpreedlyCocoa

class StringAdditionsTests: XCTestCase {
    func testOnlyNumbers() {
        XCTAssertEqual("".onlyNumbers(), "", "empty")
        XCTAssertEqual("abc".onlyNumbers(), "", "alphas omitted")
        XCTAssertEqual("123abc".onlyNumbers(), "123", "alphas suffix omitted")
        XCTAssertEqual("abc123".onlyNumbers(), "123", "alphas prefix omitted")
        XCTAssertEqual("abc123xyz".onlyNumbers(), "123", "alphas surrounding omitted")
        XCTAssertEqual("123abc456".onlyNumbers(), "123456", "alphas surrounded omitted")
        XCTAssertEqual("123.00 - 456.00".onlyNumbers(), "1230045600", "special chars omitted")
        XCTAssertEqual("0123456789".onlyNumbers(), "0123456789", "numbers only")
    }

    func testWithoutSpaces() {
        XCTAssertEqual("".withoutSpaces(), "", "empty")
        XCTAssertEqual("123".withoutSpaces(), "123", "no spaces")
        XCTAssertEqual("123 ".withoutSpaces(), "123", "trailing spaces omitted")
        XCTAssertEqual("  123".withoutSpaces(), "123", "leading spaces omitted")
        XCTAssertEqual("4111 1111 1111 1111".withoutSpaces(), "4111111111111111", "middle spaces omitted")
    }
}
