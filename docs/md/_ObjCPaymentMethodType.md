# \_ObjCPaymentMethodType

``` swift
@objc(SPRPaymentMethodType) public enum _ObjCPaymentMethodType
```

## Inheritance

`Int`

## Enumeration Cases

### `unknown`

``` swift
case unknown
```

### `creditCard`

``` swift
case creditCard
```

### `bankAccount`

``` swift
case bankAccount
```

### `applePay`

``` swift
case applePay
```

### `googlePay`

``` swift
case googlePay
```

### `thirdPartyToken`

``` swift
case thirdPartyToken
```

## Methods

### `from(_:)`

``` swift
public static func from(_ source: PaymentMethodType?) -> _ObjCPaymentMethodType
```
