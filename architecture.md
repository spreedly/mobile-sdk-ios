# Architecture

This document describes the high-level architecture of the Spreedly iOS SDK.
If you want to familiarize yourself with the code base, you are just in the right place!

## Bird's Eye View

On the highest level, the sdks is broken into 4 libraries. 2 libraries that build on each other and a [3D Secure library](https://github.com/spreedly/spreedly-ios-3ds).

The `Spreedly` provides the communication faoundation for the rest of the library. It provides no UI, and the `SpreedlyCocoa` library provide UI commonents for use on iOS.

## Code Map

This section talks briefly about various important directories and data structures. 

### `Spreedly`

This library provides the communications functionality for talking with the Spreedly back-end servers. There are a couple of important to understand design decisions about this library.

* Not ios specific. This library is just a platform independent swift library. This makes testing easier and enables it to be used in non ios situations.
* Supports both anonymous and authenticated transactions. While the publicly exposed functionality only uses the API end-points that support anonymous transactions, internally the library handles both. This enables future expansion, and also enabled a more comprehensive test setup.

### `SpreedlyCocoa`

### `SpreedlyCocoa/Controls`

This is a set of base UI components that integrate with the `Spreedly` library. If you were to build your own UI in iOS for doing spreedly transactions, this would not be a bad place to start.

The most important class here is `SecureForm`, which can be used to contain your payment forms. The `SecureForm` exposes `@IBOutlet` to bind field views to populate spreedly transactions.

### `SpreedlyCocoa/Express`

See README.md or the saple app for examples of how to use the `Express` UI.

This library used the `Spreedly` library to expose an easy to use UI framework to quickly add payment capabilities to an iOS app.

### `docs`

This directory contains html files generated from the swift docs throughout the projects.

### `CocoaSample`

This is an ios app that provides the ability to test and demonstrate all aspects of the above libraries.

NOTE: A copy of this directory lives in [the 3DS library](https://github.com/spreedly/spreedly-android-3ds) and a [repository by itself](https://github.com/spreedly/spreedly-android-sample). This is to enable testing the 3ds library and the use of the libraries via dependencies.

### `podspec`

This contains templates used during package publication to generate the podspec files for the libraries. See the [makefile](https://github.com/spreedly/mobile-sdk-ios/blob/master/Makefile) for how this is done.

### `UnitTests` and `IntegrationTests`

Contain automated tests.

## Cross-Cutting Concerns

This sections talks about the things which are everywhere and nowhere in particular.

### 3D Secure

This live in a [separate repository](https://github.com/spreedly/spreedly-ios-3ds). Originally all of these libraries were developed together in one repository. This means the sample app lives here, there, and in a standalone repository. The stand-alone repository exists mainly to test pulling all the libraries in as gradle dependencies rather than as peer libraries.

### Testing

There are unit and integration tests for the entire core library. However there is little automated testing for the UI components.
