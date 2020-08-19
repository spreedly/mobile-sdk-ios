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
    @objc public var routingNumber: String?
    @objc public var accountNumber: SpreedlySecureOpaqueString?
    /// Default: .unknown
    @objc public var accountType: BankAccountType = .unknown
    /// Default: .unknown
    @objc public var accountHolderType: BankAccountHolderType = .unknown

    @objc public override init() {
        super.init()
    }

    /// Copies values from the given BankAccountInfo or PaymentMethodInfo onto a new BankAccountInfo.
    /// including `fullName`, `firstName`, `lastName`, `address`,
    /// `shippingAddress`, `company`, `email`, `metadata`,
    /// `bankAccountType`, and `bankAccountHolderType`.
    ///
    /// Account data is not copied.
    /// - Parameter info: The source of the values.
    public override init(copyFrom info: PaymentMethodInfo?) {
        super.init(copyFrom: info)
        if let ba = info as? BankAccountInfo {
            accountType = ba.accountType ?? BankAccountType.unknown
            accountHolderType = ba.accountHolderType ?? BankAccountHolderType.unknown
        }
    }

    override func toJson() throws -> [String: Any] {
        var result = try super.toJson()

        result.maybeSet("bank_routing_number", routingNumber)
        try result.setOpaqueString("bank_account_number", accountNumber)
        result.maybeSet("bank_account_type", accountType.stringValue)
        result.maybeSet("bank_account_holder_type", accountHolderType.stringValue)

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
