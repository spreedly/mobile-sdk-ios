//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import CoreSdk
import RxSwift

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
        let client = ClientFactory.create(
                envKey: credentials.envKey,
                envSecret: credentials.envSecret,
                test: credentials.test
        )
        _client = client
        return client
    }

    func getClientOrDieTrying() -> SpreedlyClient {
        let client: SpreedlyClient
        do {
            client = try getClient()
        } catch SPSecureClientError.noSpreedlyCredentials {
            fatalError("No credentials were specified.")
        } catch {
            fatalError("Error: \(error)")
        }
        return client
    }

    // Credit Card fields
    public var creditCardDefaults: CreditCardInfo?
    @IBOutlet public weak var fullName: ValidatedTextField?
    @IBOutlet public weak var creditCardNumber: SPCreditCardNumberTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SPSecureTextField?
    @IBOutlet public weak var expirationDate: SPExpirationTextField?
    private var creditCardFields: [ValidatedTextField?] {
        [fullName, creditCardNumber, creditCardVerificationNumber, expirationDate]
    }

    // Bank Account fields
    public var bankAccountDefaults: BankAccountInfo?
    @IBOutlet public weak var bankAccountNumber: SPSecureTextField?
    @IBOutlet public weak var bankAccountRoutingNumber: ValidatedTextField?
    @IBOutlet public weak var bankAccountType: UISegmentedControl?
    @IBOutlet public weak var bankAccountHolderType: UISegmentedControl?
    private var bankAccountFields: [ValidatedTextField?] {
        [fullName, bankAccountNumber, bankAccountRoutingNumber]
    }

    private func notifyFieldsOf(errors: [SpreedlyError]) {
        for err in errors {
            let field = findField(with: err.attribute)
            field?.setError(because: err.message)
        }
    }

    private func unsetErrorFor(_ fields: [ValidatedTextField?]) {
        for field in fields {
            field?.unsetError()
        }
    }

    private func findField(with key: String?) -> ValidatedTextField? {
        switch (key) {
        case "number":
            return creditCardNumber
        case "verification_value":
            return creditCardVerificationNumber
        case "year", "month":
            return expirationDate
        case "first_name", "last_name", "full_name":
            return fullName
        case "account_number":
            return bankAccountNumber
        case "routing_number":
            return bankAccountRoutingNumber
        default:
            return nil
        }
    }
}

extension SPSecureForm {
    @IBAction public func createCreditCardPaymentMethod(sender: UIView) {
        unsetErrorFor(creditCardFields)

        let client = getClientOrDieTrying()

        let info = CreditCardInfo(from: creditCardDefaults)
        info.fullName = fullName?.text
        info.number = creditCardNumber?.secureText()
        info.verificationValue = creditCardVerificationNumber?.secureText()
        let dateParts = expirationDate?.dateParts()
        info.month = dateParts?.month
        info.year = dateParts?.year

        _ = client.createPaymentMethodFrom(creditCard: info).subscribe(onSuccess: { transaction in
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

extension SPSecureForm {
    private var selectedHolderType: BankAccountHolderType {
        switch bankAccountHolderType?.selectedSegmentIndex {
        case 0:
            return .personal
        default:
            return .business
        }
    }

    private var selectedAccountType: BankAccountType {
        switch bankAccountType?.selectedSegmentIndex {
        case 0:
            return .checking
        default:
            return .savings
        }
    }

    @IBAction public func createBankAccountPaymentMethod(sender: UIView) {
        unsetErrorFor(bankAccountFields)

        let client = getClientOrDieTrying()

        let info = BankAccountInfo(from: bankAccountDefaults)
        info.fullName = fullName?.text
        info.bankAccountNumber = bankAccountNumber?.secureText()
        info.bankRoutingNumber = bankAccountRoutingNumber?.text
        info.bankAccountHolderType = selectedHolderType
        info.bankAccountType = selectedAccountType

        _ = client.createPaymentMethodFrom(bankAccount: info).subscribe(onSuccess: { transaction in
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
