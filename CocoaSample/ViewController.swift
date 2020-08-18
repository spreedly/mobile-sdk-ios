//
//  ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 5/20/20.
//
//

import PassKit
import UIKit
import Spreedly
import SpreedlyCocoa

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func launchExpress(_ sender: Any) {
        let builder = ExpressBuilder()
        builder.allowBankAccount = true
        builder.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "Visa 1111", token: "abc456"),
            PaymentMethodItem(type: .creditCard, description: "Mastercard 1111", token: "abc456"),
            PaymentMethodItem(type: .creditCard, description: "Amex 1111", token: "abc456")
        ]
        builder.didSelectPaymentMethod = { item in
            print("Payment method selected token: \(item.token)")
            self.navigationController?.popToViewController(self, animated: true)
        }

        builder.paymentSelectionHeaderHeight = 100
        builder.paymentSelectionHeader = buildHeader()

        builder.paymentSelectionFooterHeight = 100
        builder.paymentSelectionFooter = buildFooter()

        builder.paymentRequest = buildPaymentRequest()

        let viewController = builder.buildViewController()
        navigationController?.show(viewController, sender: self)
    }

    private func buildHeader() -> UIView {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.text = "🎶 Sousa's Phones 📱"
        return label
    }

    private func buildFooter() -> UIView {
        let container = UIView(frame: .zero)

        let price = UILabel(frame: .zero)
        price.font = UIFont.preferredFont(forTextStyle: .title1)
        price.textColor = .systemBlue
        price.textAlignment = .center
        price.text = "$354.62"

        let description = UILabel(frame: .zero)
        description.font = UIFont.preferredFont(forTextStyle: .body)
        description.textAlignment = .center
        description.numberOfLines = 2
        description.text = [
            "Sax oPhone SE (2020)",
            "128GB, Polished Brass"
        ].joined(separator: "\n")

        container.addSubview(price)
        price.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            price.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            price.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            price.topAnchor.constraint(equalTo: container.topAnchor),
            price.heightAnchor.constraint(equalToConstant: 50)
        ])

        container.addSubview(description)
        description.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            description.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            description.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            description.topAnchor.constraint(equalTo: price.bottomAnchor),
            description.heightAnchor.constraint(equalToConstant: 50)
        ])

        return container
    }

    private func buildPaymentRequest() -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.ergonlabs.sample"
        request.merchantCapabilities = [
            .capabilityCredit,
            .capabilityDebit,
            .capability3DS
        ]
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.supportedNetworks = [
            .amex,
            .discover,
            .masterCard,
            .maestro,
            .elo,
            .cartesBancaires,
            .chinaUnionPay,
            .electron,
            .JCB,
            .visa
        ]

        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(string: "322.38"), type: .final),
            PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "32.24"), type: .final),
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "354.62"), type: .final)
        ]
        return request
    }

    @IBAction func expressWithPresent(_ sender: Any) {
        let builder = ExpressBuilder()
        builder.allowBankAccount = true
        builder.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "MC 4444", token: "abc456")
        ]
        builder.didSelectPaymentMethod = { item in
            print("Payment method selected token: \(item.token)")
            self.dismiss(animated: true)
        }
        builder.defaultCreditCardInfo = {
            let info = CreditCardInfo()
            info.fullName = "Full Name"
            return info
        }()
        builder.defaultBankAccountInfo = {
            let info = BankAccountInfo()
            info.firstName = "Firstname"
            info.lastName = "Lastname"
            info.accountHolderType = .business
            info.accountType = .savings
            return info
        }()
        builder.defaultApplePayInfo = {
            let info = PaymentMethodInfo()
            info.fullName = "Applepay Customer"
            info.address.address1 = "1 Infinite Loop"
            info.address.city = "Cupertino"
            info.address.state = "CA"
            info.address.zip = "95014"
            info.address.country = "US"
            info.address.phoneNumber = "8002752273"
            return info
        }()
        builder.presentationStyle = .asModal

        builder.paymentRequest = buildPaymentRequest()

        let viewController = builder.buildViewController()
        present(viewController, animated: true)
    }
}
