//
//  Spreedly.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import PassKit

public class Spreedly: NSObject {
    public static func express(context: ExpressContext) -> UIViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "Express", bundle: bundle)
        let view = storyboard.instantiateInitialViewController()! as ExpressController
        view.items = context.getPaymentMethods()
        view.didSelectPaymentMethod = context.didSelectPaymentMethod

        return view
    }
}

public class ExpressContext: NSObject {
    public var paymentMethods: [PaymentMethodItem]?
    public var allowApplePay = true
    public var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)?

    var applePayEnabled: Bool {
        PKPaymentAuthorizationViewController.canMakePayments()
                && PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: [
                    .visa,
                    .masterCard,
                    .discover,
                    .amex
                ]
        )
    }

    func getPaymentMethods() -> [PaymentMethodItem] {
        var items = paymentMethods ?? []
        if allowApplePay {
            items.append(PaymentMethodItem(type: .applePay, description: "Apple Pay", token: "abc789"))
        }
        return items
    }
}
