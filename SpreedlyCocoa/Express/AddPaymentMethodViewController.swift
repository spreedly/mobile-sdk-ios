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
    @IBOutlet weak var form: SecureForm!
    @IBOutlet weak var submit: UIButton!

    lazy var spinnerViewController = SpinnerViewController()

    var didAddPaymentMethod: ((PaymentMethodResultBase) -> Void)?

    var context: ExpressContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDelegates()
        configureSubmit()
        configureDefaults()
    }

    func configureDelegates() {
        form.delegate = self
    }

    func configureSubmit() {
        let image = UIImage.initPre13(systemName: "lock.fill", fallbackEmoji: "🔒")
        submit.setImage(image, for: .normal)
    }

    func configureDefaults() {
        form.paymentMethodDefaults = context?.paymentMethodDefaults
        form.creditCardDefaults = context?.creditCardDefaults
        form.bankAccountDefaults = context?.bankAccountDefaults
    }
}

extension AddPaymentMethodViewController: SecureFormDelegate {
    func spreedly(
            secureForm form: SecureForm,
            success transaction: Transaction
    ) {
        guard let paymentMethod = transaction.paymentMethod else {
            return
        }
        self.didAddPaymentMethod?(paymentMethod)
    }

    public func willCallSpreedly(secureForm: SecureForm) {
        spinnerViewController.overlaySpinner(on: self)
    }

    public func didCallSpreedly(secureForm: SecureForm) {
        spinnerViewController.removeSpinner()
    }

    public func clientConfiguration(secureForm: SecureForm) -> ClientConfiguration? {
        context?.clientConfiguration
    }
}
