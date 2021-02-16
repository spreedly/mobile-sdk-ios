# SecureForm

Coordinates with form controls to collect user input, manage API calls with Spreedly, and validate inputs.

``` swift
@objc(SPRSecureForm) public class SecureForm: UIView
```

Does not change presentation directly.

# Use with a Storyboard

One way to use the `SecureForm` in a Storyboard is to set it as the custom class for your ViewController's view.
Under that view, add all your form elements (e.g. card number, cardholder name, verification value, expiration date,
address fields, email address, etc), then connect those elements to the `@IBOutlet` properties on the SecureForm.
Finally, connect your call-to-action button to the SecureForm's create methods (either
`createCreditCardPaymentMethod` or `createBankAccountPaymentMethod`) to tell the form to gather the field values
and attempt payment method creation with Spreedly.

## Inheritance

`UIView`

## Properties

### `delegate`

``` swift
var delegate: SecureFormDelegate?
```

### `creditCardDefaults`

Provides a set of default values used to populate any credit card fields not set by the form.
When set, `SecureForm.paymentMethodDefaults` will be ignored.

``` swift
var creditCardDefaults: CreditCardInfo?
```

### `bankAccountDefaults`

Provides a set of default values used to populate any bank account fields not set by the form.
When set, `paymentMethodDefaults` will be ignored.

``` swift
var bankAccountDefaults: BankAccountInfo?
```

### `paymentMethodDefaults`

Provides a set of default values used to populate any fields not set by the form.

``` swift
var paymentMethodDefaults: PaymentMethodInfo?
```

### `fullName`

``` swift
var fullName: ValidatedTextField?
```

### `firstName`

``` swift
var firstName: ValidatedTextField?
```

### `lastName`

``` swift
var lastName: ValidatedTextField?
```

### `email`

``` swift
var email: UITextField?
```

### `company`

``` swift
var company: UITextField?
```

### `creditCardNumber`

``` swift
var creditCardNumber: CreditCardNumberTextField?
```

### `creditCardVerificationNumber`

``` swift
var creditCardVerificationNumber: SecureTextField?
```

### `expirationDate`

``` swift
var expirationDate: ValidatedTextField?
```

### `expirationDateProvider`

``` swift
var expirationDateProvider: ExpirationDateProvider?
```

### `bankAccountNumber`

``` swift
var bankAccountNumber: SecureTextField?
```

### `bankAccountRoutingNumber`

``` swift
var bankAccountRoutingNumber: ValidatedTextField?
```

### `bankAccountType`

``` swift
var bankAccountType: UISegmentedControl?
```

### `bankAccountHolderType`

``` swift
var bankAccountHolderType: UISegmentedControl?
```

### `address1`

``` swift
var address1: UITextField?
```

### `address2`

``` swift
var address2: UITextField?
```

### `city`

``` swift
var city: UITextField?
```

### `state`

``` swift
var state: UITextField?
```

### `zip`

``` swift
var zip: UITextField?
```

### `country`

``` swift
var country: UITextField?
```

### `phoneNumber`

``` swift
var phoneNumber: UITextField?
```

### `sameAddressForShipping`

``` swift
var sameAddressForShipping: UISwitch?
```

### `shippingAddress1`

``` swift
var shippingAddress1: UITextField?
```

### `shippingAddress2`

``` swift
var shippingAddress2: UITextField?
```

### `shippingCity`

``` swift
var shippingCity: UITextField?
```

### `shippingState`

``` swift
var shippingState: UITextField?
```

### `shippingZip`

``` swift
var shippingZip: UITextField?
```

### `shippingCountry`

``` swift
var shippingCountry: UITextField?
```

### `shippingPhoneNumber`

``` swift
var shippingPhoneNumber: UITextField?
```

### `selectedHolderType`

``` swift
var selectedHolderType: BankAccountHolderType
```

### `selectedAccountType`

``` swift
var selectedAccountType: BankAccountType
```

## Methods

### `createCreditCardPaymentMethod(sender:)`

Combines data from the defaults (`creditCardDefaults` if set otherwise `paymentMethodDefaults`) with
the form's values and attempts to create a credit card payment method.

``` swift
@IBAction public func createCreditCardPaymentMethod(sender: UIView)
```

If the create call returns any field validation errors, those fields are notified of the errors.
If successful, calls `delegate.spreedly(secureForm:success:)` with the successful `Transaction`.

### `createBankAccountPaymentMethod(sender:)`

Combines data from the defaults (`bankAccountDefaults` if set otherwise `paymentMethodDefaults`) with
the form's values and attempts to create a credit card payment method.

``` swift
@IBAction public func createBankAccountPaymentMethod(sender: UIView)
```

If the create call returns any field validation errors, those fields are notified of the errors.
If successful, calls `delegate.spreedly(secureForm:success:)` with the successful `Transaction`.
