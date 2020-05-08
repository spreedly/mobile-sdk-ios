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
        let errors = json.objectList(optional: "errors", { json in try SpreedlyError(from: json) })
        self.errors = errors
        messageKey = json.string(optional: "messageKey") ?? errors?[0].key ?? "unknown"
        message = json.string(optional: "message") ?? errors?[0].message ?? "Unknown Error"

        token = json.string(optional: "token")
        createdAt = json.date(optional: "created_at")
        updatedAt = json.date(optional: "updated_at")
        succeeded = json.bool(optional: "succeeded") ?? false
        transactionType = json.string(optional: "transaction_type")
        retained = json.bool(optional: "retained") ?? false
        state = json.string(optional: "state")

        if let paymentMethodJson = json.object(optional: "payment_method") {
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
            return Transaction(from: try json.object(for: "transaction"))
        } else {
            return Transaction(from: json)
        }
    }
}
