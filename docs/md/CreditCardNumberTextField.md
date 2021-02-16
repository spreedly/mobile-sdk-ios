# CreditCardNumberTextField

Handles credit card number input from the user.

``` swift
@objc(SPRCreditCardNumberTextField) open class CreditCardNumberTextField: SecureTextField
```

Only accepts numbers. When input matches a known card brand pattern, input will be limited to the max allowable
characters for that brand and shows the brand icon at the trailing edge. Formats the input into number groups
while the user types. Unless editing, the field's content will be masked with the `maskCharacter` showing only
the last four digits.

## Inheritance

[`SecureTextField`](/reference/ios/SecureTextField)

## Initializers

### `init(frame:)`

``` swift
@objc public override init(frame: CGRect)
```

### `init?(coder:)`

``` swift
@objc public required init?(coder: NSCoder)
```

## Properties

### `maskCharacter`

Character used for masking initial numbers. Default is "\*" (asterisk).

``` swift
var maskCharacter: String = "*"
```

### `cardNumberTextFieldDelegate`

Use the delegate to be notified whenever the card brand is determined.

``` swift
var cardNumberTextFieldDelegate: CreditCardNumberTextFieldDelegate?
```

## Methods

### `secureText()`

``` swift
public override func secureText() -> SpreedlySecureOpaqueString?
```

### `formatCardNumber(_:)`

Formats the card number input to match the card brand's pattern.

``` swift
open func formatCardNumber(_ string: String) -> String
```

### `textFieldDidEndEditing(_:reason:)`

``` swift
@objc open func textFieldDidEndEditing(_ textField: UITextField, reason: DidEndEditingReason)
```

### `textFieldDidBeginEditing(_:)`

``` swift
@objc open func textFieldDidBeginEditing(_ textField: UITextField)
```

### `generateMasked(from:)`

Masks all digits except the last four with `maskCharacter`.

``` swift
open func generateMasked(from string: String) -> String
```

### `textField(_:shouldChangeCharactersIn:replacementString:)`

``` swift
open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
```
