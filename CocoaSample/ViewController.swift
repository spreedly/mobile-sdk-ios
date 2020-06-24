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
        let context = ExpressContext()
        context.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "MC 4444", token: "abc456")
        ]
        context.didSelectPaymentMethod = { item in
            print("Payment method selected: \(item.description)")
            self.navigationController?.popToViewController(self, animated: true)
        }
        let view = Spreedly.express(context: context)
        navigationController?.show(view, sender: self)
    }

    @IBAction func expressWithPresent(_ sender: Any) {
        let context = ExpressContext()
        context.paymentMethods = [
            PaymentMethodItem(type: .creditCard, description: "MC 4444", token: "abc456")
        ]
        context.didSelectPaymentMethod = { item in
            print("Payment method selected: \(item.description)")
            self.dismiss(animated: true)
        }
        let view = Spreedly.express(context: context, present: true)
        present(view, animated: true)
    }
}
