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

    public var client: SpreedlyClient

    public var creditCardDefaults: CreditCardInfo?
    public var bankAccountDefaults: BankAccountInfo?

    @IBOutlet public weak var fullName: UITextField?
    @IBOutlet public weak var creditCardNumber: SPSecureTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SPSecureTextField?
    @IBOutlet public weak var expirationMonth: UITextField?
    @IBOutlet public weak var expirationYear: UITextField?

    public override init(frame: CGRect) {
        client = createSpreedlyClient(envKey: "secretEnvKey", envSecret: "secretEnvSecret")
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        client = createSpreedlyClient(envKey: "secretEnvKey", envSecret: "secretEnvSecret")
        super.init(coder: coder)
    }


    @IBAction public func createCreditCardPaymentMethod(sender: UIView) {
        let message = """
                      \(fullName?.text() ?? "No name")
                      \(creditCardNumber?.text() ?? "")
                      \(creditCardVerificationNumber?.text() ?? "")
                      \(expirationMonth?.text() ?? "mm")/\(expirationYear?.text() ?? "yy")
                      """
        let alert = UIAlertController(
                title: "Submit", 
                message: message,
                preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        window?.rootViewController?.present(alert, animated: true)

//        var info = CreditCardInfo(
//                fullName: creditCardDefaults?.fullName ?? "",
//                number: creditCardNumber?.secureText() ?? creditCardDefaults?.number,
//                verificationValue: <#T##SpreedlySecureOpaqueString##CoreSdk.SpreedlySecureOpaqueString#>,
//                year: <#T##Int##Swift.Int#>,
//                month: <#T##Int##Swift.Int#>
//        )
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


extension UITextField  {

    func text() -> String? {
        self.text
//        if let tf = self as? UITextField {
//            return tf.text
//        }
//        return nil
    }

    func secureText() -> SpreedlySecureOpaqueString? {
        let client = createSpreedlyClient(envKey: "secretEnvKey", envSecret: "secretEnvSecret")
        guard let text = self.text else {
            return nil
        }
        return client.createSecureString(from: text)
    }
}
