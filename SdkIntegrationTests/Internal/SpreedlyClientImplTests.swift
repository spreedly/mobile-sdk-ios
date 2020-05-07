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

    func testCanCreateBankAccount() throws {
        let bankAccount = BankAccountInfo(
                firstName: "Asha",
                lastName: "Dog",
                bankRoutingNumber: "021000021",
                bankAccountNumber: createClient().createSecureString(from: "9876543210"),
                bankAccountType: .checking,
                bankAccountHolderType: .personal
        )

        let expectation = self.expectation(description: "can create bank account")
        let promise = createClient().createBankAccountPaymentMethod(bankAccount: bankAccount, email: "asha@dog.com")

        _ = promise.subscribe(onSuccess: { (transaction: Transaction<BankAccountResult>) in
            XCTAssertNotNil(transaction)
            let bankAccount = transaction.paymentMethod
            XCTAssertNotNil(bankAccount?.token)
            expectation.fulfill()
        }, onError: { error in
            XCTFail("\(error)")
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10.0)
    }

    func testCanRecache() throws {
        let creditCardPromise = try createCreditCard(retained: true)
        let expectation = self.expectation(description: "can recache verification value")

        _ = creditCardPromise
                .flatMap { transaction -> Single<Transaction<CreditCardResult>> in
                    let creditCard = transaction.paymentMethod
                    guard let token = creditCard?.token else {
                        return Single.error(TestError.invalidResponse(
                                "token was not found in credit card create response"
                        ))
                    }

                    return self.createClient().recache(token: token, verificationValue: self.verificationValue)
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
