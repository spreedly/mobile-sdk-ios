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
        form?.delegate = self
        
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
    func spreedly<TResult>(secureForm form: SPSecureForm, success transaction: Transaction<TResult>) where TResult: PaymentMethodResultBase {
        print("My payment token is \(transaction.paymentMethod?.token ?? "empty")")

        self.navigationController?.popViewController(animated: true)

    }
}
