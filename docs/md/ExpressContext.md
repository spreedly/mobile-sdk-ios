# ExpressContext

``` swift
@objc(SPRExpressContext) public class ExpressContext: NSObject
```

## Inheritance

`NSObject`

## Properties

### `clientConfiguration`

``` swift
var clientConfiguration: ClientConfiguration?
```

### `paymentMethods`

``` swift
var paymentMethods: [PaymentMethodItem]?
```

### `allowCard`

``` swift
var allowCard = true
```

### `allowBankAccount`

``` swift
var allowBankAccount = false
```

### `allowApplePay`

``` swift
var allowApplePay = true
```

### `didSelectPaymentMethod`

``` swift
var didSelectPaymentMethod: ((SelectedPaymentMethod) -> Void)?
```

### `paymentMethodDefaults`

``` swift
var paymentMethodDefaults: PaymentMethodInfo?
```

### `creditCardDefaults`

``` swift
var creditCardDefaults: CreditCardInfo?
```

### `bankAccountDefaults`

``` swift
var bankAccountDefaults: BankAccountInfo?
```

### `applePayDefaults`

``` swift
var applePayDefaults: PaymentMethodInfo?
```

### `paymentRequest`

``` swift
var paymentRequest: PKPaymentRequest?
```

### `paymentSelectionHeader`

``` swift
var paymentSelectionHeader: UIView?
```

### `paymentSelectionHeaderHeight`

``` swift
var paymentSelectionHeaderHeight: CGFloat = 0
```

### `paymentSelectionFooter`

``` swift
var paymentSelectionFooter: UIView?
```

### `paymentSelectionFooterHeight`

``` swift
var paymentSelectionFooterHeight: CGFloat = 0
```

### `fullNamePaymentMethod`

``` swift
var fullNamePaymentMethod: String?
```

### `fullNameCreditCard`

``` swift
var fullNameCreditCard: String?
```

### `fullNameBankAccount`

``` swift
var fullNameBankAccount: String?
```

### `fullNameApplePay`

``` swift
var fullNameApplePay: String?
```
