# SingleTransaction

Represents a push style sequence containing one `Transaction` element.

``` swift
@objc(SPRSingleTransaction) public class SingleTransaction: NSObject
```

## Inheritance

`NSObject`

## Initializers

### `init(source:)`

``` swift
public init(source: SingleTransactionSource)
```

## Methods

### `subscribe(onSuccess:onError:)`

Subscribes a success and error handler for this transaction.

``` swift
@objc public func subscribe(onSuccess: ((Transaction) -> Void)?, onError: ((Error) -> Void)? = nil)
```
