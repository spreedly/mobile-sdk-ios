//
//  ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 5/20/20.
//
//

import UIKit
import CoreSdk
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
