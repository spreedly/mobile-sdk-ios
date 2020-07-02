//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import XCTest
@testable import Spreedly

class ObjCTransactionTests: XCTestCase {
    func testInitWhenNoPaymentMethodGivenShouldHaveNilPaymentMethod() {
        let transactionResponse: [String: Any] = [
            "token": "abc123",
            "succeeded": false
        ]

        let transaction = _ObjCTransaction(from: transactionResponse)

        XCTAssertFalse(transaction.succeeded)
        XCTAssertNil(transaction.paymentMethod)
    }
}
