//
//  ExpressRootController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/18/20.
//

import UIKit
import CoreSdk
import PassKit

class ExpressRootController: UIViewController {
    @IBOutlet weak var paymentItems: UITableView!

    var items: [PaymentMethodItem]?

    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            PaymentMethodItem(type: .creditCard, description: "Visa 1111", token: "abc123"),
            PaymentMethodItem(type: .creditCard, description: "MC 5454", token: "abc456")
        ]
        if applePayEnabled {
            items?.append(PaymentMethodItem(type: .applePay, description: "Apple Pay", token: "abc789"))
        }

        paymentItems.dataSource = self
    }

    var applePayEnabled: Bool {
        PKPaymentAuthorizationViewController.canMakePayments()
                && PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: [
                    .visa,
                    .masterCard,
                    .discover,
                    .amex
                ]
        )
    }
}

extension ExpressRootController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Items count: \(items?.count ?? 0)")
        return items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let text = items?[indexPath.row].description ?? "\(indexPath.row)"
        cell.textLabel?.text = text
        print("Row: \(indexPath.row), Text: \(text)")
        return cell
    }
}

public class PaymentMethodItem {
    var type: PaymentMethodType
    var description: String
    var token: String

    init(type: PaymentMethodType, description: String, token: String) {
        self.type = type
        self.description = description
        self.token = token
    }
}

class PaymentMethodTable: UITableView {

}
