# ExpressBuilder

ExpressBuilder is the entrypoint for the Express UI workflow.

``` swift
@objc(SPRExpressBuilder) public class ExpressBuilder: NSObject
```

Create an instance of this class, optionally set properties to configure Express UI behavior, and finally call
`buildViewController()` to get a `UIViewController` ready to show.

### Example

``` swift
var builder = ExpressBuilder()
builder.didSelectPaymentMethod = { item in
    print("User wants to use a payment method with token: \(item.token)")
}
let controller = builder.buildViewController()
navigationController?.show(controller, sender: self)
```

## Inheritance

`NSObject`

## Properties

### `clientConfiguration`

A ClientConfiguration contains the environment key necessary to create payment methods with Spreedly.
This can be set explicitly. If it is not, the Express system will look for a `Spreedly-env.plist` file
in the main bundle for the environment key value under `ENV_KEY`.

``` swift
var clientConfiguration: ClientConfiguration?
```

### `allowCard`

Default:​ true. Allow the user to add new card payment methods.

``` swift
var allowCard: Bool = true
```

### `allowBankAccount`

Default:​ false. Allow the user to add new bank account payment methods.

``` swift
var allowBankAccount: Bool = false
```

### `allowApplePay`

Default:​ true. Allow users to select the Apple Pay payment method. When true, the `paymentRequest` property
must also be set.

``` swift
var allowApplePay: Bool = true
```

### `paymentMethods`

A list of payment methods available for the user to select. Set if providing
any previously stored payment methods.

``` swift
var paymentMethods: [PaymentMethodItem]?
```

### `didSelectPaymentMethod`

Called after the user selects a payment method. When called, the controller returned from
`buildViewController` should be popped/dismissed.

``` swift
var didSelectPaymentMethod: ((SelectedPaymentMethod) -> Void)?
```

### `defaultPaymentMethodInfo`

Set this to provide a full name on the payment method creation forms and to provide
name, company, email, address, shipping address, and metadata information to Spreedly
when a payment method is created. Values in this property will be used when creating a credit card
or bank account payment method.

``` swift
var defaultPaymentMethodInfo: PaymentMethodInfo?
```

### `defaultCreditCardInfo`

Set this to provide a full name on the form and to provide
name, company, email, address, shipping address, and metadata information to Spreedly when the payment method
is created. When this property is set, `defaultPaymentMethodInfo` will be ignored.

``` swift
var defaultCreditCardInfo: CreditCardInfo?
```

### `defaultBankAccountInfo`

Set this to provide a full name, bank account type, and bank account holder type on the form and to provide
name, company, email, address, shipping address, and metadata information to Spreedly when the payment method
is created. When this property is set, `defaultPaymentMethodInfo` will be ignored.

``` swift
var defaultBankAccountInfo: BankAccountInfo?
```

### `defaultApplePayInfo`

Set this to provide a name, company, email, address, shipping address, and metadata information to Spreedly
when the payment method is created. When this property is set, `defaultPaymentMethodInfo` will be ignored.

``` swift
var defaultApplePayInfo: PaymentMethodInfo?
```

### `paymentRequest`

Required when offering Apple Pay. Provides values to the Apple Pay dialog.

``` swift
var paymentRequest: PKPaymentRequest?
```

##### Example

``` swift
let request = PKPaymentRequest()
request.merchantIdentifier = "merchant.com.your_company.app"
request.countryCode = "US"
request.currencyCode = "USD"
request.supportedNetworks = [.amex, .discover, .masterCard, .visa]
request.merchantCapabilities = [.capabilityCredit, .capabilityDebit]
request.paymentSummaryItems = [
    PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(string: "322.38"), type: .final),
    PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "32.24"), type: .final),
    PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "354.62"), type: .final)
]

let builder = ExpressBuilder()
builder.paymentRequest = request
```

### `presentationStyle`

Default:​ `.withinNavigationView`. When showing the Express UI within an existing `UINavigationController`,
set this to `.withinNavigationView`. When it is meant to appear separately, such as within a modal,
set this to `.asModal` so it will provide its own `UINavigationController`.

``` swift
var presentationStyle: PresentationStyle = .withinNavigationView
```

### `paymentSelectionHeader`

Appears at the top of the payment selection screen. Also set `paymentSelectionHeaderHeight` when
using this property.

``` swift
var paymentSelectionHeader: UIView?
```

### `paymentSelectionHeaderHeight`

Default:​ zero. Set this to more than zero when using the `paymentSelectionHeader`.

``` swift
var paymentSelectionHeaderHeight: CGFloat = 0
```

### `paymentSelectionFooter`

Appears after all other controls on the payment selection screen. Also set `paymentSelectionFooterHeight` when
using this property.

``` swift
var paymentSelectionFooter: UIView?
```

### `paymentSelectionFooterHeight`

Default:​ zero. Set this to more than zero when using the `paymentSelectionFooter`.

``` swift
var paymentSelectionFooterHeight: CGFloat = 0
```

## Methods

### `buildViewController()`

Returns a `UIViewController` for the Express UI workflow configured with the properties from this object.

``` swift
public func buildViewController() -> UIViewController
```
