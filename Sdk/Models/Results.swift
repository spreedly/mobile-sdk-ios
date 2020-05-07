//
// Created by Stefan Rusek on 5/6/20.
//

import Foundation

public enum StorageState: String, Codable {
    case cached
    case retained
    case redacted
}

public enum PaymentMethodType: String, Codable {
    case creditCard = "credit_card"
    case bankAccount = "bank_account"
    case applePay = "apple_pay"
    case googlePay = "google_pay"
    case thirdPartyToken = "third_party_token"
}

public struct SpreedlyError: Decodable {
    public let key: String
    public let message: String
    public let attribute: String?

    init(from json: [String: Any]) throws {
        key = try json.string(for: "key")
        message = try json.string(for: "message")
        attribute = json.string(optional: "attribute")
    }
}

public class PaymentMethodResultBase {
    public let token: String?
    public let storageState: StorageState?
    public let test: Bool
    public let paymentMethodType: PaymentMethodType?
    public let address: Address?
    public let shippingAddress: Address?
    public let errors: [SpreedlyError]

    required init(from json: [String: Any]) {
        token = json.string(optional: "token")
        storageState = json["storage_state"] as? StorageState
        test = json.bool(optional: "test") ?? false
        paymentMethodType = json["payment_method_type"] as? PaymentMethodType
        address = Address(from: json, as: .billing)
        shippingAddress = Address(from: json, as: .shipping)
        errors = json.objectList(optional: "errors", { json in try SpreedlyError(from: json) }) ?? []
    }
}

public class CreditCardResult: PaymentMethodResultBase {
    var cardType: String?
    var year: Int?
    var month: Int?

    var lastFourDigits: String?
    var firstSixDigits: String?
    var number: String?

    var eligibleForCardUpdater: Bool?
    var callbackUrl: String?
    var fingerprint: String?

    required init(from json: [String: Any]) {
        cardType = json.string(optional: "card_type")
        year = json.int(optional: "year")
        month = json.int(optional: "month")

        lastFourDigits = json.string(optional: "last_four_digits")
        firstSixDigits = json.string(optional: "first_six_digits")
        number = json.string(optional: "number")

        eligibleForCardUpdater = json.bool(optional: "eligible_for_card_updater")
        callbackUrl = json.string(optional: "callback_url")
        fingerprint = json.string(optional: "fingerprint")

        super.init(from: json)
    }
}

public class BankAccountResult: PaymentMethodResultBase {
    required init(from json: [String: Any]) {
        super.init(from: json)
    }
}
