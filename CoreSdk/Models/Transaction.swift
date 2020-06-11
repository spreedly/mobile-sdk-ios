//
// Created by Stefan Rusek on 5/7/20.
//

import Foundation
import RxSwift

@objc(SPRTransactionBase)
public class TransactionBase: NSObject {
    @objc public let token: String?
    @objc public let createdAt: Date?
    @objc public let updatedAt: Date?
    @objc public let succeeded: Bool
    @objc public let transactionType: String?
    @objc public let retained: Bool
    @objc public let state: String?
    @objc public let messageKey: String
    @objc public let message: String
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
    }
}

public class Transaction<TPaymentMethod>: TransactionBase where TPaymentMethod: PaymentMethodResultBase {
    public let paymentMethod: TPaymentMethod?

    override init(from json: [String: Any]) {
        if let paymentMethodJson = json.object(optional: "payment_method") {
            paymentMethod = TPaymentMethod(from: paymentMethodJson)
        } else {
            paymentMethod = nil
        }

        super.init(from: json)
    }

    static func unwrapFrom(data: Data) throws -> Transaction<TPaymentMethod> {
        let json = try data.decodeJson()
        if json.keys.contains("transaction") {
            return Transaction(from: try json.object(for: "transaction"))
        }

        return Transaction(from: json)
    }
}

@objc(SPRTransaction)
public class _ObjCTransaction: TransactionBase {
    @objc public var paymentMethod: PaymentMethodResultBase?

    @objc public var creditCard: CreditCardResult? {
        paymentMethod as? CreditCardResult
    }
    @objc public var bankAccount: BankAccountResult? {
        paymentMethod as? BankAccountResult
    }
    @objc public var applePay: ApplePayResult? {
        paymentMethod as? ApplePayResult
    }

    override init(from json: [String: Any]) {
        if let paymentMethodJson = json.object(optional: "payment_method") {
            paymentMethod = _ObjCTransaction.initPaymentMethod(from: paymentMethodJson)
        } else {
            paymentMethod = nil
        }
        super.init(from: json)
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

    static func unwrap(from data: Data) throws -> _ObjCTransaction {
        let json = try data.decodeJson()
        if json.keys.contains("transaction") {
            return _ObjCTransaction(from: try json.object(for: "transaction"))
        }

        return _ObjCTransaction(from: json)
    }
}

@objc(SPRSingleTransaction)
public class _ObjCSingleTransaction: NSObject {
    private var observable: Single<_ObjCTransaction>

    init(observable: Single<_ObjCTransaction>) {
        self.observable = observable
    }

    @objc
    public func subscribe(onSuccess: ((_ObjCTransaction) -> Void)?, onError: ((Error) -> Void)?) {
        _ = observable.subscribe(onSuccess: onSuccess, onError: onError)
    }
}
