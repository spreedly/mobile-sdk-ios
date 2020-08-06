//
//  PaymentSelectionViewController.swift
//  SpreedlyCocoa
//

import UIKit
import Spreedly
import PassKit

class PaymentSelectionViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var addCard: UIButton!
    @IBOutlet weak var addBankAccount: UIButton!

    private var handler: ApplePayHandler?

    var context = ExpressContext()
    var items: [PaymentMethodItem]? {
        context.paymentMethods
    }
    var didSelectPaymentMethod: ((SelectedPaymentMethod) -> Void)? {
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
            addCard.layer.addBorder(edge: .bottom, color: UIColor.separatorPre13, thickness: 1)
        }

        styleNavButton(button: addBankAccount)
    }

    func styleNavButton(button: UIButton) {
        button.contentHorizontalAlignment = .leading

        let image = UIImage.initPre13(systemName: "chevron.right", fallbackEmoji: "〉")
        let imageView = UIImageView(image: image)
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

        let selected = SelectedPaymentMethod(token: method.token ?? "", type: type)
        selected.paymentMethod = method
        didSelectPaymentMethod?(selected)
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

extension PaymentSelectionViewController: UICollectionViewDataSource {
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

        cell.imageView.image = UIImage.fromResources(named: item.imageName)
        cell.textLabel.text = item.shortDescription
        return cell
    }
}

extension PaymentSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items?[indexPath.item] else {
            return
        }
        if item.type == .applePay {
            startApplePay()
            return
        }

        let paymentMethod = SelectedPaymentMethod(token: item.token, type: item.type)
        didSelectPaymentMethod?(paymentMethod)
    }
}

/* MARK: - Apple Pay */
extension PaymentSelectionViewController {
    func startApplePay() {
        guard let request = context.paymentRequest else {
            fatalError("A PKPaymentRequest must be set on the ExpressBuilder object to initiate the Apple Pay workflow")
        }

        let credentials: ClientConfiguration
        do {
            credentials = try ClientConfiguration.getConfiguration()
        } catch {
            fatalError("\(error)")
        }

        let client = ClientFactory.create(with: credentials)
        handler = ApplePayHandler(
                client: client,
                defaults: context.applePayDefaults ?? context.paymentMethodDefaults
        )
        handler?.startPayment(request: request) { success, transaction in
            if success {
                let selected = SelectedPaymentMethod(
                        token: transaction?.paymentMethod?.token ?? "",
                        type: .applePay
                )
                selected.paymentMethod = transaction?.paymentMethod
                self.didSelectPaymentMethod?(selected)
            }
        }
    }
}
