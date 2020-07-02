//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import UIKit
import CoreSdk

class AddCardViewController: AddPaymentMethodViewController {
    @IBOutlet weak var expirationDatePicker: ExpirationPickerField!
    @IBOutlet weak var stackView: UIStackView!

    @IBAction func pickerTriggered(_ sender: Any) {
        expirationDatePicker?.showPicker()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addBackground(color: .tertiarySystemBackground)
        stackView.subviews.filter { $0 is UITextField }.dropFirst().forEach { view in
            view.layer.addBorder(edge: .top, color: .separator, thickness: 1)
        }

        configureDefaults()
    }

    func configureDefaults() {
        form.fullName?.text = context?.fullNameCreditCard
    }
}
