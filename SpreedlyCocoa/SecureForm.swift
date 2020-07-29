//
// Created by Stefan Rusek on 5/20/20.
//

import Foundation
import UIKit
import Spreedly
import RxSwift

@objc(SPRSecureFormDelegate)
public protocol SecureFormDelegate: class {
    /// Called after a payment method is successfully created.
    func spreedly(
            secureForm form: SecureForm,
            success: Transaction
    )

    /// Called immediately before calling Spreedly's API endpoint. Useful for starting an activity spinner.
    @objc optional func willCallSpreedly(secureForm: SecureForm)

    /// Called immediately after calling Spreedly's API endpoint. Useful for stopping an activity spinner.
    @objc optional func didCallSpreedly(secureForm: SecureForm)

    /// If this method returns a ClientConfiguration, it wil be used by the SecureForm. Otherwise
    /// the SecureForm will attempt to read configuration values from `Spreedly-env.plist` in the
    /// main bundle.
    @objc optional func clientConfiguration(secureForm: SecureForm) -> ClientConfiguration?
}

@objc(SPRSecureForm)
public class SecureForm: UIView {
    @objc public weak var delegate: SecureFormDelegate?

    private var client: SpreedlyClient?

    private func getClientConfiguration() throws -> ClientConfiguration {
        if let config = delegate?.clientConfiguration?(secureForm: self) {
            return config
        }
        return try ClientConfiguration.getConfiguration()
    }

    private func getClient() throws -> SpreedlyClient {
        if let client = client {
            return client
        }

        let config = try getClientConfiguration()
        let client = ClientFactory.create(with: config)

        self.client = client
        return client
    }

    private func getClientOrDieTrying() -> SpreedlyClient {
        let client: SpreedlyClient
        do {
            client = try getClient()
        } catch ClientError.noSpreedlyCredentials {
            fatalError("No credentials were specified.")
        } catch {
            fatalError("Error: \(error)")
        }
        return client
    }

    @objc public var creditCardDefaults: CreditCardInfo?
    @objc public var bankAccountDefaults: BankAccountInfo?
    @objc public var paymentMethodDefaults: PaymentMethodInfo?

    // Shared fields
    @IBOutlet public weak var fullName: ValidatedTextField?
    @IBOutlet public weak var firstName: ValidatedTextField?
    @IBOutlet public weak var lastName: ValidatedTextField?
    @IBOutlet public weak var email: UITextField?

    // Credit card fields
    @IBOutlet public weak var creditCardNumber: CreditCardNumberTextField?
    @IBOutlet public weak var creditCardVerificationNumber: SecureTextField?
    @IBOutlet public weak var expirationDate: ValidatedTextField?
    @IBOutlet public weak var expirationDateProvider: ExpirationDateProvider?

    @IBOutlet public weak var company: UITextField?
    private var creditCardFields: [ValidatedTextField?] {
        [fullName, firstName, lastName, creditCardNumber, creditCardVerificationNumber, expirationDate]
    }

    // Bank account fields
    @IBOutlet public weak var bankAccountNumber: SecureTextField?
    @IBOutlet public weak var bankAccountRoutingNumber: ValidatedTextField?
    @IBOutlet public weak var bankAccountType: UISegmentedControl?
    @IBOutlet public weak var bankAccountHolderType: UISegmentedControl?
    private var bankAccountFields: [ValidatedTextField?] {
        [fullName, firstName, lastName, bankAccountNumber, bankAccountRoutingNumber]
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

    private func notifyFieldsOfValidation(fields: [ValidatedTextField?], errors: [SpreedlyError]) {
        var errorFields = [ValidatedTextField]()
        for err in errors {
            guard let field = findField(with: err.attribute) else {
                continue
            }
            field.setError(because: err.message)
            errorFields.append(field)
        }

        let validFields = Set<ValidatedTextField?>(fields).symmetricDifference(errorFields)
        for field in validFields {
            field?.setValid()
        }
    }

    private func clearValidationFor(_ fields: [ValidatedTextField?]) {
        for field in fields {
            field?.clearValidation()
        }
    }

    private func findField(with key: String?) -> ValidatedTextField? {
        switch key {
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

// MARK: - Creating cards
    @IBAction public func createCreditCardPaymentMethod(sender: UIView) {
        delegate?.willCallSpreedly?(secureForm: self)

        clearValidationFor(creditCardFields)

        let info = creditCardDefaults ?? CreditCardInfo(fromInfo: paymentMethodDefaults)
        maybeSetCardFields(on: info)
        maybeSetAddress(on: &info.address)
        maybeSetShippingAddress(on: &info.shippingAddress)

        let client = getClientOrDieTrying()
        _ = client.createPaymentMethodFrom(creditCard: info).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                self.delegate?.didCallSpreedly?(secureForm: self)
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOfValidation(fields: self.creditCardFields, errors: errors)
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
        if let date = expirationDateProvider?.expirationDate() {
            info.month = date.month
            info.year = date.year
        }

        info.unlessNil(set: \.fullName, to: fullName?.text)
        info.unlessNil(set: \.firstName, to: firstName?.text)
        info.unlessNil(set: \.lastName, to: lastName?.text)
        info.unlessNil(set: \.company, to: company?.text)
    }

// MARK: - Creating bank accounts

    @IBAction public func createBankAccountPaymentMethod(sender: UIView) {
        delegate?.willCallSpreedly?(secureForm: self)

        clearValidationFor(bankAccountFields)

        let info = bankAccountDefaults ?? BankAccountInfo(fromInfo: paymentMethodDefaults)
        maybeSetBankAccountFields(on: info)
        maybeSetAddress(on: &info.address)
        maybeSetShippingAddress(on: &info.shippingAddress)

        let client = getClientOrDieTrying()
        _ = client.createPaymentMethodFrom(bankAccount: info).subscribe(onSuccess: { transaction in
            DispatchQueue.main.async {
                self.delegate?.didCallSpreedly?(secureForm: self)
                if let errors = transaction.errors, errors.count > 0 {
                    self.notifyFieldsOfValidation(fields: self.bankAccountFields, errors: errors)
                } else {
                    self.delegate?.spreedly(secureForm: self, success: transaction)
                }
            }
        })
    }

    public var selectedHolderType: BankAccountHolderType {
        get {
            guard let index = bankAccountHolderType?.selectedSegmentIndex else {
                return .unknown
            }

            switch index {
            case 0:
                return .personal
            default:
                return .business
            }
        }
        set {
            switch newValue {
            case .personal, .unknown:
                bankAccountHolderType?.selectedSegmentIndex = 0
            case .business:
                bankAccountHolderType?.selectedSegmentIndex = 1
            }
        }
    }

    public var selectedAccountType: BankAccountType {
        get {
            guard let index = bankAccountType?.selectedSegmentIndex else {
                return .unknown
            }

            switch index {
            case 0:
                return .checking
            default:
                return .savings
            }
        }
        set {
            switch newValue {
            case .checking, .unknown:
                bankAccountType?.selectedSegmentIndex = 0
            case .savings:
                bankAccountType?.selectedSegmentIndex = 1
            }
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
    func unlessNil<T>(set path: ReferenceWritableKeyPath<Address, T>, to value: T?) {
        if let value = value {
            self[keyPath: path] = value
        }
    }
}
