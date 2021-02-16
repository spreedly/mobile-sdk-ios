# BankAccountInfo

A set of information used when creating a bank account payment method with Spreedly.

``` swift
public class BankAccountInfo: PaymentMethodInfo
```

## Inheritance

[`PaymentMethodInfo`](/reference/ios/PaymentMethodInfo)

## Initializers

### `init()`

``` swift
@objc public override init()
```

### `init(copyFrom:)`

Copies values from the given BankAccountInfo or PaymentMethodInfo onto a new BankAccountInfo.
including `fullName`, `firstName`, `lastName`, `address`,
`shippingAddress`, `company`, `email`, `metadata`,
`bankAccountType`, and `bankAccountHolderType`.

``` swift
public override init(copyFrom info: PaymentMethodInfo?)
```

Account data is not copied.

#### Parameters

  - info: The source of the values.

## Properties

### `routingNumber`

``` swift
var routingNumber: String?
```

### `accountNumber`

``` swift
var accountNumber: SpreedlySecureOpaqueString?
```

### `accountType`

Default:​ .unknown

``` swift
var accountType: BankAccountType = .unknown
```

### `accountHolderType`

Default:​ .unknown

``` swift
var accountHolderType: BankAccountHolderType = .unknown
```
