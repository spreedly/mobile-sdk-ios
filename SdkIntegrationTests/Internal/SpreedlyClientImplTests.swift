//
// Created by Eli Thompson on 4/30/20.
//
import Foundation
import XCTest
import RxSwift
@testable import Sdk

class CreateCreditCardIntegrationTests: XCTestCase {
    let verificationValue = "919"

    func client() throws -> SpreedlyClientImpl {
        return SpreedlyClientImpl(env: ENV_KEY, secret: ENV_SECRET)
    }

    func createCreditCard(retained: Bool? = nil) throws -> Single<Transaction<CreditCard>> {
        var creditCard = CreditCard()
        creditCard.number = "4111111111111111"
        creditCard.verificationValue = verificationValue
        creditCard.firstName = "Dolly"
        creditCard.lastName = "Dog"
        creditCard.month = 1
        creditCard.year = 2022

        return try client().createCreditCardPaymentMethod(
                creditCard: creditCard,
                email: "dolly@dog.com",
                retained: retained
        )
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
        let spreedlyClient: SpreedlyClientImpl
        do {
            spreedlyClient = try client()
        } catch {
            XCTFail("Unable to create client. \(error)")
            return
        }

        let promise = spreedlyClient.createCreditCardPaymentMethod(creditCard: creditCard, email: "dolly@dog.com")

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
        let spreedlyClient: SpreedlyClientImpl
        do {
            spreedlyClient = try client()
        } catch {
            XCTFail("Unable to create client. \(error)")
            return
        }
        let promise = spreedlyClient.createBankAccountPaymentMethod(bankAccount: bankAccount, email: "asha@dog.com")

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
        let creditCardPromise = try createCreditCard(retained: true)
        let expectation = self.expectation(description: "can recache verification value")

        _ = creditCardPromise
        .flatMap { transaction -> Single<Transaction<CreditCard>> in
            let creditCard = transaction.paymentMethod
            guard let token = creditCard.token else {
                return Single.error(SpreedlyError(message: "token was not found in credit card create response"))
            }

            let spreedlyClient: SpreedlyClientImpl
            do {
                spreedlyClient = try self.client()
            } catch {
                XCTFail("Unable to create client. \(error)")
                throw error
            }

            return spreedlyClient.recache(token: token, verificationValue: self.verificationValue)
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
