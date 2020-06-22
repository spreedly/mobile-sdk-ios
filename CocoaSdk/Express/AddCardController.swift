//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import UIKit
import CoreSdk

class AddCardController: UIViewController {
    @IBOutlet weak var expirationDate: ExpirationPickerField!
    @IBOutlet weak var form: SPSecureForm!

    var didAddCard: ((CreditCardResult) -> Void)?

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
        guard let card = transaction.paymentMethod as? CreditCardResult else {
            return
        }
        self.didAddCard?(card)
        self.navigationController?.popViewController(animated: true)
    }
}
