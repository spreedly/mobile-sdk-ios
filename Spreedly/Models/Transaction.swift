//
// Created by Stefan Rusek on 5/7/20.
//

import Foundation
import RxSwift

@objc(SPRTransaction)
public class Transaction: NSObject {
    @objc public let token: String?
    @objc public let createdAt: Date?
    @objc public let updatedAt: Date?
    @objc public let succeeded: Bool
    @objc public let transactionType: String?
    @objc public let retained: Bool
    @objc public let state: String?
    @objc public let messageKey: String
    @objc public let message: String
    @objc public let errors: [SpreedlyError]?
    @objc public let paymentMethod: PaymentMethodResultBase?

    @objc public var creditCard: CreditCardResult? {
        paymentMethod?.paymentMethodType == PaymentMethodType.creditCard ? paymentMethod as? CreditCardResult : nil
    }
    @objc public var bankAccount: BankAccountResult? {
        paymentMethod?.paymentMethodType == PaymentMethodType.bankAccount ? paymentMethod as? BankAccountResult : nil
    }
    @objc public var applePay: ApplePayResult? {
        paymentMethod?.paymentMethodType == PaymentMethodType.applePay ? paymentMethod as? ApplePayResult : nil
    }

    init(from json: [String: Any]) {
        if let paymentMethodJson = json.object(optional: "payment_method") {
            paymentMethod = Transaction.initPaymentMethod(from: paymentMethodJson)
        } else {
            paymentMethod = nil
        }

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
    }

    private static func initPaymentMethod(from json: [String: Any]) -> PaymentMethodResultBase? {
        let paymentMethodType = json.string(optional: "payment_method_type")

        switch paymentMethodType {
        case CreditCardResult.paymentMethodType: return CreditCardResult(from: json)
        case BankAccountResult.paymentMethodType: return BankAccountResult(from: json)
        case ApplePayResult.paymentMethodType: return ApplePayResult(from: json)
        default: return nil
        }
    }

    static func unwrap(from data: Data) throws -> Transaction {
        let json = try data.decodeJson()
        if json.keys.contains("transaction") {
            return Transaction(from: try json.object(for: "transaction"))
        }

        return Transaction(from: json)
    }
}

@objc(SPRSingleTransaction)
public class _ObjCSingleTransaction: NSObject { // swiftlint:disable:this type_name
    private var observable: Single<Transaction>

    init(observable: Single<Transaction>) {
        self.observable = observable
    }

    @objc public func subscribe(onSuccess: ((Transaction) -> Void)?, onError: ((Error) -> Void)?) {
        _ = observable.subscribe(onSuccess: onSuccess, onError: onError)
    }
}
