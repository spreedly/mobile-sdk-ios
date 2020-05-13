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

    func assertMinimalCardFieldsPopulate(result: CreditCardResult, info: CreditCardInfo) {
        XCTAssertNotNil(result.token)
        XCTAssertEqual(result.storageState, StorageState.cached)
        XCTAssertEqual(result.test, true)
        XCTAssertEqual(result.paymentMethodType, PaymentMethodType.creditCard)
        XCTAssertNil(result.callbackUrl)

        XCTAssertEqual(result.firstName, info.firstName)
        XCTAssertEqual(result.lastName, info.lastName)
        XCTAssertEqual(result.fullName, "\(info.firstName!) \(info.lastName!)")

        XCTAssertEqual(result.cardType, "visa")
        XCTAssertEqual(result.year, info.year)
        XCTAssertEqual(result.month, info.month)

        XCTAssertEqual(result.lastFourDigits, "1111")
        XCTAssertEqual(result.firstSixDigits, "411111")
        XCTAssertEqual(result.number, "XXXX-XXXX-XXXX-1111")
        XCTAssertNotNil(result.fingerprint)
    }

    func testCanCreateMinimalCreditCard() throws {
        let client = createClient()
        let info = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: verificationValue),
                year: 2029,
                month: 1
        )

        let expectation = self.expectation(description: "can create credit card")
        let email = ""
        let promise = createClient().createCreditCardPaymentMethod(creditCard: info, email: email)

        _ = promise.subscribe(onSuccess: { transaction in
            XCTAssertNotNil(transaction)
            let result = transaction.paymentMethod!

            self.assertMinimalCardFieldsPopulate(result: result, info: info)

            XCTAssertEqual(result.email, email)

            expectation.fulfill()
        }, onError: { error in
            XCTFail("\(error)")
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10.0)
    }

    func testCanCreateFullCreditCard() throws {
        let client = createClient()
        let info = CreditCardInfo(
                firstName: "Dolly",
                lastName: "Dog",
                number: client.createSecureString(from: "4111111111111111"),
                verificationValue: client.createSecureString(from: verificationValue),
                year: 2029,
                month: 1
        )

        var billing = Address()
        billing.address1 = "123 Fake St"
        billing.address2 = "Suite #200"
        billing.city = "Springfield"
        billing.state = "OR"
        billing.zip = "97475"
        billing.country = "US"
        billing.phoneNumber = "541-555-2222"
        info.address = billing

        var shipping = Address()
        shipping.address1 = "321 Wall St"
        shipping.address2 = "Suite #4100"
        shipping.city = "Seattle"
        shipping.state = "WA"
        shipping.zip = "98121"
        shipping.country = "US"
        shipping.phoneNumber = "206-555-2222"
        info.shippingAddress = shipping

        let expectation = self.expectation(description: "can create credit card")
        let email = "dolly@dog.com"
        let promise = createClient().createCreditCardPaymentMethod(creditCard: info, email: email)

        _ = promise.subscribe(onSuccess: { transaction in
            XCTAssertNotNil(transaction)
            let result = transaction.paymentMethod!

            self.assertMinimalCardFieldsPopulate(result: result, info: info)

            XCTAssertEqual(result.email, email)

            XCTAssertEqual(result.address?.address1, billing.address1)
            XCTAssertEqual(result.address?.address2, billing.address2)
            XCTAssertEqual(result.address?.city, billing.city)
            XCTAssertEqual(result.address?.state, billing.state)
            XCTAssertEqual(result.address?.zip, billing.zip)
            XCTAssertEqual(result.address?.country, billing.country)
            XCTAssertEqual(result.address?.phoneNumber, billing.phoneNumber)

            XCTAssertEqual(result.shippingAddress?.address1, shipping.address1)
            XCTAssertEqual(result.shippingAddress?.address2, shipping.address2)
            XCTAssertEqual(result.shippingAddress?.city, shipping.city)
            XCTAssertEqual(result.shippingAddress?.state, shipping.state)
            XCTAssertEqual(result.shippingAddress?.zip, shipping.zip)
            XCTAssertEqual(result.shippingAddress?.country, shipping.country)
            XCTAssertEqual(result.shippingAddress?.phoneNumber, shipping.phoneNumber)

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
            let bankAccount = transaction.paymentMethod!
            XCTAssertNotNil(bankAccount.token)
            XCTAssertNil(bankAccount.bankName)
            XCTAssertEqual(bankAccount.accountType, BankAccountType.checking)
            XCTAssertEqual(bankAccount.accountHolderType, BankAccountHolderType.personal)
            XCTAssertEqual(bankAccount.routingNumberDisplayDigits, "021")
            XCTAssertEqual(bankAccount.accountNumberDisplayDigits, "3210")
            XCTAssertEqual(bankAccount.routingNumber, "021*")
            XCTAssertEqual(bankAccount.accountNumber, "*3210")
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

                    let verify = self.createClient().createSecureString(from: self.verificationValue)
                    return self.createClient().recache(token: token, verificationValue: verify)
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
