//
// Created by Eli Thompson on 6/18/20.
//

import Foundation
import UIKit
import Spreedly

class AddCardViewController: AddPaymentMethodViewController {
    @IBOutlet weak var expirationDatePicker: ExpirationPickerField!
    @IBOutlet weak var stackView: UIStackView!

    @IBAction func pickerTriggered(_ sender: Any) {
        expirationDatePicker?.showPicker()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addBackground(color: UIColor.tertiarySystemBackgroundPre13)
        stackView.subviews.filter { $0 is UITextField }.dropFirst().forEach { view in
            view.layer.addBorder(edge: .top, color: UIColor.separatorPre13, thickness: 1)
        }

        configureDefaults()
    }

    func configureDefaults() {
        form.fullName?.text = context?.fullNameCreditCard
    }
}
