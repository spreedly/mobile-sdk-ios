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

        hideDisallowedMethods()
        collectionViewDidLoad()
        styleNavButtons()
    }

    func styleNavButtons() {
        styleNavButton(button: addCard)

        if context.allowCard && context.allowBankAccount {
            // if both buttons appear on the screen, add a border between them
            addCard.layer.addBorder(edge: .bottom, color: .systemGray2, thickness: 1)
        }

        styleNavButton(button: addBankAccount)
    }

    func styleNavButton(button: UIButton) {
        button.contentHorizontalAlignment = .leading

        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        button.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.trailingAnchor.constraint(equalTo: button.trailingAnchor)
        ])
    }

    func hideDisallowedMethods() {
        if !context.allowCard {
            addCard.isHidden = true
        }
        if !context.allowBankAccount {
            addBankAccount.isHidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let viewController = segue.destination as? AddPaymentMethodController {
            viewController.didAddPaymentMethod = onPaymentMethodAdded
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

extension ExpressController: UICollectionViewDataSource {
    func collectionViewDidLoad() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(PaymentMethodCell.self, forCellWithReuseIdentifier: "PaymentMethod")
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

