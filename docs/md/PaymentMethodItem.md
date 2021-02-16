# PaymentMethodItem

Contains basic information about a payment method.

``` swift
@objc(SPRPaymentMethodItem) public class PaymentMethodItem: NSObject
```

## Inheritance

`NSObject`

## Initializers

### `init(type:description:token:)`

``` swift
public init(type: PaymentMethodType, description: String, token: String)
```

### `init(type:cardBrand:description:token:)`

``` swift
public init(type: PaymentMethodType, cardBrand: CardBrand, description: String, token: String)
```

## Properties

### `type`

``` swift
let type: PaymentMethodType
```

### `shortDescription`

A very short description of the payment method displayable to the customer.

``` swift
let shortDescription: String
```

### `token`

Spreedly's payment method token.

``` swift
let token: String
```

### `cardBrand`

``` swift
var cardBrand: CardBrand?
```

### `_objCType`

``` swift
var _objCType: _ObjCPaymentMethodType
```
