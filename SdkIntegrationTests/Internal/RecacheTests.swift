//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation
import XCTest
import RxSwift
@testable import Sdk

class RecacheTests: XCTestCase {
    func testCanRecache() throws {
        let creditCardPromise = try Helpers.createCreditCard(retained: true)
        let expectation = self.expectation(description: "can recache verification value")

        _ = creditCardPromise.flatMap { transaction -> Single<Transaction<CreditCardResult>> in
            let creditCard = transaction.paymentMethod
            guard let token = creditCard?.token else {
                return Single.error(TestError.invalidResponse(
                        "token was not found in credit card create response"
                ))
            }

            let verify = Helpers.createClient().createSecureString(from: Helpers.verificationValue)
            return Helpers.createClient().recache(token: token, verificationValue: verify)
        }.subscribe(onSuccess: { (transaction: Transaction<CreditCardResult>) in
            expectation.fulfill()
            XCTAssertEqual("RecacheSensitiveData", transaction.transactionType)
            XCTAssert(transaction.succeeded)
        }, onError: { error in
            expectation.fulfill()
            XCTFail("\(error)")
        })
        self.wait(for: [expectation], timeout: 10.0)
    }
}
