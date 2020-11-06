# Transaction

Contains response information and metadata pertaining to the payment method creation attempt.

``` swift
@objc(SPRTransaction) public class Transaction: NSObject
```

## Inheritance

`NSObject`

## Properties

### `token`

The token uniquely identifying this transaction (not the created payment method) at Spreedly.

``` swift
let token: String?
```

### `createdAt`

``` swift
let createdAt: Date?
```

### `updatedAt`

``` swift
let updatedAt: Date?
```

### `succeeded`

`true` if the transaction request was successfully executed, `false` otherwise.

``` swift
let succeeded: Bool
```

### `transactionType`

The type of transaction.

``` swift
let transactionType: String?
```

### `retained`

If the payment method was set to be automatically retained on creation

``` swift
let retained: Bool
```

### `state`

``` swift
let state: String?
```

### `messageKey`

``` swift
let messageKey: String
```

### `message`

A human-readable string indicating the result of the transaction.

``` swift
let message: String
```

### `errors`

If the transaction was unsuccessful, this array will contain error information.

``` swift
let errors: [SpreedlyError]?
```

### `paymentMethod`

Non-nil when the create transaction succeeds. Use the type-specific properties (`creditCard`, `bankAccount`,
`applePay`) for richer APIs.

``` swift
let paymentMethod: PaymentMethodResult?
```

### `creditCard`

Non-nil when the payment method created is a credit card.

``` swift
var creditCard: CreditCardResult?
```

### `bankAccount`

Non-nil when the payment method created is a bank account.

``` swift
var bankAccount: BankAccountResult?
```

### `applePay`

Non-nil when the payment method created is Apple Pay.

``` swift
var applePay: ApplePayResult?
```
