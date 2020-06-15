//
//  SPCreditCardNumberTextField.swift
//  SdkIntegrationTests
//
//  Created by Eli Thompson on 6/12/20.
//

import Foundation
import XCTest
@testable import CocoaSdk

class SPCreditCardNumberTextFieldTests: XCTestCase {
    func testFormatCardNumber() {
        let field = SPCreditCardNumberTextField()
        XCTAssertEqual(field.formatCardNumber(""), "")
        XCTAssertEqual(field.formatCardNumber("4"), "4")
        XCTAssertEqual(field.formatCardNumber("4111"), "4111")
        XCTAssertEqual(field.formatCardNumber("41111111"), "4111 1111")
        XCTAssertEqual(field.formatCardNumber("411111111111"), "4111 1111 1111")
        XCTAssertEqual(field.formatCardNumber("4111111111111111"), "4111 1111 1111 1111")
        XCTAssertEqual(field.formatCardNumber("4111 1111 1111 1111"), "4111 1111 1111 1111")
        XCTAssertEqual(field.formatCardNumber("4111111111111111111"), "4111 1111 1111 1111 111")
    }

    func testCleanAndReplace() {
        XCTAssertEqual(clean("", 0.step(0), "1"), "1", "previously empty")
        XCTAssertEqual(clean("4111", 0.step(4), "9"), "9", "can replace all")
        XCTAssertEqual(clean("4111", 0.step(4), ""), "", "can clear all")

        XCTAssertNil(clean("4111 1111 1111 1111 111", 23.step(0), "9"), "max digits 19")
        XCTAssertNil(clean("5454 5454 5454 5454", 19.step(0), "9"), "max digits 16")
        XCTAssertNil(clean("4111", 4.step(0), "a"), "numbers only")
    }

    func clean(_ current: String, _ range: NSRange, _ replacement: String) -> String? {
        let field = SPCreditCardNumberTextField()
        return field.cleanAndReplace(current: current, range: range, replacementString: replacement)
    }

    func testGenerateMasked() {
        let field = SPCreditCardNumberTextField()
        XCTAssertEqual(field.generateMasked(from: ""), "")
        XCTAssertEqual(field.generateMasked(from: "4"), "4")
        XCTAssertEqual(field.generateMasked(from: "41"), "41")
        XCTAssertEqual(field.generateMasked(from: "411"), "411")
        XCTAssertEqual(field.generateMasked(from: "4111"), "4111")
        XCTAssertEqual(field.generateMasked(from: "41111"), "*111 1")
        XCTAssertEqual(field.generateMasked(from: "41111111"), "**** 1111")
        XCTAssertEqual(field.generateMasked(from: "411111111111"), "**** **** 1111")
        XCTAssertEqual(field.generateMasked(from: "4111111111111111"), "**** **** **** 1111")
        XCTAssertEqual(field.generateMasked(from: "4111 1111 1111 1111"), "**** **** **** 1111")
        XCTAssertEqual(field.generateMasked(from: "4111111111111111111"), "**** **** **** ***1 111")
    }
}

fileprivate extension Int {
    func step(_ length: Int) -> NSRange {
        NSRange(location: self, length: length)
    }
}
