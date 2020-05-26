//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import CoreSdk
import RxSwift
import FormTextField

public protocol SPSecureFormDelegate {
    // TODO: make these methods optionally implementable
    func spreedly<TResult>(secureForm form: SPSecureForm, success: Transaction<TResult>) where TResult: PaymentMethodResultBase
}

public enum SPSecureClientError: Error {
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

    public func getClient() throws -> SpreedlyClient {
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

    // Credit Card fields
    public var creditCardDefaults: CreditCardInfo?
    @IBOutlet public weak var fullName: ValidatedTextField?
    @IBOutlet public weak var creditCardNumber: SPCreditCardNumberTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SPSecureTextField?
    @IBOutlet public weak var expirationDate: SPExpirationTextField?
    var creditCardFields: [UIView?] {
        [fullName, creditCardNumber, creditCardVerificationNumber, expirationDate]
    }

    // Bank Account fields
    public var bankAccountDefaults: BankAccountInfo?
    @IBOutlet public weak var bankAccountNumber: SPSecureTextField?
    @IBOutlet public weak var bankAccountRoutingNumber: SPSecureTextField?
    @IBOutlet public weak var bankAccountType: UISegmentedControl?
    @IBOutlet public weak var bankAccountHolderType: UISegmentedControl?

    var selectedBankAccountType: String?

    var bankAccountFields: [UIView?] {
        [fullName, bankAccountNumber, bankAccountRoutingNumber, bankAccountType, bankAccountHolderType]
    }

    @IBAction public func createCreditCardPaymentMethod(sender: UIView) {
        unsetErrorFor(creditCardFields)

        let client: SpreedlyClient
        do {
            client = try getClient()
        } catch SPSecureClientError.noSpreedlyCredentials {
            displayAlert(message: "No credentials were specified.", title: "Error")
            return
        } catch {
            displayAlert(message: "Error: \(error)", title: "Error")
            return
        }

        let info = CreditCardInfo(from: creditCardDefaults)

        info.fullName = fullName?.text()
        info.number = creditCardNumber?.secureText()
        info.verificationValue = creditCardVerificationNumber?.secureText()
        let dateParts = expirationDate?.dateParts()
        info.month = dateParts?.month
        info.year = dateParts?.year

        _ = client.createCreditCardPaymentMethod(creditCard: info).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOf(errors: errors)
                } else {
                    self.delegate?.spreedly(secureForm: self, success: transaction)
                }
            }
        })
    }

    private func notifyFieldsOf(errors: [SpreedlyError]) {
        for err in errors {
            let view = keyToView(err.attribute)
            view?.setError(message: err.message)
        }
    }

    private func unsetErrorFor(_ fields: [UIView?]) {
        for field in fields {
            field?.unsetError()
        }
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

    func keyToView(_ key: String?) -> UIView? {
        switch (key) {
        case "number":
            return creditCardNumber
        case "verification_value":
            return creditCardVerificationNumber
        case "year", "month":
            return expirationDate
        case "first_name", "last_name", "full_name":
            return fullName
        default:
            return nil
        }
    }

    public func viewDidLoad() {

    }
}

extension SPSecureForm {
    @IBAction public func createBankAccountPaymentMethod(sender: UIView) {
        unsetErrorFor(bankAccountFields)

        let client: SpreedlyClient
        do {
            client = try getClient()
        } catch SPSecureClientError.noSpreedlyCredentials {
            displayAlert(message: "No credentials were specified.", title: "Error")
            return
        } catch {
            displayAlert(message: "Error: \(error)", title: "Error")
            return
        }

        let info = BankAccountInfo(from: bankAccountDefaults)

        info.fullName = fullName?.text()
        info.bankAccountNumber = bankAccountNumber?.secureText()
        info.bankRoutingNumber = bankAccountRoutingNumber?.text()

        switch bankAccountHolderType?.selectedSegmentIndex {
        case 0:
            info.bankAccountHolderType = .personal
        default:
            info.bankAccountHolderType = .business
        }

        switch bankAccountType?.selectedSegmentIndex {
        case 0:
            info.bankAccountType = .checking
        default:
            info.bankAccountType = .savings
        }

        _ = client.createBankAccountPaymentMethod(bankAccount: info).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOf(errors: errors)
                } else {
                    self.delegate?.spreedly(secureForm: self, success: transaction)
                }
            }
        })
    }
}

extension UIView {
    @objc
    open func setError(message: String) {
        print("My error is: \(message)")
    }

    @objc
    open func unsetError() {

    }
}

extension ValidatedTextField {
    open override func setError(message: String) {
        invalidate(because: message)
    }

    open override func unsetError() {
        validate()
    }
}

public class SPSecureTextField: ValidatedTextField {

}


extension UITextField {
    func text() -> String? {
        self.text
    }

    @objc
    public func secureText() -> SpreedlySecureOpaqueString? {
        guard let text = self.text else {
            return nil
        }
        let client = getClient()
        return client?.createSecureString(from: text)
    }

    func getClient() -> SpreedlyClient? {
        var view = self.superview

        while view != nil {
            if let form = view as? SPSecureForm {
                return try? form.getClient()
            }
            view = view?.superview
        }

        return nil
    }
}


