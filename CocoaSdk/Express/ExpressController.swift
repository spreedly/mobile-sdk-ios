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
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        let textLabel = UILabel(frame: .zero)
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(textLabel)
//        NSLayoutConstraint.activate([
//            textLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            textLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
//        ])
//        self.textLabel = textLabel
//
//        self.contentView.backgroundColor = .lightGray
//        self.textLabel.textAlignment = .center
//    }

//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//
//        fatalError("not supported")
//    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.textLabel.text = nil
        self.imageView.image = nil
    }
}

extension ExpressController: UICollectionViewDataSource {
    func collectionViewDidLoad() {
        self.collectionView.backgroundColor = .white
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? 0
    }

    func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let protoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "pm2", for: indexPath)
        guard let cell = protoCell as? PaymentMethodCell,
              let item = items?[indexPath.row] else {
            return protoCell
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

struct ExpressController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
