# ApplePayInfo

A set of information used when creating an Apple Pay payment method with Spreedly.

``` swift
public class ApplePayInfo: PaymentMethodInfo
```

## Inheritance

[`PaymentMethodInfo`](/reference/ios/PaymentMethodInfo)

## Initializers

### `init(payment:)`

``` swift
@objc public convenience init(payment: PKPayment)
```

### `init(paymentTokenData:)`

``` swift
@objc public init(paymentTokenData: Data)
```

### `init(copyFrom:payment:)`

Copies values from the given PaymentMethodInfo onto a new instance.

``` swift
public init(copyFrom info: PaymentMethodInfo?, payment: PKPayment)
```

## Properties

### `testCardNumber`

Set this to a [Spreedly test card number](https:​//docs.spreedly.com/reference/test-data/#credit-cards) when
testing Apple Pay.

``` swift
var testCardNumber: String?
```
