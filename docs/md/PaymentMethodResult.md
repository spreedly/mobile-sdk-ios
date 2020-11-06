# PaymentMethodResult

Contains information returned from Spreedly after attempting to create a payment method.

``` swift
@objc(SPRPaymentMethodResultBase) public class PaymentMethodResult: NSObject
```

## Inheritance

`NSObject`

## Properties

### `token`

The token identifying the newly created payment method in the Spreedly vault.

``` swift
let token: String?
```

### `storageState`

The storage state of the payment method.

``` swift
let storageState: StorageState?
```

### `test`

`true` if this payment method is a test payment method and cannot be used against real gateways or receivers.

``` swift
let test: Bool
```

### `paymentMethodType`

The type of this payment method (e.g., `creditCard`, `bankAccount`, `applePay`).

``` swift
let paymentMethodType: PaymentMethodType?
```

### `email`

``` swift
let email: String?
```

### `firstName`

``` swift
let firstName: String?
```

### `lastName`

``` swift
let lastName: String?
```

### `fullName`

``` swift
let fullName: String?
```

### `company`

``` swift
let company: String?
```

### `address`

``` swift
let address: Address?
```

### `shippingAddress`

``` swift
let shippingAddress: Address?
```

### `errors`

If the payment method is invalid (missing required fields, etc), there will be associated error messages here.

``` swift
let errors: [SpreedlyError]
```

### `metadata`

``` swift
let metadata: Metadata?
```

### `shortDescription`

A brief description displayable to the user.

``` swift
var shortDescription: String
```

### `_objCPaymentMethodType`

``` swift
var _objCPaymentMethodType: _ObjCPaymentMethodType
```

### `_objCStorageState`

``` swift
var _objCStorageState: _ObjCStorageState
```
