# SelectedPaymentMethod

Contains data about the payment method selected by the user from the `PaymentSelectionViewController`.

``` swift
@objc(SPRSelectedPaymentMethod) public class SelectedPaymentMethod: NSObject
```

## Inheritance

`NSObject`

## Initializers

### `init(token:type:)`

``` swift
public init(token: String, type: PaymentMethodType)
```

## Properties

### `token`

Spreedly's payment method token

``` swift
let token: String
```

### `type`

The payment method type

``` swift
let type: PaymentMethodType
```

### `paymentMethod`

If the payment method was created by the user before selection, this will contain the payment method object.

``` swift
var paymentMethod: PaymentMethodResult?
```

### `_objCType`

The payment method type

``` swift
var _objCType: _ObjCPaymentMethodType
```
