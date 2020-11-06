# PaymentMethodInfo

A set of information used when creating payment methods with Spreedly.

``` swift
public class PaymentMethodInfo: NSObject
```

## Inheritance

`NSObject`

## Initializers

### `init()`

``` swift
@objc public override init()
```

### `init(copyFrom:)`

Copies values from the given PaymentMethodInfo into a new instance.

``` swift
public init(copyFrom info: PaymentMethodInfo?)
```

## Properties

### `email`

``` swift
var email: String?
```

### `metadata`

``` swift
var metadata: Metadata?
```

### `fullName`

``` swift
var fullName: String?
```

### `firstName`

``` swift
var firstName: String?
```

### `lastName`

``` swift
var lastName: String?
```

### `company`

``` swift
var company: String?
```

### `address`

When provided, will pass `address1`, `address2`, `city`, `state`, `zip`, `country`,
and `phone_number` properties to Spreedly when creating a payment method from this object.

``` swift
var address: Address
```

### `shippingAddress`

When provided, will pass `shipping_address1`, `shipping_address2`, `shipping_city`, `shipping_state`,
`shipping_zip`, `shipping_country`, and `shipping_phone_number` properties to Spreedly
when creating a payment method from this object.

``` swift
var shippingAddress: Address
```

### `retained`

When true, an authenticated request must be sent to the server including both the
environment key and secret.

``` swift
var retained: Bool?
```
