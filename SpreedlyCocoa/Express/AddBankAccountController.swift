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

        stackView.addBackground(color: UIColor.tertiarySystemBackgroundPre13)
        stackView.subviews.filter {
            $0 is UITextField
        }.dropFirst().forEach { view in
            view.layer.addBorder(edge: .top, color: UIColor.separatorPre13, thickness: 1)
        }
    }

    override func configureDefaults() {
        super.configureDefaults()

        form.fullName?.text = context?.fullNameBankAccount
        form.selectedAccountType = context?.bankAccountDefaults?.accountType ?? .checking
        form.selectedHolderType = context?.bankAccountDefaults?.accountHolderType ?? .personal
    }
}
