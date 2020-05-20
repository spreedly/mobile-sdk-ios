//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import CoreSdk
import RxSwift

public protocol SPSecureFormDelegate {
    func spreedly(secureForm form: SPSecureForm, creditCardSuccess result: Transaction<CreditCardResult>);
}

public class SPSecureForm: UIView {

    public var delegate: SPSecureFormDelegate?

    public var creditCardDefaults: CreditCardInfo?
    public var bankAccountDefaults: BankAccountInfo?

    @IBOutlet public weak var fullName: UITextField?
    @IBOutlet public weak var creditCardNumber: SPSecureTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SPSecureTextField?

    @IBAction public func createCreditCardPaymentMethod(sender: UIView) -> Single<Transaction<CreditCardResult>> {
        let alert = UIAlertController(title: "Submit", message: "\(creditCardNumber?.text() ?? "") - \(creditCardVerificationNumber?.text() ?? "")", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        window?.rootViewController?.present(alert, animated: true)

        var info = CreditCardInfo(fullName: creditCardDefaults?.fullName, number: creditCardNumber?.secureText() ?? creditCardDefaults?.number, verificationValue: <#T##SpreedlySecureOpaqueString##CoreSdk.SpreedlySecureOpaqueString#>, year: <#T##Int##Swift.Int#>, month: <#T##Int##Swift.Int#>)
    }

    func keyToView(_ key: String) -> UIView? {
        switch (key) {
        case "credit_card_number":
            return creditCardNumber
        default:
            return nil
        }
    }

}

public class SPSecureTextField: UITextField {


}


extension UIView {

    func text() -> String? {
        if let tf = self as? UITextField {
            return tf.text
        }
        return nil
    }

    func secureText() -> SpreedlySecureOpaqueString? {
        return nil
    }
}