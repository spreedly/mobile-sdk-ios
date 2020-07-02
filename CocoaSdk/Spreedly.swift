//
//  Spreedly.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import PassKit
import CoreSdk

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

    /// Set this to provide a full name on the payment method creation forms and to provide
    /// name, company, email, address, shipping address, and metadata information to Spreedly
    /// when a payment method is created. Values in this property will be used when creating a credit card
    /// or bank account payment method.
    @objc public var defaultPaymentMethodInfo: PaymentMethodInfo?

    /// Set this to provide a full name on the form and to provide
    /// name, company, email, address, shipping address, and metadata information to Spreedly when the payment method
    /// is created. When this property is set, `defaultPaymentMethodInfo` will be ignored.
    @objc public var defaultCreditCardInfo: CreditCardInfo?

    /// Set this to provide a full name, bank account type, and bank account holder type on the form and to provide
    /// name, company, email, address, shipping address, and metadata information to Spreedly when the payment method
    /// is created. When this property is set, `defaultPaymentMethodInfo` will be ignored.
    @objc public var defaultBankAccountInfo: BankAccountInfo?

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
        context.paymentMethodDefaults = defaultPaymentMethodInfo
        context.creditCardDefaults = CreditCardInfo(fromCard: defaultCreditCardInfo)
        context.bankAccountDefaults = BankAccountInfo(fromBankAccount: defaultBankAccountInfo)
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
    @objc public var paymentMethodDefaults: PaymentMethodInfo?
    @objc public var creditCardDefaults: CreditCardInfo?
    @objc public var bankAccountDefaults: BankAccountInfo?

    private func fullName(from info: PaymentMethodInfo?) -> String? {
        guard let first = info?.firstName,
              let last = info?.lastName else {
            return nil
        }
        return "\(first) \(last)"
    }

    @objc public var fullNamePaymentMethod: String? {
        paymentMethodDefaults?.fullName ?? fullName(from: paymentMethodDefaults)
    }

    @objc public var fullNameCreditCard: String? {
        creditCardDefaults?.fullName ?? fullName(from: creditCardDefaults) ?? fullNamePaymentMethod
    }

    @objc public var fullNameBankAccount: String? {
        bankAccountDefaults?.fullName ?? fullName(from: bankAccountDefaults) ?? fullNamePaymentMethod
    }
}
