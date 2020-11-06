# ValidatedTextField

A UITextField which is aware of its validation state and updates its appearance commensurately.

``` swift
@objc(SPRValidatedTextField) open class ValidatedTextField: UITextField
```

## Inheritance

`UITextField`, `UITextFieldDelegate`

## Initializers

### `init?(coder:)`

``` swift
@objc public required init?(coder: NSCoder)
```

### `init(frame:)`

``` swift
@objc public override init(frame: CGRect)
```

## Properties

### `validationState`

Gets the current validation state.

``` swift
var validationState: ValidationState = .none
```

### `reason`

The reason this control is in error.

``` swift
var reason: String?
```

### `delegate`

``` swift
var delegate: UITextFieldDelegate?
```

## Methods

### `clearValidation()`

Puts the control into an undetermined validation state.

``` swift
@objc public func clearValidation()
```

### `setError(because:)`

Puts the control into an error state.

``` swift
@objc public func setError(because reason: String)
```

#### Parameters

  - reason: A human readable reason for the error.

### `setValid()`

Puts the control into a valid state.

``` swift
@objc public func setValid()
```

### `textField(_:shouldChangeCharactersIn:replacementString:)`

Any time the user causes the text to change, reset the validation state.

``` swift
@objc public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
```
