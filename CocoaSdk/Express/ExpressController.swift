//
//  ExpressRootController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/18/20.
//

import UIKit
import CoreSdk
import PassKit

class ExpressController: UIViewController {
    @IBOutlet weak var paymentItems: UITableView!

    var items: [PaymentMethodItem]?
    var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        paymentItems.dataSource = self
    }

    @IBAction func done(_ sender: Any) {
        let indexPath = paymentItems.indexPathForSelectedRow
        guard let row = indexPath?.row,
              let selectedPaymentMethod = items?[row] else {
            return
        }

        didSelectPaymentMethod?(selectedPaymentMethod)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AddCardController {
            viewController.didAddCard = self.onCardAdded
        }
    }

    func onCardAdded(card: CreditCardResult) {
        let brand = CardBrand.from(spreedlyType: card.cardType ?? "")
        self.items?.insert(PaymentMethodItem(
                type: .creditCard,
                description: "\(brand.rawValue.capitalized) \(card.lastFourDigits ?? "")",
                token: card.token ?? ""
        ), at: 0)
        self.paymentItems.reloadData()
        self.paymentItems.selectRow(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
    }
}

extension ExpressController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let text = items?[indexPath.row].description ?? "\(indexPath.row)"
        cell.textLabel?.text = text
        return cell
    }
}

public class PaymentMethodItem {
    public let type: PaymentMethodType
    public let description: String
    public let token: String

    public init(type: PaymentMethodType, description: String, token: String) {
        self.type = type
        self.description = description
        self.token = token
    }
}

class PaymentMethodTable: UITableView {

}
