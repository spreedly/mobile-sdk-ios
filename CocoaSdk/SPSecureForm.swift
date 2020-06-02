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
        let client = createSpreedlyClient(
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
    @IBOutlet public weak var company: UITextField?
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

    @IBOutlet public weak var email: UITextField?

    // Address fields
    @IBOutlet public weak var address1: UITextField?
    @IBOutlet public weak var address2: UITextField?
    @IBOutlet public weak var city: UITextField?
    @IBOutlet public weak var state: UITextField?
    @IBOutlet public weak var zip: UITextField?
    @IBOutlet public weak var country: UITextField?
    @IBOutlet public weak var phoneNumber: UITextField?

    // Shipping address fields
    @IBOutlet public weak var shippingAddress1: UITextField?
    @IBOutlet public weak var shippingAddress2: UITextField?
    @IBOutlet public weak var shippingCity: UITextField?
    @IBOutlet public weak var shippingState: UITextField?
    @IBOutlet public weak var shippingZip: UITextField?
    @IBOutlet public weak var shippingCountry: UITextField?
    @IBOutlet public weak var shippingPhoneNumber: UITextField?

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
        maybeSetCardFields(on: info)
        maybeSetAddress(on: info)
        maybeSetShippingAddress(on: info)

        var email: String?
        if let emailValue = self.email?.text {
            email = emailValue
        }

        _ = client.createCreditCardPaymentMethod(creditCard: info, email: email, metadata: nil).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOf(errors: errors)
                } else {
                    self.delegate?.spreedly(secureForm: self, success: transaction)
                }
            }
        })
    }

    private func maybeSetCardFields(on info: CreditCardInfo) {
        // Always number and verification from this form
        info.number = creditCardNumber?.secureText()
        info.verificationValue = creditCardVerificationNumber?.secureText()

        if let fullName = fullName?.text {
            info.fullName = fullName
        }
        if let dateParts = expirationDate?.dateParts()
        {
            info.month = dateParts.month
            info.year = dateParts.year
        }
        if let company = company?.text {
            info.company = company
        }
    }

    private func maybeSetAddress(on info: CreditCardInfo) {
        if let address1 = address1?.text {
            info.address?.address1 = address1
        }
        if let address2 = address2?.text {
            info.address?.address2 = address2
        }
        if let city = city?.text {
            info.address?.city = city
        }
        if let state = state?.text {
            info.address?.state = state
        }
        if let zip = zip?.text {
            info.address?.zip = zip
        }
        if let country = country?.text {
            info.address?.country = country
        }
        if let phoneNumber = phoneNumber?.text {
            info.address?.phoneNumber = phoneNumber
        }
    }

    private func maybeSetShippingAddress(on info: CreditCardInfo) {
        if let address1 = shippingAddress1?.text {
            info.shippingAddress?.address1 = address1
        }
        if let address2 = shippingAddress2?.text {
            info.shippingAddress?.address2 = address2
        }
        if let city = shippingCity?.text {
            info.shippingAddress?.city = city
        }
        if let state = shippingState?.text {
            info.shippingAddress?.state = state
        }
        if let zip = shippingZip?.text {
            info.shippingAddress?.zip = zip
        }
        if let country = shippingCountry?.text {
            info.shippingAddress?.country = country
        }
        if let phoneNumber = shippingPhoneNumber?.text {
            info.shippingAddress?.phoneNumber = phoneNumber
        }
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
