# spreedly-ios

The Spreedly mobile SDK for iOS simplifies your mobile application's integration with Spreedly by providing pre-built UIs for a quick start and low-level APIs deeper integrations.

# Getting Started

## Installation

We recommend using CocoaPods to integrate the Spreedly SDK with your project. The `Spreedly` pod provides basic, low-level APIs for custom integrations. The `SpreedlyCocoa` pod provides custom controls and the Spreedly Express workflow, a prebuild UI for collecting and selecting payment methods.

### CocoaPods
```ruby
# Core SDK
pod 'Spreedly'

# Express prebuilt UIs and controls
pod 'SpreedlyCocoa' 
```

### Spreedly-env.plist
Add a file named `Spreedly-env.plist` to your app. An empty version of this file is available in `CocoaSample/Spreedly-env.plist`. The file supports the following settings:

- `ENV_KEY` Your Spreedly environment key.
- `TEST` Yes/true if the app is non-production.
- `TEST_CARD_NUMBER` The card number passed to Spreedly when creating an Apple Pay payment method. 

# Sample App
A sample app is included in the project. To run it:

1. Run `pod install` and then open `SpreedlySdk.xcworkspace` in XCode.
2. If desired, update the `CocoaSample/Spreedly-env.plist` file to contain your Spreedly environment key to enable creation of payment methods within the sample app.
3. Run the `CocoaSample` scheme. 

## Check Status

|  |  |
| -----:| --- | 
Spreedly Build | ![Build](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Build%20Libraries&branch=master)
Spreedly Tests | ![Tests](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Run%20Tests&branch=master)
Sample App Build | ![Sample](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Build%20Sdk%20Sample&branch=master)
Lint | ![Lint](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Lint%20check%20sources&branch=master)

## Targets

* Spreedly - The core library. Includes the Spreedly client and all APIs necessary for a custom integration.
* SpreedlyCocoa - UI specific library. Includes custom controls and the Express iOS controllers.
* UnitTests - Unit tests for Spreedly and SpreedlyCocoa.
* IntegrationTests - Integration tests making API calls to Spreedly.
* CocoaSample - The sample app demonstrating the custom controls and Express features.

# Contributing

## Cirrus CI

This repository is setup to run builds, tests, and linting using [Cirrus CI](https://cirrus-ci.org/). 

## Tests
Run tests from the command line with `make test` or with Xcode by choosing the `Spreedly` scheme and running Product -> Test. 

## Test Coverage
The `Spreedly` scheme is configured to include coverage metrics with the test runs. This can be viewed within Xcode by running the tests on the `Spreedly` scheme, then navigating to the Report navigator and finding the `Coverage` report. 

Test coverage metrics are also available from the command line using [Slather](https://github.com/SlatherOrg/slather) with:
```shell script
make coverage
``` 

View the coverage results locally with:
To open the results locally:
```shell script
open ./slather-html/index.html
```

A coverage report is regularly posted:
* [master](https://ergonlabs.github.io/spreedly-docs/coverage/master/core-sdk/ios/index.html)
* [latest branch](https://ergonlabs.github.io/spreedly-docs/coverage/pr/core-sdk/ios/index.html)

## Linting
Run `make lint` to do a lint check locally using [SwiftLint](https://github.com/realm/SwiftLint).

