//
//  Spreedly.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import PassKit
import Spreedly

/// ExpressBuilder is the entrypoint for the Express UI workflow. Create an instance of this class, optionally set
/// properties to configure Express UI behavior, and finally call `buildViewController()` to get a `UIViewController`
/// ready to show.
///
/// ### Example
/// ```swift
/// var builder = ExpressBuilder()
/// builder.didSelectPaymentMethod = { item in
///     print("User wants to use a payment method with token: \(item.token)")
/// }
/// let controller = builder.buildViewController()
/// navigationController?.show(controller, sender: self)
/// ```
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

    /// A ClientConfiguration contains the environment key necessary to create payment methods with Spreedly.
    /// This can be set explicitly. If it is not, the Express system will look for a `Spreedly-env.plist` file
    /// in the main bundle for the environment key value under `ENV_KEY`.
    @objc public var clientConfiguration: ClientConfiguration?

    /// Default: true. Allow the user to add new card payment methods.
    @objc public var allowCard: Bool = true

    /// Default: false. Allow the user to add new bank account payment methods.
    @objc public var allowBankAccount: Bool = false

    /// Default: true. Allow users to select the Apple Pay payment method. When true, the `paymentRequest` property
    /// must also be set.
    @objc public var allowApplePay: Bool = true

    /// A list of payment methods available for the user to select. Set if providing
    /// any previously stored payment methods.
    @objc public var paymentMethods: [PaymentMethodItem]?

    /// Called after the user selects a payment method. When called, the controller returned from
    /// `buildViewController` should be popped/dismissed.
    @objc public var didSelectPaymentMethod: ((SelectedPaymentMethod) -> Void)?

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

    /// Set this to provide a name, company, email, address, shipping address, and metadata information to Spreedly
    /// when the payment method is created. When this property is set, `defaultPaymentMethodInfo` will be ignored.
    @objc public var defaultApplePayInfo: PaymentMethodInfo?

    /// Required when offering Apple Pay. Provides values to the Apple Pay dialog.
    ///
    /// ### Example
    /// ```swift
    /// let request = PKPaymentRequest()
    /// request.merchantIdentifier = "merchant.com.your_company.app"
    /// request.countryCode = "US"
    /// request.currencyCode = "USD"
    /// request.supportedNetworks = [.amex, .discover, .masterCard, .visa]
    /// request.merchantCapabilities = [.capabilityCredit, .capabilityDebit]
    /// request.paymentSummaryItems = [
    ///     PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(string: "322.38"), type: .final),
    ///     PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "32.24"), type: .final),
    ///     PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "354.62"), type: .final)
    /// ]
    ///
    /// let builder = ExpressBuilder()
    /// builder.paymentRequest = request
    /// ```
    @objc public var paymentRequest: PKPaymentRequest?

    /// Default: `.withinNavigationView`. When showing the Express UI within an existing `UINavigationController`,
    /// set this to `.withinNavigationView`. When it is meant to appear separately, such as within a modal,
    /// set this to `.asModal` so it will provide its own `UINavigationController`.
    @objc public var presentationStyle: PresentationStyle = .withinNavigationView

    /// Appears at the top of the payment selection screen. Also set `paymentSelectionHeaderHeight` when
    /// using this property.
    @objc public var paymentSelectionHeader: UIView?

    /// Default: zero. Set this to more than zero when using the `paymentSelectionHeader`.
    @objc public var paymentSelectionHeaderHeight: CGFloat = 0

    /// Appears after all other controls on the payment selection screen. Also set `paymentSelectionFooterHeight` when
    /// using this property.
    @objc public var paymentSelectionFooter: UIView?

    /// Default: zero. Set this to more than zero when using the `paymentSelectionFooter`.
    @objc public var paymentSelectionFooterHeight: CGFloat = 0

    /// Returns a `UIViewController` for the Express UI workflow configured with the properties from this object.
    public func buildViewController() -> UIViewController {
        guard let storyboard = UIStoryboard.fromResources(named: "Express") else {
            fatalError("Unable to find Express storyboard in searched bundles.")
        }
        let initial: UIViewController
        let express: ExpressViewController

        switch presentationStyle {
        case .withinNavigationView:
            express = storyboard.instantiateViewController(withIdentifier: "PaymentSelection") as! ExpressViewController // swiftlint:disable:this force_cast line_length
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
        context.clientConfiguration = clientConfiguration

        context.allowCard = allowCard
        context.allowBankAccount = allowBankAccount
        context.allowApplePay = allowApplePay

        context.paymentMethods = getPaymentMethods()

        context.didSelectPaymentMethod = didSelectPaymentMethod

        context.paymentMethodDefaults = defaultPaymentMethodInfo
        context.creditCardDefaults = CreditCardInfo(fromCard: defaultCreditCardInfo)
        context.bankAccountDefaults = BankAccountInfo(fromBankAccount: defaultBankAccountInfo)
        context.applePayDefaults = defaultApplePayInfo

        context.paymentRequest = paymentRequest

        context.paymentSelectionHeader = paymentSelectionHeader
        context.paymentSelectionHeaderHeight = paymentSelectionHeaderHeight
        context.paymentSelectionFooter = paymentSelectionFooter
        context.paymentSelectionFooterHeight = paymentSelectionFooterHeight

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
    @objc public var clientConfiguration: ClientConfiguration?

    @objc public var paymentMethods: [PaymentMethodItem]?

    @objc public var allowCard = true
    @objc public var allowBankAccount = false
    @objc public var allowApplePay = true

    @objc public var didSelectPaymentMethod: ((SelectedPaymentMethod) -> Void)?

    @objc public var paymentMethodDefaults: PaymentMethodInfo?
    @objc public var creditCardDefaults: CreditCardInfo?
    @objc public var bankAccountDefaults: BankAccountInfo?
    @objc public var applePayDefaults: PaymentMethodInfo?

    @objc public var paymentRequest: PKPaymentRequest?

    @objc public var paymentSelectionHeader: UIView?
    @objc public var paymentSelectionHeaderHeight: CGFloat = 0

    @objc public var paymentSelectionFooter: UIView?
    @objc public var paymentSelectionFooterHeight: CGFloat = 0

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

    @objc public var fullNameApplePay: String? {
        applePayDefaults?.fullName ?? fullName(from: applePayDefaults) ?? fullNamePaymentMethod
    }
}
