# spreedly-ios

This is the Spreedly mobile SDK for iOS.

## Check Status

|  |  |
| -----:| --- | 
Core Sdk Build | ![Build](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Build%20Libraries&branch=master)
Core Sdk Tests | ![Tests](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Run%20Tests&branch=master)
Sample App Build | ![Sample](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Build%20Sdk%20Sample&branch=master)
Lint | ![Lint](https://api.cirrus-ci.com/github/ergonlabs/spreedly-ios.svg?test=Lint%20check%20sources&branch=master)

## Targets

* CoreSdk - The core library. Includes the Spreedly client and all APIs necessary for a custom integration.
* CocoaSdk - UI specific library. Includes custom controls and the Express iOS controllers.
* SdkTests - Unit tests for CoreSdk and CocoaSdk.
* SdkIntegrationTests - Integration tests making API calls to Spreedly.
* CocoaSample - The sample app demonstrating the custom controls and Express features.

## Cirrus CI

This repository is setup to run builds, tests, and linting using [Cirrus CI](https://cirrus-ci.org/). 

## Lint

Run `./lint.sh` to do a lint check locally.

# Coverage

A coverage report is regularly posted:

* [master](https://ergonlabs.github.io/spreedly-docs/coverage/master/core-sdk/ios/index.html)
* [latest branch](https://ergonlabs.github.io/spreedly-docs/coverage/pr/core-sdk/ios/index.html)

To see this locally run:
```shell script
make coverage
```
To open the results locally:
```shell script
open ./slather-html/index.html
```
