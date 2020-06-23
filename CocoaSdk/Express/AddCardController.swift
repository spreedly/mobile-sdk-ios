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
        for index in 0..<stackView.subviews.count - 1 {
            let view = stackView.subviews[index]
            view.layer.addBorder(edge: .bottom, color: .systemGray2, thickness: 1)
        }
    }
}
