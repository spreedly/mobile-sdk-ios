//
//  ExpressRootController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/18/20.
//

import UIKit
import Spreedly
import PassKit

class ExpressViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addCard: UIButton!
    @IBOutlet weak var addBankAccount: UIButton!
    
    private var handler: ApplePayHandler?

    var context = ExpressContext()
    var items: [PaymentMethodItem]? {
        context.paymentMethods
    }
    var didSelectPaymentMethod: ((PaymentMethodItem) -> Void)? {
        context.didSelectPaymentMethod
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hideDisallowedMethods()
        collectionViewDidLoad()
        styleNavButtons()
        insertArrangedSubview(
                view: context.paymentSelectionHeader,
                height: context.paymentSelectionHeaderHeight,
                at: 0
        )
        insertArrangedSubview(
                view: context.paymentSelectionFooter,
                height: context.paymentSelectionFooterHeight,
                at: stackView.arrangedSubviews.count
        )
    }

    func styleNavButtons() {
        styleNavButton(button: addCard)

        if context.allowCard && context.allowBankAccount {
            // if both buttons appear on the screen, add a border between them
            addCard.layer.addBorder(edge: .bottom, color: .separator, thickness: 1)
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

        if let viewController = segue.destination as? AddPaymentMethodViewController {
            viewController.didAddPaymentMethod = onPaymentMethodAdded
            viewController.context = context
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

    func insertArrangedSubview(view: UIView?, height: CGFloat, at index: Int) {
        guard let view = view,
              height > 0 else {
            return
        }

        stackView.insertArrangedSubview(view, at: index)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}

extension ExpressViewController: UICollectionViewDataSource {
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

extension ExpressViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items?[indexPath.item] else {
            return
        }
        if item.type == .applePay {
            startApplePay()
            return
        }

        didSelectPaymentMethod?(item)
    }
}

/* MARK: - Apple Pay */
extension ExpressViewController {
    func startApplePay() {
        let credentials: ClientConfiguration
        do {
            credentials = try ClientConfiguration.getConfiguration()
        } catch {
            fatalError("\(error)")
        }

        let client = ClientFactory.create(with: credentials)
        handler = ApplePayHandler(client: client)

        guard let request = context.paymentRequest else {
            fatalError("A PKPaymentRequest must be set on the ExpressBuilder object to initiate the Apple Pay workflow")
        }

        handler?.startPayment(request: request) { success, transaction in
            if success {
                print("Apple Pay success!")
                let item = PaymentMethodItem(
                        type: .applePay,
                        description: "Apple Pay",
                        token: transaction?.paymentMethod?.token ?? ""
                )
                self.didSelectPaymentMethod?(item)
            } else {
                print("Apple Pay failed :(")
            }
        }
    }
}
