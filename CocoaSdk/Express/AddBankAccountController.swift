//
//  AddBankAccountController.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/23/20.
//

import UIKit
import CoreSdk

class AddBankAccountController: AddPaymentMethodController {
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addBackground(color: .systemBackground)
        stackView.subviews.filter { $0 is UITextField }.dropFirst().forEach { view in
            view.layer.addBorder(edge: .top, color: .systemGray2, thickness: 1)
        }
    }
}
