//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import UIKit
import CoreSdk

class AddCardController: UIViewController {
    @IBOutlet weak var expirationDate: ExpirationPickerField!
    @IBOutlet weak var form: SPSecureForm!

    @IBAction func pickerTriggered(_ sender: Any) {
        expirationDate?.showPicker()
    }

    override func viewDidLoad() {
        configureDelegates()
    }

    func configureDelegates() {
        form.delegate = self
    }
}

extension AddCardController: SPSecureFormDelegate {
    func spreedly<TResult>(
            secureForm form: SPSecureForm,
            success transaction: Transaction<TResult>
    ) where TResult: PaymentMethodResultBase {
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
