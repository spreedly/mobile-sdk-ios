//
//  AddBankAccountController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/23/20.
//

import UIKit
import Spreedly

class AddBankAccountController: AddPaymentMethodViewController {
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addBackground(color: .tertiarySystemBackground)
        stackView.subviews.filter { $0 is UITextField }.dropFirst().forEach { view in
            view.layer.addBorder(edge: .top, color: .separator, thickness: 1)
        }

        configureDefaults()
    }

    func configureDefaults() {
        form.fullName?.text = context?.fullNameBankAccount
        form.selectedAccountType = context?.bankAccountDefaults?.bankAccountType ?? .checking
        form.selectedHolderType = context?.bankAccountDefaults?.bankAccountHolderType ?? .personal
    }
}
