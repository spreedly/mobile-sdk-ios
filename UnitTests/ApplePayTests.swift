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

        let info = ApplePayInfo(payment: payment)
        XCTAssertEqual(info.paymentToken, payment.token.paymentData)
    }

    func testInitWithFirstLastData() {
        let info = ApplePayInfo(paymentTokenData: TokenStub.data)
        XCTAssertEqual(info.paymentToken, TokenStub.data)
    }
}
