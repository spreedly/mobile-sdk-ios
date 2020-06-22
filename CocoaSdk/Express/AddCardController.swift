//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import UIKit
import CoreSdk

class AddCardController: AddPaymentMethodController {
    @IBOutlet weak var expirationDate: ExpirationPickerField!

    @IBAction func pickerTriggered(_ sender: Any) {
        expirationDate?.showPicker()
    }
}
