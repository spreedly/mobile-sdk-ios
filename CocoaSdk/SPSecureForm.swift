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

    public var creditCardDefaults: CreditCardInfo?
    public var bankAccountDefaults: BankAccountInfo?

    // Shared fields
    @IBOutlet public weak var fullName: ValidatedTextField?
    @IBOutlet public weak var firstName: ValidatedTextField?
    @IBOutlet public weak var lastName: ValidatedTextField?
    @IBOutlet public weak var email: UITextField?

    // Credit card fields
    @IBOutlet public weak var creditCardNumber: SPCreditCardNumberTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SPSecureTextField?
    @IBOutlet public weak var expirationDate: SPExpirationTextField?
    @IBOutlet public weak var company: UITextField?
    private var creditCardFields: [ValidatedTextField?] {
        [fullName, firstName, lastName, creditCardNumber, creditCardVerificationNumber, expirationDate]
    }

    // Bank account fields
    @IBOutlet public weak var bankAccountNumber: SPSecureTextField?
    @IBOutlet public weak var bankAccountRoutingNumber: ValidatedTextField?
    @IBOutlet public weak var bankAccountType: UISegmentedControl?
    @IBOutlet public weak var bankAccountHolderType: UISegmentedControl?
    private var bankAccountFields: [ValidatedTextField?] {
        [fullName, bankAccountNumber, bankAccountRoutingNumber]
    }

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
            return fullName // TODO: What attribute does Spreedly say is in error when any combination of these three fields is invalid?
        case "account_number":
            return bankAccountNumber
        case "routing_number":
            return bankAccountRoutingNumber
        default:
            return nil
        }
    }

    /// When an address form field exists with a non-nil value, assign it to
    /// the related Address property.
    private func maybeSetAddress(on address: inout Address) {
        address.unlessNil(set: \.address1, to: address1?.text)
        address.unlessNil(set: \.address2, to: address2?.text)
        address.unlessNil(set: \.city, to: city?.text)
        address.unlessNil(set: \.state, to: state?.text)
        address.unlessNil(set: \.zip, to: zip?.text)
        address.unlessNil(set: \.country, to: country?.text)
        address.unlessNil(set: \.phoneNumber, to: phoneNumber?.text)
    }

    /// When a shippingAddress form field exists with a non-nil value, assign it to
    /// the related Address property.
    private func maybeSetShippingAddress(on address: inout Address) {
        address.unlessNil(set: \.address1, to: shippingAddress1?.text)
        address.unlessNil(set: \.address2, to: shippingAddress2?.text)
        address.unlessNil(set: \.city, to: shippingCity?.text)
        address.unlessNil(set: \.state, to: shippingState?.text)
        address.unlessNil(set: \.zip, to: shippingZip?.text)
        address.unlessNil(set: \.country, to: shippingCountry?.text)
        address.unlessNil(set: \.phoneNumber, to: shippingPhoneNumber?.text)
    }
}

// MARK: - Creating cards
extension SPSecureForm {
    @IBAction public func createCreditCardPaymentMethod(sender: UIView) {
        unsetErrorFor(creditCardFields)

        let client = getClientOrDieTrying()

        let info = CreditCardInfo(from: creditCardDefaults)
        maybeSetCardFields(on: info)
        maybeSetAddress(on: &info.address)
        maybeSetShippingAddress(on: &info.shippingAddress)

        _ = client.createCreditCardPaymentMethod(creditCard: info, email: email?.text, metadata: nil).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOf(errors: errors)
                } else {
                    self.delegate?.spreedly(secureForm: self, success: transaction)
                }
            }
        })
    }

    /// When a form field exists with a non-nil value, assign it to
    /// the related CreditCardInfo property.
    /// However, `number` and `verificationValue` will be set to nil if the field
    /// does not exist.
    private func maybeSetCardFields(on info: CreditCardInfo) {
        // Always get number and verification from this form
        info.number = creditCardNumber?.secureText()
        info.verificationValue = creditCardVerificationNumber?.secureText()
        if let dateParts = expirationDate?.dateParts() {
            info.month = dateParts.month
            info.year = dateParts.year
        }

        info.unlessNil(set: \.fullName, to: fullName?.text)
        info.unlessNil(set: \.firstName, to: firstName?.text)
        info.unlessNil(set: \.lastName, to: lastName?.text)
        info.unlessNil(set: \.company, to: company?.text)
    }
}

// MARK: - Creating bank accounts
extension SPSecureForm {
    @IBAction public func createBankAccountPaymentMethod(sender: UIView) {
        unsetErrorFor(bankAccountFields)

        let client = getClientOrDieTrying()

        let info = BankAccountInfo(from: bankAccountDefaults)
        maybeSetBankAccountFields(on: info)
        maybeSetAddress(on: &info.address)
        maybeSetShippingAddress(on: &info.shippingAddress)

        _ = client.createBankAccountPaymentMethod(bankAccount: info, email: email?.text, metadata: nil).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOf(errors: errors)
                } else {
                    self.delegate?.spreedly(secureForm: self, success: transaction)
                }
            }
        })
    }

    private var selectedHolderType: BankAccountHolderType? {
        guard let index = bankAccountHolderType?.selectedSegmentIndex else {
            return nil
        }

        switch index {
        case 0:
            return .personal
        default:
            return .business
        }
    }

    private var selectedAccountType: BankAccountType? {
        guard let index = bankAccountType?.selectedSegmentIndex else {
            return nil
        }

        switch index {
        case 0:
            return .checking
        default:
            return .savings
        }
    }

    /// When a form field exists with a non-nil value, assign it to
    /// the related BankAccountInfo property.
    private func maybeSetBankAccountFields(on info: BankAccountInfo) {
        info.unlessNil(set: \.fullName, to: fullName?.text)
        info.unlessNil(set: \.firstName, to: firstName?.text)
        info.unlessNil(set: \.lastName, to: lastName?.text)

        info.unlessNil(set: \.bankAccountNumber, to: bankAccountNumber?.secureText())
        info.unlessNil(set: \.bankRoutingNumber, to: bankAccountRoutingNumber?.text)
        info.unlessNil(set: \.bankAccountType, to: selectedAccountType)
        info.unlessNil(set: \.bankAccountHolderType, to: selectedHolderType)
    }
}

extension CreditCardInfo {
    func unlessNil<T>(set path: ReferenceWritableKeyPath<CreditCardInfo, T>, to value: T?) {
        if let value = value {
            self[keyPath: path] = value
        }
    }
}

extension BankAccountInfo {
    func unlessNil<T>(set path: ReferenceWritableKeyPath<BankAccountInfo, T>, to value: T?) {
        if let value = value {
            self[keyPath: path] = value
        }
    }
}

extension Address {
    mutating func unlessNil<T>(set path: WritableKeyPath<Address, T>, to value: T?) {
        if let value = value {
            self[keyPath: path] = value
        }
    }
}
