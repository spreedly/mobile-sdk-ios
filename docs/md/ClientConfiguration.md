# ClientConfiguration

Contains configuration values used by the SpreedlyClient implementation.

``` swift
@objc(SPRClientConfiguration) public class ClientConfiguration: NSObject
```

  - envKey: The [environment key](https://docs.spreedly.com/basics/credentials/#environment-key) is required for all communication with Spreedly.

  - envSecret: The environment secret is only used by integration tests and should not be set in production.

  - test: Set to true when the client will be used for testing to enable test-specific behaviors.

  - testCardNumber: When using Apple Pay, there is no way to request a test payment method from the Passkit framework. Instead, pass set this property to one of the above [test credit card numbers](https://docs.spreedly.com/reference/test-data/#credit-cards) and Spreedly will recognize it as a test payment method. This *only* applies when creating Apple Pay payment methods.

## Inheritance

`NSObject`

## Initializers

### `init(envKey:envSecret:test:testCardNumber:)`

``` swift
@objc public init(envKey: String, envSecret: String? = nil, test: Bool = false, testCardNumber: String? = nil)
```

## Properties

### `envKey`

Spreedly environment key

``` swift
let envKey: String
```

### `envSecret`

Spreedly environment secret. Only used in integration tests.

``` swift
let envSecret: String?
```

### `test`

Test-mode flag.

``` swift
let test: Bool
```

### `testCardNumber`

Card number used when in test-mode when creating Apple Pay payment methods.

``` swift
let testCardNumber: String?
```

## Methods

### `getConfiguration()`

Attempts to read values from `Spreedly-env.plist` in the main bundle and returns a ClientConfiguration
initialized with the values therein.

``` swift
@objc public static func getConfiguration() throws -> ClientConfiguration
```

#### Throws

`ClientError.noSpreedlyCredentials` Spreedly-env.plist file cannot be found or it does not contain an `ENV_KEY` entry with a value.
