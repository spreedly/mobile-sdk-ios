# SpreedlySecureOpaqueString

A representation of a String where the content of that String is intentionally obscured both reminding the
developer that it should be carefully handled and to limit the possibility of it being recorded in logs, dumps,
or prints.

``` swift
@objc(SPRSecureOpaqueString) public protocol SpreedlySecureOpaqueString
```

## Requirements

### clear()

Clears the content.

``` swift
func clear()
```

### append(\_:​)

Appends the given String to the content.

``` swift
func append(_ string: String)
```

### removeLastCharacter()

Removes the last character from the content.

``` swift
func removeLastCharacter()
```
