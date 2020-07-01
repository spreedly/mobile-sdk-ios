//
//  Spreedly.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import PassKit

@objc(SPRSpreedly)
public class Spreedly: NSObject {
    @objc public static func expressBuilder() -> ExpressBuilder {
        ExpressBuilder()
    }
}

@objc(SPRExpressBuilder)
public class ExpressBuilder: NSObject {
    @objc(SPRPresentationStyle)
    public enum PresentationStyle: Int {
        /// Use this if the ExpressController will be part of an existing UINavigationController.
        case withinNavigationView = 0
        /// Use this if the ExpressController will be shown own its own. The returned controller will be a
        /// UINavigationController wrapping the ExpressController.
        case asModal
    }

    @objc public var allowCard = true
    @objc public var allowBankAccount = false
    @objc public var allowApplePay = true
    @objc public var paymentMethods: [PaymentMethodItem]?
    @objc public var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)?

    @objc public var presentationStyle: PresentationStyle = .withinNavigationView

    public func buildViewController() -> UIViewController {
        let bundle = Bundle(for: type(of: self))
        let storyboard = UIStoryboard(name: "Express", bundle: bundle)
        let initial: UIViewController
        let express: ExpressViewController

        switch presentationStyle {
        case .withinNavigationView:
            express = storyboard.instantiateInitialViewController()! as ExpressViewController
            initial = express
        case .asModal:
            let navController = storyboard.instantiateViewController(
                    withIdentifier: "Navigation"
            ) as! UINavigationController // swiftlint:disable:this force_cast
            express = navController.visibleViewController as! ExpressViewController // swiftlint:disable:this force_cast
            initial = navController
        }

        express.context = buildContext()
        return initial
    }

    func buildContext() -> ExpressContext {
        let context = ExpressContext()
        context.allowCard = allowCard
        context.allowBankAccount = allowBankAccount
        context.allowApplePay = allowApplePay
        context.paymentMethods = getPaymentMethods()
        context.didSelectPaymentMethod = didSelectPaymentMethod
        return context
    }

    func getPaymentMethods() -> [PaymentMethodItem] {
        var items = paymentMethods ?? []
        if allowApplePay {
            items.append(PaymentMethodItem(type: .applePay, description: "Apple Pay", token: "abc789"))
        }
        return items
    }
}

@objc(SPRExpressContext)
public class ExpressContext: NSObject {
    @objc public var paymentMethods: [PaymentMethodItem]?
    @objc public var allowCard = true
    @objc public var allowBankAccount = false
    @objc public var allowApplePay = true
    @objc public var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)?
}
