# \_ObjCClient

A set of methods used to create payment methods and recache verification values.
Returns single-element sequences of `SPRTransaction` to be handled asynchronously.

``` swift
@objc(SPRClient) public protocol _ObjCClient
```

## Requirements

### \_objCCreatePaymentMethod(from:​)

Attempts to create a payment method.

``` swift
@objc(createPaymentMethodFrom) func _objCCreatePaymentMethod(from: PaymentMethodInfo) -> SingleTransaction
```

### \_objCRecache(token:​verificationValue:​)

Attempts to recache the verification value for a payment method identified by the token.

``` swift
@objc(recacheWithToken: verificationValue:) func _objCRecache(token: String, verificationValue: SpreedlySecureOpaqueString) -> SingleTransaction
```
