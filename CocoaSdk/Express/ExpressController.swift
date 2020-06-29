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

//    @IBAction func done(_ sender: Any) {
//        guard let row = collectionView.indexPathsForSelectedItems?
//        guard let row = paymentItems.indexPathForSelectedRow?.row,
//              let selectedPaymentMethod = items?[row] else {
//            return
//        }
//
//        didSelectPaymentMethod?(selectedPaymentMethod)
//    }

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
    @objc(type) public var _objCType: _ObjCPaymentMethodType {  // swiftlint:disable:this identifier_name
        _ObjCPaymentMethodType.from(type)
    }
}

class PaymentMethodCell: UICollectionViewCell {
    let padding: CGFloat = 8.0

    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = .white
        container.layer.cornerRadius = 15
        return container
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func addShadow(view: UIView) {
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    }

    func setup() {
        layer.backgroundColor = UIColor.clear.cgColor
        addShadow(view: contentView)

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])

        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        container.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            textLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        fatalError("not supported")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.textLabel.text = nil
        self.imageView.image = nil
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
