# SpreedlyClient

A set of methods used to create payment methods and recache verification values.
Returns single-element sequences of `Transaction` to be handled asynchronously.

``` swift
public protocol SpreedlyClient
```

## Requirements

### createPaymentMethodFrom(creditCard:​)

Attempts to create a credit card payment method.

``` swift
func createPaymentMethodFrom(creditCard: CreditCardInfo) -> SingleTransaction
```

### createPaymentMethodFrom(bankAccount:​)

Attempts to create a bank account payment method.

``` swift
func createPaymentMethodFrom(bankAccount: BankAccountInfo) -> SingleTransaction
```

### recache(token:​verificationValue:​)

Attempts to recache the verification value for a payment method identified by the token.

``` swift
func recache(token: String, verificationValue: SpreedlySecureOpaqueString) -> SingleTransaction
```

### createPaymentMethodFrom(applePay:​)

Attempts to create an Apple Pay payment method.

``` swift
func createPaymentMethodFrom(applePay: ApplePayInfo) -> SingleTransaction
```
