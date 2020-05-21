//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import CocoaSdk
import CoreSdk
import RxSwift

class CreditCardFormViewController: UIViewController {

    @IBOutlet var form: SPSecureForm?

    override func viewDidLoad() {
        super.viewDidLoad()

        setDefaults()
        configureHandlers()
    }

    /// Set defaults here for values like name
    /// or address information.
    func setDefaults() {
        form?.fullName?.text = "Dolly Dog"

        let defaults = CreditCardInfo()
        var billing = Address()
        billing.address1 = "123 Bark St"
        billing.city = "Canine"
        billing.state = "WA"
        billing.zip = "98121"
        billing.country = "US"
        billing.phoneNumber = "206-555-2275"
        defaults.address = billing

        form?.creditCardDefaults = defaults
    }

    func configureHandlers() {
        self.form?.delegate = self
    }
}

extension CreditCardFormViewController: SPSecureFormDelegate {
    func spreedly<TResult>(secureForm form: SPSecureForm, result: Single<Transaction<TResult>>) where TResult: PaymentMethodResultBase {
        _ = result.subscribe(onSuccess: { (transaction: Transaction<TResult>) -> Void in
            print("My payment token is \(transaction.paymentMethod?.token ?? "empty")")
        })
    }
}
