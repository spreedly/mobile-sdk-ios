//
// Created by Stefan Rusek on 5/6/20.
//

import XCTest
import RxSwift
import Spreedly

class RecacheTests: XCTestCase {
    func testCanRecache() throws {
        let creditCardPromise = try Helpers.createCreditCard(retained: true)

        let transaction = try creditCardPromise.flatMap { transaction -> Single<Transaction> in
            let creditCard = transaction.paymentMethod
            guard let token = creditCard?.token else {
                return Single.error(TestError.invalidResponse(
                        "token was not found in credit card create response"
                ))
            }

            let verify = SpreedlySecureOpaqueStringBuilder.build(from: Helpers.verificationValue)
            return Helpers.createClient().recache(token: token, verificationValue: verify)
        }.assertResult(self)

        XCTAssertEqual("RecacheSensitiveData", transaction.transactionType)
        XCTAssert(transaction.succeeded)
    }
}