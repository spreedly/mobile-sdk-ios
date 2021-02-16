# CreditCardInfo

A set of information used when creating a credit card payment method with Spreedly.

``` swift
public class CreditCardInfo: PaymentMethodInfo
```

## Inheritance

[`PaymentMethodInfo`](/reference/ios/PaymentMethodInfo)

## Initializers

### `init()`

``` swift
@objc public override init()
```

### `init(copyFrom:)`

Copies values from the given CreditCardInfo or PaymentMethodInfo onto a new CreditCardInfo.
including `fullName`, `firstName`, `lastName`, `address`,
`shippingAddress`, `company`, `email`, and `metadata`.

``` swift
public override init(copyFrom info: PaymentMethodInfo?)
```

Card data is not copied.

#### Parameters

  - info: The source of the values.

## Properties

### `number`

``` swift
var number: SpreedlySecureOpaqueString?
```

### `verificationValue`

``` swift
var verificationValue: SpreedlySecureOpaqueString?
```

### `year`

Expiration year.

``` swift
var year: Int?
```

### `month`

Expiration month.

``` swift
var month: Int?
```

### `_objCYear`

Expiration year.

``` swift
var _objCYear: Int
```

### `_objCMonth`

Expiration month.

``` swift
var _objCMonth: Int
```
