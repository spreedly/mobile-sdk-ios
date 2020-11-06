# ClientFactory

Creator class for creating instances of SpreedlyClient

``` swift
@objc(SPRClientFactory) public class ClientFactory: NSObject
```

## Inheritance

`NSObject`

## Methods

### `create(with:)`

Creates a concrete instance of a `SpreedlyClient` using the given `ClientConfiguration`.

``` swift
public static func create(with config: ClientConfiguration) -> SpreedlyClient
```

### `_objCCreate(with:)`

Creates a concrete instance of a `SpreedlyClient` using the given `ClientConfiguration`.

``` swift
@objc(createWithConfig) public static func _objCCreate(with config: ClientConfiguration) -> _ObjCClient
```
