# SpreedlyThreeDSTransactionRequest

``` swift
public class SpreedlyThreeDSTransactionRequest
```

## Inheritance

`ChallengeStatusReceiver`

## Initializers

### `init(_:_:)`

``` swift
public init(_ service: SDK3DS.ThreeDS2Service, _ transaction: SDK3DS.Transaction)
```

## Properties

### `delegate`

``` swift
var delegate: SpreedlyThreeDSTransactionRequestDelegate?
```

## Methods

### `serialize()`

``` swift
public func serialize() -> String
```

### `doChallenge(withScaAuthenticationJson:)`

``` swift
public func doChallenge(withScaAuthenticationJson auth: Data)
```

### `doChallenge(withScaAuthentication:)`

``` swift
public func doChallenge(withScaAuthentication auth: [String: Any])
```

### `completed(_:)`

``` swift
public func completed(_ e: CompletionEvent)
```

### `cancelled()`

``` swift
public func cancelled()
```

### `timedout()`

``` swift
public func timedout()
```

### `protocolError(_:)`

``` swift
public func protocolError(_ e: ProtocolErrorEvent)
```

### `runtimeError(_:)`

``` swift
public func runtimeError(_ e: RuntimeErrorEvent)
```
