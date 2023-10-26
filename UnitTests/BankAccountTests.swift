//
// Created by Eli Thompson on 5/1/20.
//
import XCTest
@testable import Spreedly

class BankAccountInfoTests: XCTestCase {
    func testCanEncode() throws {
        let info = BankAccountInfo()
        info.firstName = "Dolly"
        info.lastName = "Dog"
        info.routingNumber = "123456"
        info.accountNumber = SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111")
        info.accountType = .checking
        info.accountHolderType = .personal

        let json = try info.toJson()

        let expected = try """
                           {
                             "first_name" : "Dolly",
                             "last_name" : "Dog",
                             "bank_routing_number" : "123456",
                             "bank_account_number" : "4111111111111111",
                             "bank_account_type" : "checking",
                             "bank_account_holder_type" : "personal"
                           }
                           """.data(using: .utf8)!.spr_decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testCanEncodeWithFullName() throws {
        let info = BankAccountInfo()
        info.fullName = "Dolly Dog"
        info.routingNumber = "123456"
        info.accountNumber = SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111")
        info.accountType = .checking
        info.accountHolderType = .personal

        let json = try info.toJson()

        let expected = try """
                           {
                             "full_name" : "Dolly Dog",
                             "bank_routing_number" : "123456",
                             "bank_account_number" : "4111111111111111",
                             "bank_account_type" : "checking",
                             "bank_account_holder_type" : "personal"
                           }
                           """.data(using: .utf8)!.spr_decodeJson()

        XCTAssertEqual(expected as NSObject, json as NSObject)
    }

    func testFromShouldClone() {
        let source = BankAccountInfo()
        source.fullName = "Dolly Dog"
        source.firstName = "Dolly"
        source.lastName = "Dog"

        source.accountNumber = SpreedlySecureOpaqueStringBuilder.build(from: "9876543210")
        source.routingNumber = "021000021"
        source.accountType = .savings
        source.accountHolderType = .business

        source.address.address1 = "123 Fake St"
        source.shippingAddress.address1 = "321 Wall St"

        let sink = BankAccountInfo(copyFrom: source)

        XCTAssertEqual(sink.fullName, source.fullName)
        XCTAssertEqual(sink.firstName, source.firstName)
        XCTAssertEqual(sink.lastName, source.lastName)

        XCTAssertNil(sink.accountNumber)
        XCTAssertNil(sink.routingNumber)
        XCTAssertEqual(sink.accountType, source.accountType)
        XCTAssertEqual(sink.accountHolderType, source.accountHolderType)

        XCTAssertEqual(sink.address, source.address)
        XCTAssertEqual(sink.shippingAddress, source.shippingAddress)
    }
}
