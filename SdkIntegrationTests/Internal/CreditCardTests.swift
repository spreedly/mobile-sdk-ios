//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import Sdk

class CreditCardTests: XCTestCase {
    let valid = "4111111111111111"

    func testCanCreateCreditCard() throws {
        let client = Helpers.createClient()
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: Helpers.verificationValue),
                year: 2029,
                month: 1
        )

        let expectation = self.expectation(description: "can create credit card")
        let promise = client.createCreditCardPaymentMethod(creditCard: creditCard, email: "dolly@dog.com", metadata: nil)

        _ = promise.subscribe(onSuccess: { transaction in
            XCTAssertNotNil(transaction)
            let actualCreditCard = transaction.paymentMethod
            XCTAssertNotNil(actualCreditCard?.token)
            expectation.fulfill()
        }, onError: { error in
            XCTFail("\(error)")
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10.0)
    }
}
