# SecureFormDelegate

A set of methods that you use to receive successfully created payment methods from Spreedly and provide
client configuration for that communication.

``` swift
@objc(SPRSecureFormDelegate) public protocol SecureFormDelegate: class
```

## Inheritance

`class`

## Requirements

### spreedly(secureForm:​success:​)

Tells the delegate that a payment methods was successfully created.

``` swift
func spreedly(secureForm: SecureForm, success: Transaction)
```

## Optional Requirements

### willCallSpreedly(secureForm:​)

Tells the delegate that a network call will be made. Useful for starting an activity spinner.

``` swift
@objc optional func willCallSpreedly(secureForm: SecureForm)
```

### didCallSpreedly(secureForm:​)

Tells the delegate that a network call completed. Useful for stopping an activity spinner.

``` swift
@objc optional func didCallSpreedly(secureForm: SecureForm)
```

### clientConfiguration(secureForm:​)

Returns a `ClientConfiguration` to use rather than using the values from `Spreedly-env.plist`
from the main bundle.

``` swift
@objc optional func clientConfiguration(secureForm: SecureForm) -> ClientConfiguration?
```
