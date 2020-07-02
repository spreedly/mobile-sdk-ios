//
// Created by Eli Thompson on 6/2/20.
//

import Foundation
import PassKit
import XCTest
@testable import Spreedly

class ApplePayInfoTests: XCTestCase {
    class TokenStub: PKPaymentToken {
        static var data: Data {
            "$$$".data(using: .utf8)!
        }
        override var paymentData: Data {
            TokenStub.data
        }
    }

    class PaymentStub: PKPayment {
        override var token: PKPaymentToken {
            TokenStub()
        }
    }

    func testInitWithFirstLastToken() {
        let payment = PaymentStub()

        let info = ApplePayInfo(firstName: "Dolly", lastName: "Dog", payment: payment)

        XCTAssertEqual(info.firstName, "Dolly")
        XCTAssertEqual(info.lastName, "Dog")
        XCTAssertNil(info.fullName)
        XCTAssertEqual(info.paymentToken, payment.token.paymentData)
    }

    func testInitWithFirstLastData() {
        let info = ApplePayInfo(firstName: "Dolly", lastName: "Dog", paymentTokenData: TokenStub.data)

        XCTAssertEqual(info.firstName, "Dolly")
        XCTAssertEqual(info.lastName, "Dog")
        XCTAssertNil(info.fullName)
        XCTAssertEqual(info.paymentToken, TokenStub.data)
    }

    func testInitWithFullNameToken() {
        let payment = PaymentStub()

        let info = ApplePayInfo(fullName: "Dolly Dog", payment: payment)

        XCTAssertNil(info.firstName)
        XCTAssertNil(info.lastName)
        XCTAssertEqual(info.fullName, "Dolly Dog")
        XCTAssertEqual(info.paymentToken, payment.token.paymentData)
    }

    func testInitWithFullNameData() {
        let info = ApplePayInfo(fullName: "Dolly Dog", paymentTokenData: TokenStub.data)

        XCTAssertNil(info.firstName)
        XCTAssertNil(info.lastName)
        XCTAssertEqual(info.fullName, "Dolly Dog")
        XCTAssertEqual(info.paymentToken, TokenStub.data)
    }
}
