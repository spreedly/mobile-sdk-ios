# CreditCardNumberTextFieldDelegate

``` swift
public protocol CreditCardNumberTextFieldDelegate: class
```

## Inheritance

`class`

## Requirements

### cardBrandDetermined(brand:​)

Called whenever the card brand is determined based on the `CreditCardNumberTextField` content. May be
called many times.

``` swift
func cardBrandDetermined(brand: CardBrand)
```
