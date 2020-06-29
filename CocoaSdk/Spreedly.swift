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
    public static func express(context: ExpressContext, present: Bool = false) -> UIViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "Express", bundle: bundle)
        let view: UIViewController
        let express: ExpressController
        if present {
            let navController = storyboard.instantiateViewController(
                    withIdentifier: "NavigationController"
            ) as! UINavigationController // swiftlint:disable:this force_cast
            express = navController.visibleViewController as! ExpressController // swiftlint:disable:this force_cast
            view = navController
        } else {
            express = storyboard.instantiateInitialViewController()! as ExpressController
            view = express
        }
        express.context = context
        return view
    }
}

@objc(SPRExpressContext)
public class ExpressContext: NSObject {
    @objc public var paymentMethods: [PaymentMethodItem]?
    @objc public var allowCard = true
    @objc public var allowBankAccount = false
    @objc public var allowApplePay = true
    @objc public var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)?

    func getPaymentMethods() -> [PaymentMethodItem] {
        var items = paymentMethods ?? []
        if allowApplePay {
            items.append(PaymentMethodItem(type: .applePay, description: "Apple Pay", token: "abc789"))
        }
        return items
    }
}
