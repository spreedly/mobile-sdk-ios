//
// Created by Stefan Rusek on 5/6/20.
//

import XCTest
import Spreedly

class RecacheTests: XCTestCase {
    func testCanRecache() throws {
        let creditCardPromise = try Helpers.createCreditCard(retained: true)
        let creditCard = try creditCardPromise.assertResult(self).paymentMethod
        guard let token = creditCard?.token else {
            assertionFailure("token was not found in credit card create response")
            return
        }

        let verify = SpreedlySecureOpaqueStringBuilder.build(from: Helpers.verificationValue)
        let transaction = try Helpers.createClient().recache(token: token, verificationValue: verify).assertResult(self)

        XCTAssertEqual("RecacheSensitiveData", transaction.transactionType)
        XCTAssert(transaction.succeeded)
    }
}
