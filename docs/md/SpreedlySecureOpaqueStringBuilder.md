# SpreedlySecureOpaqueStringBuilder

``` swift
@objc(SPRSecureOpaqueStringBuilder) public class SpreedlySecureOpaqueStringBuilder: NSObject
```

## Inheritance

`NSObject`

## Methods

### `build(from:)`

Builds an instance of `SpreedlySecureOpaqueString` from the given string.
Returns nil if the given string was nil.

``` swift
@objc public static func build(from string: String?) -> SpreedlySecureOpaqueString
```
