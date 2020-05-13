//
// Created by Eli Thompson on 4/30/20.
//

import Foundation
import XCTest
import RxSwift
@testable import Sdk

class CreateCreditCardIntegrationTests: XCTestCase {
    let verificationValue = "919"

    /**
     Initializes a SpreedlyClient by searching for the key and secret first in the environment variables (most useful
     for local development) and then by the secret variables (injected via CI).
    */
    func createClient() -> SpreedlyClientImpl {
        let key = ProcessInfo.processInfo.environment["ENV_KEY"] ?? secretEnvKey
        let secret = ProcessInfo.processInfo.environment["ENV_SECRET"] ?? secretEnvSecret
        return SpreedlyClientImpl(envKey: key, envSecret: secret, test: true)
    }

    func createCreditCard(retained: Bool? = nil) throws -> Single<Transaction<CreditCardResult>> {
        let client = createClient()
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: verificationValue),
                year: 2029,
                month: 1
        )
        creditCard.retained = retained

        return client.createCreditCardPaymentMethod(
                creditCard: creditCard,
                email: "dolly@dog.com"
        )
    }

    func testCanCreateCreditCard() throws {
        let client = createClient()
        let creditCard = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: verificationValue),
                year: 2029,
                month: 1
        )

        let expectation = self.expectation(description: "can create credit card")
        let promise = createClient().createCreditCardPaymentMethod(creditCard: creditCard, email: "dolly@dog.com")

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
