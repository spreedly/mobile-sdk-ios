//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import SpreedlyCocoa
import Spreedly
import RxSwift

class BankAccountFormViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var form: SecureForm!
    @IBOutlet weak var fullName: ValidatedTextField!
    @IBOutlet weak var accountNumber: SPSecureTextField!
    @IBOutlet weak var routingNumber: ValidatedTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDelegates()
        setDefaults()
    }

    /// Set defaults here for values like name
    /// or address information.
    func setDefaults() {
        fullName.text = "Dolly Dog"

        let defaults = BankAccountInfo()
        let billing = Address()
        billing.address1 = "123 Bark St"
        billing.city = "Canine"
        billing.state = "WA"
        billing.zip = "98121"
        billing.country = "US"
        billing.phoneNumber = "206-555-2275"
        defaults.address = billing

        form.bankAccountDefaults = defaults
    }

    func configureDelegates() {
        form.delegate = self

        fullName.delegate = self
        accountNumber.delegate = self
        routingNumber.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder? {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

extension BankAccountFormViewController: SPSecureFormDelegate {
    func willCallSpreedly(secureForm: SecureForm) {
        // intentionally blank
    }

    func didCallSpreedly(secureForm: SecureForm) {
        // intentionally blank
    }

    func spreedly(
            secureForm form: SecureForm,
            success transaction: Transaction
    ) {
        let token = transaction.paymentMethod?.token ?? "empty"
        print("My payment token is \(token)")

        displayAlert(message: "Token: \(token)", title: "Success")
    }

    func displayAlert(message: String, title: String) {
        let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
}
