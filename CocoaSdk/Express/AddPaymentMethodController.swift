//
//  AddPaymentMethodController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import CoreSdk

class AddPaymentMethodController: UIViewController {
    @IBOutlet weak var form: SPSecureForm!

    var didAddPaymentMethod: ((PaymentMethodResultBase) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDelegates()
    }

    func configureDelegates() {
        form.delegate = self
    }
}

extension AddPaymentMethodController: SPSecureFormDelegate {
    func spreedly<TResult>(
            secureForm form: SPSecureForm,
            success transaction: Transaction<TResult>
    ) where TResult: PaymentMethodResultBase {
        guard let paymentMethod = transaction.paymentMethod else {
            return
        }
        self.didAddPaymentMethod?(paymentMethod)
        self.navigationController?.popViewController(animated: true)
    }

}
