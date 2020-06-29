//
//  ExpressRootController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/18/20.
//

import UIKit
import CoreSdk
import PassKit
import SwiftUI

class ExpressController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addCard: UIButton!
    @IBOutlet weak var addBankAccount: UIButton!

    var context = ExpressContext()
    var items: [PaymentMethodItem]? {
        context.getPaymentMethods()
    }
    var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)? {
        context.didSelectPaymentMethod
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !context.allowCard {
            addCard.isHidden = true
        }
        if !context.allowBankAccount {
            addBankAccount.isHidden = true
        }

        collectionViewDidLoad()
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

extension ExpressController: UICollectionViewDataSource {
    func collectionViewDidLoad() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.register(PaymentMethodCell.self, forCellWithReuseIdentifier: "PaymentMethod")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? 0
    }

    func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let protoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentMethod", for: indexPath)
        guard let cell = protoCell as? PaymentMethodCell,
              let item = items?[indexPath.row] else {
            fatalError("couldn't find the cell")
        }

        cell.imageView.image = UIImage(named: item.imageName)
        cell.textLabel.text = item.shortDescription
        return cell
    }
}

extension ExpressController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items?[indexPath.item] else {
            return
        }
        didSelectPaymentMethod?(item)
    }
}
