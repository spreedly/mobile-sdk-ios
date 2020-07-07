//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import SpreedlyCocoa
import Spreedly
import RxSwift

class CreditCardFormViewController: UIViewController {
    @IBOutlet weak var form: SPSecureForm!
    @IBOutlet weak var expirationDatePicker: ExpirationPickerField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setDefaults()
        configureDelegates()
    }

    /// Set defaults here for values like name
    /// or address information.
    func setDefaults() {
        form.fullName?.text = "Dolly Dog"

        let defaults = CreditCardInfo()
        let billing = Address()
        billing.address1 = "123 Bark St"
        billing.city = "Canine"
        billing.state = "WA"
        billing.zip = "98121"
        billing.country = "US"
        billing.phoneNumber = "206-555-2275"
        defaults.address = billing

        form.creditCardDefaults = defaults
    }

    func configureDelegates() {
        form.delegate = self
    }

    @IBAction func pickerTriggered(_ sender: Any) {
        expirationDatePicker.showPicker()
    }
}

extension CreditCardFormViewController: SPSecureFormDelegate {
    func willCallSpreedly(secureForm: SPSecureForm) {
        // intentionally blank
    }

    func didCallSpreedly(secureForm: SPSecureForm) {
        // intentionally blank
    }

    func spreedly(
            secureForm form: SPSecureForm,
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
