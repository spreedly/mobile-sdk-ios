//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import CocoaSdk
import CoreSdk
import RxSwift

class BankAccountFormViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var form: SPSecureForm?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDelegates()
        setDefaults()
    }

    /// Set defaults here for values like name
    /// or address information.
    func setDefaults() {
        form?.fullName?.text = "Dolly Dog"

        let defaults = BankAccountInfo()
        var billing = Address()
        billing.address1 = "123 Bark St"
        billing.city = "Canine"
        billing.state = "WA"
        billing.zip = "98121"
        billing.country = "US"
        billing.phoneNumber = "206-555-2275"
        defaults.address = billing

        form?.bankAccountDefaults = defaults
    }

    func configureDelegates() {
        self.form?.delegate = self
        self.form?.fullName?.delegate = self
        self.form?.bankAccountRoutingNumber?.delegate = self
        self.form?.bankAccountNumber?.delegate = self
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
    func spreedly<TResult>(secureForm form: SPSecureForm, success transaction: Transaction<TResult>) where TResult: PaymentMethodResultBase {
        print("My payment token is \(transaction.paymentMethod?.token ?? "empty")")

        self.navigationController?.popViewController(animated: true)

    }
}
