//
//  AddPaymentMethodController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/22/20.
//

import Foundation
import UIKit
import CoreSdk

class AddPaymentMethodViewController: UIViewController {
    @IBOutlet weak var form: SPSecureForm!

    lazy var spinnerViewController = SpinnerViewController()

    var didAddPaymentMethod: ((PaymentMethodResultBase) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDelegates()
    }

    func configureDelegates() {
        form.delegate = self
    }
}

extension AddPaymentMethodViewController: SPSecureFormDelegate {
    func spreedly<TResult>(
            secureForm form: SPSecureForm,
            success transaction: Transaction<TResult>
    ) where TResult: PaymentMethodResultBase {
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
