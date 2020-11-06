# CreditCardResult

Contains information returned from Spreedly after attempting to create a credit card payment method.

``` swift
@objc(SPRCreditCardResult) public class CreditCardResult: PaymentMethodResult
```

## Inheritance

[`PaymentMethodResult`](/reference/ios/PaymentMethodResult)

## Properties

### `cardType`

The card brand, e.g., `visa`, `mastercard`.

``` swift
var cardType: String?
```

### `year`

The expiration year.

``` swift
var year: Int?
```

### `month`

The expiration month.

``` swift
var month: Int?
```

### `lastFourDigits`

The last four digits of the credit card number. This can be displayed to the user.

``` swift
var lastFourDigits: String?
```

### `firstSixDigits`

The first six digits of the credit card number. This can be displayed to the user.

``` swift
var firstSixDigits: String?
```

### `number`

The obscured credit card number, e.g., `XXXX-XXXX-XXXX-4444`.

``` swift
var number: String?
```

### `eligibleForCardUpdater`

``` swift
var eligibleForCardUpdater: Bool?
```

### `callbackUrl`

``` swift
var callbackUrl: String?
```

### `fingerprint`

``` swift
var fingerprint: String?
```

### `shortDescription`

``` swift
var shortDescription: String
```

### `_objCYear`

``` swift
var _objCYear: Int
```

### `_objcMonth`

``` swift
var _objcMonth: Int
```
