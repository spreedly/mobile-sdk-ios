# BankAccountResult

Contains information returned from Spreedly after attempting to create a bank account payment method.

``` swift
@objc(SPRBankAccountResult) public class BankAccountResult: PaymentMethodResult
```

## Inheritance

[`PaymentMethodResult`](/reference/ios/PaymentMethodResult)

## Properties

### `bankName`

``` swift
var bankName: String?
```

### `accountType`

The type of account. Can be one of `checking` or `savings`.

``` swift
var accountType: BankAccountType = .unknown
```

### `accountHolderType`

The account holder type. Can be one of `business` or `personal`.

``` swift
var accountHolderType: BankAccountHolderType = .unknown
```

### `routingNumberDisplayDigits`

A portion of the routing number. Can be displayed to the user.

``` swift
var routingNumberDisplayDigits: String?
```

### `accountNumberDisplayDigits`

A portion of the account number. Can be displayed to the user.

``` swift
var accountNumberDisplayDigits: String?
```

### `routingNumber`

The account routing number.

``` swift
var routingNumber: String?
```

### `accountNumber`

The account number.

``` swift
var accountNumber: String?
```

### `shortDescription`

``` swift
var shortDescription: String
```
