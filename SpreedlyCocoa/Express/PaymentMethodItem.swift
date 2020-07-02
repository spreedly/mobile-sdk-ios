//
// Created by Eli Thompson on 6/29/20.
//

import Foundation
import Spreedly

@objc(SPRPaymentMethodItem)
public class PaymentMethodItem: NSObject {
    public let type: PaymentMethodType
    @objc public let shortDescription: String
    @objc public let token: String

    var imageName: String {
        switch type {
        case .bankAccount:
            return "spr_icon_bank"
        case .applePay:
            return "spr_card_applepay"
        default:
            return "spr_card_unknown"
        }
    }

    public init(type: PaymentMethodType, description: String, token: String) {
        self.type = type
        self.shortDescription = description
        self.token = token
    }
}

extension PaymentMethodItem {
    @objc(type) public var _objCType: _ObjCPaymentMethodType {  // swiftlint:disable:this identifier_name
        _ObjCPaymentMethodType.from(type)
    }
}
