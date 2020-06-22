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
            PaymentMethodItem(type: .creditCard, description: "MC 5454", token: "abc456")
        ]
        let view = Spreedly.express(context: context)
        self.navigationController?.pushViewController(view, animated: true)
    }
}
