//
// Created by Eli Thompson on 4/30/20.
//
import Foundation
import XCTest
import RxSwift
@testable import Sdk

class CreateCreditCardIntegrationTests: XCTestCase {
    let verificationValue = "919"

    func client() -> SpreedlyClientImpl {
        let envKey = ProcessInfo.processInfo.environment["ENV_KEY"]!
        let envSecret = ProcessInfo.processInfo.environment["ENV_SECRET"]!
        return SpreedlyClientImpl(env: envKey, secret: envSecret)
    }

    func createCreditCard(retained: Bool? = nil) -> Single<Transaction<CreditCard>> {
        var creditCard = CreditCard()
        creditCard.number = "4111111111111111"
        creditCard.verificationValue = verificationValue
        creditCard.firstName = "Dolly"
        creditCard.lastName = "Dog"
        creditCard.month = 1
        creditCard.year = 2022
        creditCard.retained = retained

        return client().createCreditCardPaymentMethod(creditCard: creditCard, email: "dolly@dog.com")
    }

    func testCanCreateCreditCard() throws {
        var creditCard = CreditCard()
        creditCard.number = "4111111111111111"
        creditCard.verificationValue = "919"
        creditCard.firstName = "Dolly"
        creditCard.lastName = "Dog"
        creditCard.month = 1
        creditCard.year = 2022

        let expectation = self.expectation(description: "can create credit card")
        let promise = client().createCreditCardPaymentMethod(creditCard: creditCard, email: "dolly@dog.com")

        _ = promise.subscribe(onSuccess: { transaction in
            XCTAssertNotNil(transaction)
            let actualCreditCard = transaction.paymentMethod
            XCTAssertNotNil(actualCreditCard.token)
            expectation.fulfill()
        }, onError: { error in
            XCTFail("\(error)")
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10.0)
    }

    func testCanCreateBankAccount() throws {
        let bankAccount = BankAccount()
        bankAccount.firstName = "Asha"
        bankAccount.lastName = "Dog"
        bankAccount.bankRoutingNumber = "021000021"
        bankAccount.bankAccountNumber = "9876543210"
        bankAccount.bankAccountType = "checking"
        bankAccount.bankAccountHolderType = "personal"

        let expectation = self.expectation(description: "can create bank account")
        let promise = client().createBankAccountPaymentMethod(bankAccount: bankAccount, email: "asha@dog.com")

        _ = promise.subscribe(onSuccess: { (transaction: Transaction<BankAccount>) in
            XCTAssertNotNil(transaction)
            let bankAccount = transaction.paymentMethod
            XCTAssertNotNil(bankAccount.token)
            expectation.fulfill()
        }, onError: { error in
            XCTFail("\(error)")
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10.0)
    }

    func testCanRecache() throws {
        let creditCardPromise = createCreditCard(retained: true)
        let expectation = self.expectation(description: "can recache verification value")

        _ = creditCardPromise.flatMap { transaction -> Single<Transaction<CreditCard>> in
            let creditCard = transaction.paymentMethod
            guard let token = creditCard.token else {
                return Single.error(SpreedlyError(message: "token was not found in credit card create response"))
            }
            return self.client().recache(token: token, verificationValue: self.verificationValue)
        }.subscribe(onSuccess: { (transaction: Transaction<CreditCard>) in
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
