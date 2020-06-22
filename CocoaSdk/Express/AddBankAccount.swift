//
//  AddBankAccount.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import CoreSdk

class AddBankAccountController: UIViewController {
    @IBOutlet weak var form: SPSecureForm!

    var didAddBankAccount: ((BankAccountResult) -> Void)?

    override func viewDidLoad() {
        configureDelegates()
    }

    func configureDelegates() {
        form.delegate = self
    }
}

extension AddBankAccountController: SPSecureFormDelegate {
    func spreedly<TResult>(
            secureForm form: SPSecureForm,
            success transaction: Transaction<TResult>
    ) where TResult: PaymentMethodResultBase {
        guard let bank = transaction.paymentMethod as? BankAccountResult else {
            return
        }
        self.didAddBankAccount?(bank)
        self.navigationController?.popViewController(animated: true)
    }

}
