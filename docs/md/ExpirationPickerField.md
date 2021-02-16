# ExpirationPickerField

A `UITextField` with `UIPickerView` spinners allowing the user to select a month and year.

``` swift
@objc(SPRExpirationPickerField) public class ExpirationPickerField: ValidatedTextField
```

The month defaults to `01` and the year defaults to the current year.

## Inheritance

[`ValidatedTextField`](/reference/ios/ValidatedTextField), [`ExpirationDateProvider`](/reference/ios/ExpirationDateProvider), `UIPickerViewDataSource`, `UIPickerViewDelegate`

## Initializers

### `init()`

``` swift
@objc public init()
```

### `init?(coder:)`

``` swift
@objc public required init?(coder: NSCoder)
```

## Methods

### `showPicker()`

``` swift
@objc public func showPicker()
```

### `numberOfComponents(in:)`

``` swift
@objc public func numberOfComponents(in pickerView: UIPickerView) -> Int
```

### `pickerView(_:numberOfRowsInComponent:)`

``` swift
@objc public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
```

### `pickerView(_:titleForRow:forComponent:)`

``` swift
@objc public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
```

### `pickerView(_:didSelectRow:inComponent:)`

``` swift
@objc public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
```

### `expirationDate()`

``` swift
public func expirationDate() -> ExpirationDate?
```
