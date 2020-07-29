//
// Created by Eli Thompson on 7/13/20.
//

import Foundation

@objc public enum BankAccountType: Int, CaseIterable {
    case unknown
    case checking
    case savings

    public var stringValue: String? {
        switch self {
        case .unknown: return nil
        case .checking: return "checking"
        case .savings: return "savings"
        }
    }

    static func from(_ string: String?) -> BankAccountType {
        switch string {
        case "checking": return .checking
        case "savings": return .savings
        default: return .unknown
        }
    }
}

@objc public enum BankAccountHolderType: Int, CaseIterable {
    case unknown
    case business
    case personal

    public var stringValue: String? {
        switch self {
        case .unknown: return nil
        case .business: return "business"
        case .personal: return "personal"
        }
    }

    static func from(_ string: String?) -> BankAccountHolderType {
        switch string {
        case "business": return .business
        case "personal": return .personal
        default: return .unknown
        }
    }
}

/// A set of information used when creating a bank account payment method with Spreedly.
public class BankAccountInfo: PaymentMethodInfo {
    @objc public var bankRoutingNumber: String?
    @objc public var bankAccountNumber: SpreedlySecureOpaqueString?
    /// Default: .unknown
    @objc public var bankAccountType: BankAccountType = .unknown
    /// Default: .unknown
    @objc public var bankAccountHolderType: BankAccountHolderType = .unknown

    @objc public override init() {
        super.init()
    }

    /// Copies values from the given PaymentMethodInfo onto a new BankAccountInfo.
    public init(fromInfo info: PaymentMethodInfo?) {
        super.init(from: info)
    }

    /// Copies values from the given BankAccountInfo
    /// including `fullName`, `firstName`, `lastName`, `address`,
    /// `shippingAddress`, `company`, `email`, `metadata`,
    /// `bankAccountType`, and `bankAccountHolderType`.
    ///
    /// Account data is not copied.
    /// - Parameter info: The source of the values.
    public convenience init(fromBankAccount info: BankAccountInfo?) {
        self.init(fromInfo: info)

        bankAccountType = info?.bankAccountType ?? BankAccountType.unknown
        bankAccountHolderType = info?.bankAccountHolderType ?? BankAccountHolderType.unknown
    }

    override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        result.maybeSet("bank_routing_number", bankRoutingNumber)
        try result.setOpaqueString("bank_account_number", bankAccountNumber)
        result.maybeSet("bank_account_type", bankAccountType.stringValue)
        result.maybeSet("bank_account_holder_type", bankAccountHolderType.stringValue)

        return result
    }

    override func toRequestJson() throws -> [String: Any] {
        [
            "payment_method": [
                "email": email ?? "",
                "metadata": metadata ?? Metadata(),
                "bank_account": try self.toJson(),
                "retained": self.retained ?? false
            ]
        ]
    }
}
