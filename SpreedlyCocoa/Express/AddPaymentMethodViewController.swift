//
//  AddPaymentMethodController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import Spreedly

class AddPaymentMethodViewController: UIViewController {
    @IBOutlet weak var form: SPSecureForm!

    lazy var spinnerViewController = SpinnerViewController()

    var didAddPaymentMethod: ((PaymentMethodResultBase) -> Void)?

    var context: ExpressContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDelegates()

        form.paymentMethodDefaults = context?.paymentMethodDefaults
        form.creditCardDefaults = context?.creditCardDefaults
        form.bankAccountDefaults = context?.bankAccountDefaults
    }

    func configureDelegates() {
        form.delegate = self
    }
}

extension AddPaymentMethodViewController: SPSecureFormDelegate {
    func spreedly(
            secureForm form: SPSecureForm,
            success transaction: Transaction
    ) {
        guard let paymentMethod = transaction.paymentMethod else {
            return
        }
        self.didAddPaymentMethod?(paymentMethod)
    }

    public func willCallSpreedly(secureForm: SPSecureForm) {
        spinnerViewController.overlaySpinner(on: self)
    }

    public func didCallSpreedly(secureForm: SPSecureForm) {
        spinnerViewController.removeSpinner()
    }
}
