//
//  ViewController.swift
//  CocoaSample
//
//  Created by Stefan Rusek on 5/20/20.
//
//

import UIKit
import CocoaSdk

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
        let view = builder.buildViewController()
        navigationController?.show(view, sender: self)
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
        builder.presentationStyle = .asModal
        let view = builder.buildViewController()
        present(view, animated: true)
    }
}
