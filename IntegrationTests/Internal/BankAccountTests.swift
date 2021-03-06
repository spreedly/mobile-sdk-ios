//
// Created by Stefan Rusek on 5/6/20.
//

import XCTest
import Spreedly

class BankAccountTests: XCTestCase {
    func testCanCreateBankAccount() throws {
        let client = Helpers.createClient()
        let info = BankAccountInfo()
        info.firstName = "Asha"
        info.lastName = "Dog"
        info.routingNumber = Helpers.testBankRoutingNumber
        info.accountNumber = Helpers.secureBankAccountNumber
        info.accountType = .checking
        info.accountHolderType = .personal

        let promise = client.createPaymentMethodFrom(bankAccount: info)

        let transaction = try promise.assertResult(self)
        let bankAccount = transaction.bankAccount!

        XCTAssertNotNil(bankAccount.token)
        XCTAssertNil(bankAccount.bankName)
        XCTAssertEqual(bankAccount.accountType, BankAccountType.checking)
        XCTAssertEqual(bankAccount.accountHolderType, BankAccountHolderType.personal)
        XCTAssertEqual(bankAccount.routingNumberDisplayDigits, "021")
        XCTAssertEqual(bankAccount.accountNumberDisplayDigits, "3210")
        XCTAssertEqual(bankAccount.routingNumber, "021*")
        XCTAssertEqual(bankAccount.accountNumber, "*3210")

    }
}
