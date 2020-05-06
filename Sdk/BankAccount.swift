//
// Created by Eli Thompson on 5/1/20.
//
import Foundation

public class BankAccount: NSObject, Codable {
    // Gateway-specific metadata
    public var token: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var storageState: String?
    public var test: Bool?
    public var metadata: [String: String]?
    public var paymentMethodType: String?
    public var errors: [String]?

    // Bank Account-specific data
    // read-only from Spreedly
    public var bankName: String?
    public var accountType: String?
    public var accountHolderType: String?
    public var routingNumberDisplayDigits: String?
    public var accountNumberDisplayDigits: String?
    public var routingNumber: String?
    public var accountNumber: String?
    // write-only to Spreedly
    public var bankRoutingNumber: String?
    public var bankAccountNumber: String?
    public var bankAccountType: String?
    public var bankAccountHolderType: String?

    // Customer-specific data
    public var firstName: String?
    public var lastName: String?
    public var fullName: String?
    public var company: String?
    public var address1: String?
    public var address2: String?
    public var city: String?
    public var state: String?
    public var zip: String?
    public var country: String?
    public var phoneNumber: String?
}

struct CreateBankAccountPaymentMethodRequest: Encodable {
    let bankAccount: BankAccount
    let email: String?
    let metadata: [String: String?]?
}

extension CreateBankAccountPaymentMethodRequest {
    struct CodingData: Encodable {
        let paymentMethod: CreateBankAccountPaymentMethodRequest
    }

    func wrapToData() throws -> Data {
        try Coders.encode(entity: CreateBankAccountPaymentMethodRequest.CodingData(paymentMethod: self))
    }
}
