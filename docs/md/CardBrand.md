# CardBrand

Card brands supported by Spreedly.

``` swift
public enum CardBrand
```

## Inheritance

`String`

## Enumeration Cases

### `alelo`

``` swift
case alelo
```

### `amex`

``` swift
case amex
```

### `cabal`

``` swift
case cabal
```

### `carnet`

``` swift
case carnet
```

### `dankort`

``` swift
case dankort
```

### `dinersClub`

``` swift
case dinersClub
```

### `discover`

``` swift
case discover
```

### `elo`

``` swift
case elo
```

### `forbrubsforeningen`

``` swift
case forbrubsforeningen
```

### `jcb`

``` swift
case jcb
```

### `maestro`

``` swift
case maestro
```

### `mastercard`

``` swift
case mastercard
```

### `naranja`

``` swift
case naranja
```

### `sodexo`

``` swift
case sodexo
```

### `unionpay`

``` swift
case unionpay
```

### `visa`

``` swift
case visa
```

### `vr`

``` swift
case vr
```

### `unknown`

``` swift
case unknown
```

## Properties

### `maxLength`

The maximum count of digits allowed by the card brand.

``` swift
var maxLength: Int
```

## Methods

### `from(_:)`

Parses the given string determining and returning the appropriate brand, otherwise `.unknown`.

``` swift
public static func from(_ number: String?) -> CardBrand
```

### `from(spreedlyType:)`

Parses the given Spreedly-style (snake case) brand name string returning the appropriate brand, otherwise
`CardBrand.unknown`.

``` swift
public static func from(spreedlyType: String?) -> CardBrand
```
