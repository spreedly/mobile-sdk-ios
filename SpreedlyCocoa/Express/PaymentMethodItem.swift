//
// Created by Eli Thompson on 6/29/20.
//

import Foundation
import Spreedly
import UIKit

/// Contains basic information about a payment method.
@objc(SPRPaymentMethodItem)
public class PaymentMethodItem: NSObject {
    public let type: PaymentMethodType

    /// A very short description of the payment method displayable to the customer.
    @objc public let shortDescription: String

    /// Spreedly's payment method token.
    @objc public let token: String

    public var cardBrand: CardBrand?

    @objc(cardBrand) var _cardBrand: String? {
        get {
            cardBrand?.rawValue
        }
        set(value) {
            cardBrand = CardBrand.from(spreedlyType: value)
        }
    }

    var imageName: String {
        switch type {
        case .bankAccount:
            return "spr_icon_bank"
        case .applePay:
            return "spr_card_applepay"
        case .creditCard:
            let resourceName = "spr_card_\(cardBrand ?? .unknown)"
            return UIImage.canLoadFromResources(named: resourceName) ? resourceName : "spr_card_unknown"
        default:
            return "spr_card_unknown"
        }
    }

    public init(type: PaymentMethodType, description: String, token: String) {
        self.type = type
        self.shortDescription = description
        self.token = token
    }

    public init(type: PaymentMethodType, cardBrand: CardBrand, description: String, token: String) {
        self.type = type
        self.cardBrand = cardBrand
        self.shortDescription = description
        self.token = token
    }
}

extension PaymentMethodItem {
    @objc(type) public var _objCType: _ObjCPaymentMethodType {  // swiftlint:disable:this identifier_name
        _ObjCPaymentMethodType.from(type)
    }
}
