//
// Created by Stefan Rusek on 5/7/20.
//

import Foundation

public class Transaction<TPaymentMethod> where TPaymentMethod: PaymentMethodResultBase {
    public let token: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let succeeded: Bool
    public let transactionType: String?
    public let retained: Bool
    public let state: String?
    public let messageKey: String
    public let message: String
    public let paymentMethod: TPaymentMethod?
    public let errors: [SpreedlyError]?

    init(from json: [String: Any]) {
        let errors = json.optObjectList("errors", { json in try SpreedlyError(from: json) })
        self.errors = errors
        messageKey = json["messageKey"] as? String ?? errors?[0].key ?? "unknown"
        message = json["message"] as? String ?? errors?[0].message ?? "Unknown Error"

        token = json["token"] as? String
        createdAt = json.optDate("created_at")
        updatedAt = json.optDate("created_at")
        succeeded = json["succeeded"] as? Bool ?? false
        transactionType = json["transaction_type"] as? String
        retained = json["retained"] as? Bool ?? false
        state = json["state"] as? String

        if let paymentMethodJson = json["payment_method"] as? [String: Any] {
            paymentMethod = TPaymentMethod(from: paymentMethodJson)
        } else {
            paymentMethod = nil
        }
    }
}

extension Transaction {

    static func unwrapFrom(data: Data) throws -> Transaction<TPaymentMethod> {
        let json = try data.decodeJson()
        if json.keys.contains("transaction") {
            return Transaction(from: try json.getObject("transaction"))
        } else {
            return Transaction(from: json)
        }
    }
}
