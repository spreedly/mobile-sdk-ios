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

public struct SpreedlyError2: Decodable {
    public let key: String
    public let message: String
    public let attribute: String?

    init(from json: [String: Any]) {
        key = json["key"] as! String
        message = json["message"] as! String
        attribute = json["attribute"] as? String
    }
}

public class PaymentMethodResultBase {
    public let token: String?
    public let storageState: StorageState?
    public let test: Bool
    public let paymentMethodType: PaymentMethodType?
    public let address: Address?
    public let shippingAddress: Address?
    public let errors: [SpreedlyError2]

    required public init(from json: [String: Any]) {
        token = json["token"] as? String
        storageState = json["storage_state"] as? StorageState
        test = json["test"] as? Bool ?? false
        paymentMethodType = json["payment_method_type"] as? PaymentMethodType
        address = Address(from: json, as: .billing)
        shippingAddress = Address(from: json, as: .shipping)
        errors = json.optObjectList("errors", { json in SpreedlyError2(from: json) }) ?? []
    }
}

public class CreditCardResult: PaymentMethodResultBase {
    public required init(from json: [String: Any]) {
        super.init(from: json)
    }
}

public class BankAccountResult: PaymentMethodResultBase {
    public required init(from json: [String: Any]) {
        super.init(from: json)
    }
}
