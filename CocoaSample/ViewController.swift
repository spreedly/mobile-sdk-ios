//
//  ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 5/20/20.
//
//

import UIKit
import Spreedly
import SpreedlyCocoa

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func launchExpress(_ sender: Any) {
        let builder = Spreedly.expressBuilder()
        builder.allowBankAccount = true
        builder.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "Visa 1111", token: "abc456"),
            PaymentMethodItem(type: .creditCard, description: "Mastercard 1111", token: "abc456"),
            PaymentMethodItem(type: .creditCard, description: "Amex 1111", token: "abc456")
        ]
        builder.didSelectPaymentMethod = { item in
            print("Payment method selected: \(item.shortDescription)")
            self.navigationController?.popToViewController(self, animated: true)
        }

        builder.paymentSelectionHeaderHeight = 100
        builder.paymentSelectionHeader = {
            let label = UILabel(frame: .zero)
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            label.textAlignment = .center
            label.text = "🎶 Sousa's Phones 📱"
            return label
        }()

        builder.paymentSelectionFooterHeight = 100
        builder.paymentSelectionFooter = {
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
        }()

        let viewController = builder.buildViewController()
        navigationController?.show(viewController, sender: self)
    }

    @IBAction func expressWithPresent(_ sender: Any) {
        let builder = Spreedly.expressBuilder()
        builder.allowBankAccount = true
        builder.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "MC 4444", token: "abc456")
        ]
        builder.didSelectPaymentMethod = { item in
            print("Payment method selected: \(item.shortDescription)")
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
            info.bankAccountHolderType = .business
            info.bankAccountType = .savings
            return info
        }()
        builder.presentationStyle = .asModal

        let viewController = builder.buildViewController()
        present(viewController, animated: true)
    }
}
