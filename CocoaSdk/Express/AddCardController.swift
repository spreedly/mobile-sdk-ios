//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import UIKit
import CoreSdk

class AddCardController: AddPaymentMethodController {
    @IBOutlet weak var expirationDate: ExpirationPickerField!
    @IBOutlet weak var stackView: UIStackView!

    @IBAction func pickerTriggered(_ sender: Any) {
        expirationDate?.showPicker()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addBackground(color: .systemBackground)
        stackView.subviews.filter { $0 is UITextField }.dropFirst().forEach { view in
            view.layer.addBorder(edge: .top, color: .systemGray2, thickness: 1)
        }
    }
}
