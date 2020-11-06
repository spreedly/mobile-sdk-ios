# ExpressBuilder.PresentationStyle

``` swift
@objc(SPRPresentationStyle) public enum PresentationStyle
```

## Inheritance

`Int`

## Enumeration Cases

### `withinNavigationView`

Use this if the ExpressController will be part of an existing UINavigationController.

``` swift
case withinNavigationView
```

### `asModal`

Use this if the ExpressController will be shown own its own. The returned controller will be a
UINavigationController wrapping the ExpressController.

``` swift
case asModal
```
