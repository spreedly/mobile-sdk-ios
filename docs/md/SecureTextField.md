# SecureTextField

Allows this control to return it's text property as a SpreedlySecureOpaqueString.
Recommended for use with card verification value.

``` swift
@objc(SPRSecureTextField) open class SecureTextField: ValidatedTextField
```

## Inheritance

[`ValidatedTextField`](/reference/ios/ValidatedTextField)

## Methods

### `secureText()`

Returns the text value of this field as a SpreedlySecureOpaqueString.

``` swift
@objc public func secureText() -> SpreedlySecureOpaqueString?
```
