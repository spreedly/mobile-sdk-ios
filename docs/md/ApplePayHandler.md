# ApplePayHandler

``` swift
@objc(SPRApplePayHandler) public class ApplePayHandler: NSObject
```

## Inheritance

`NSObject`, `PKPaymentAuthorizationControllerDelegate`

## Initializers

### `init(client:defaults:)`

``` swift
public init(client: SpreedlyClient, defaults: PaymentMethodInfo? = nil)
```

### `init(client:)`

``` swift
@objc public init(client: _ObjCClient)
```

## Methods

### `startPayment(request:completion:)`

``` swift
@objc public func startPayment(request: PKPaymentRequest, completion: @escaping PaymentCompletionHandler)
```

### `paymentAuthorizationController(_:didAuthorizePayment:completion:)`

``` swift
public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void)
```

### `paymentAuthorizationControllerDidFinish(_:)`

``` swift
public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController)
```
