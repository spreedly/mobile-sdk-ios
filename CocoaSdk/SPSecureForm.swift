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

public enum SPSecureClientError: Error {
    case noSpreedlyClient
    case noSpreedlyCredentials
}

public class SPSecureForm: UIView {

    public var delegate: SPSecureFormDelegate?

    private func getCredentials() throws -> (envKey: String, envSecret: String, test: Bool) {
        guard let path = Bundle.main.path(forResource: "Spreedly-env", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) as? [String: Any],
              let envKey = config["ENV_KEY"] as? String,
              let envSecret = config["ENV_SECRET"] as? String,
              envKey.count > 0 && envSecret.count > 0 else {
            throw SPSecureClientError.noSpreedlyCredentials
        }

        return (
                envKey: envKey,
                envSecret: envSecret,
                test: config["TEST"] as? Bool ?? false
        )
    }

    private var _client: SpreedlyClient?
    private func getOrCreateClient() throws -> SpreedlyClient {
        if let client = _client {
            return client
        }

        let credentials = try getCredentials()
        let client = createSpreedlyClient(
                envKey: credentials.envKey,
                envSecret: credentials.envSecret,
                test: credentials.test
        )
        _client = client
        return client
    }

//    public var client: SpreedlyClient {
//        get {
//            if let client = _client {
//                return client
//            } else {
//                if let path = Bundle.main.path(forResource: "Spreedly-env", ofType: "plist"),
//                   let config = NSDictionary(contentsOfFile: path) as? [String: Any],
//                   let envKey = config["ENV_KEY"] as? String,
//                   let envSecret = config["ENV_SECRET"] as? String
//                {
//                    _client = createSpreedlyClient(envKey: envKey, envSecret: envSecret, test: config["TEST"] as? Bool ?? false)
//                    return _client!
//                }
//            }
//            fatalError("SPSecureForm needs a SpreedlyClient, you can either create one and set the client property or you can use a Spreedly-env.plist file.")
//        }
//        set {
//            _client = newValue
//        }
//    }

    public var creditCardDefaults: CreditCardInfo?
    public var bankAccountDefaults: BankAccountInfo?

    @IBOutlet public weak var fullName: UITextField?
    @IBOutlet public weak var creditCardNumber: SPSecureTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SPSecureTextField?
    @IBOutlet public weak var expirationMonth: UITextField?
    @IBOutlet public weak var expirationYear: UITextField?

    @IBOutlet public weak var errors: UILabel?

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }



    @IBAction public func createCreditCardPaymentMethod(sender: UIView) {
        let client: SpreedlyClient
        do {
            client = try getOrCreateClient()
        } catch SPSecureClientError.noSpreedlyCredentials  {
            displayAlert(message: "No credentials were specified.", title: "Error")
            return
        } catch {
            displayAlert(message: "Error: \(error)", title: "Error")
            return
        }

        let message = """
                      \(fullName?.text() ?? "No name")
                      \(creditCardNumber?.text() ?? "")
                      \(creditCardVerificationNumber?.text() ?? "")
                      \(expirationMonth?.text() ?? "mm")/\(expirationYear?.text() ?? "yy")
                      """
        displayAlert(message: message, title: "Submit")

        let info = CreditCardInfo(from: creditCardDefaults)

        info.fullName = fullName?.text()
        info.number = creditCardNumber?.secureText()
        info.verificationValue = creditCardVerificationNumber?.secureText()
        info.month = Int(expirationMonth?.text() ?? "")
        info.year = Int(expirationYear?.text() ?? "")

        _ = client.createCreditCardPaymentMethod(creditCard: info).subscribe(onSuccess: { transaction in
            if let errors = transaction.errors, errors.count > 0 {
                DispatchQueue.main.async {
                    self.errors?.text = errors[0].message    // Update UI
                }
                return
            }

            self.delegate?.spreedly(secureForm: self, creditCardSuccess: transaction)
        })
    }

    func displayAlert(message: String, title: String) {
        let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        window?.rootViewController?.present(alert, animated: true)
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


extension UITextField {

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
