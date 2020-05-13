//
// Created by Stefan Rusek on 5/6/20.
//

import XCTest
import RxSwift
@testable import Sdk

class BankAccountTests: XCTestCase {
    func testCanCreateBankAccount() throws {
        let client = Helpers.createClient()
        let info = BankAccountInfo(
                firstName: "Asha",
                lastName: "Dog",
                bankRoutingNumber: "021000021",
                bankAccountNumber: client.createSecureString(from: "9876543210"),
                bankAccountType: .checking,
                bankAccountHolderType: .personal
        )

        let promise = client.createBankAccountPaymentMethod(bankAccount: info, email: "asha@dog.com")

        let transaction = try promise.assertResult(self)
        let bankAccount = transaction.paymentMethod!

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
