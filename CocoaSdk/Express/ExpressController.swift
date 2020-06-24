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

    var context: ExpressContext?
    var items: [PaymentMethodItem]? {
        context?.getPaymentMethods()
    }
    var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)? {
        context?.didSelectPaymentMethod
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        paymentItems.dataSource = self
    }

    @IBAction func done(_ sender: Any) {
        guard let row = paymentItems.indexPathForSelectedRow?.row,
              let selectedPaymentMethod = items?[row] else {
            return
        }

        didSelectPaymentMethod?(selectedPaymentMethod)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let viewController = segue.destination as? AddPaymentMethodController {
            viewController.didAddPaymentMethod = self.onPaymentMethodAdded
            return
        }
    }

    func onPaymentMethodAdded(method: PaymentMethodResultBase) {
        guard let type = method.paymentMethodType else {
            return
        }
        let item = PaymentMethodItem(
                type: type,
                description: method.shortDescription,
                token: method.token ?? ""
        )
        didSelectPaymentMethod?(item)
    }
}

extension ExpressController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.shortDescription
            cell.imageView?.image = UIImage(named: item.imageName)
        }
        return cell
    }
}

@objc(SPRPaymentMethodItem)
public class PaymentMethodItem: NSObject {
    public let type: PaymentMethodType
    @objc public let shortDescription: String
    @objc public let token: String

    var imageName: String {
        switch type {
        case .bankAccount:
            return "spr_icon_bank"
        case .applePay:
            return "spr_card_applepay"
        default:
            return "spr_card_unknown"
        }
    }

    public init(type: PaymentMethodType, description: String, token: String) {
        self.type = type
        self.shortDescription = description
        self.token = token
    }
}

extension PaymentMethodItem {
    @objc(type) public var _objCType: _ObjCPaymentMethodType { // swiftlint:disable:this identifier_name
        _ObjCPaymentMethodType.from(type)
    }
}
