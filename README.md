![Swift](https://github.com/ergonlabs/spreedly-ios/workflows/Swift/badge.svg?branch=master)

# spreedly-ios

This is the Spreedly mobile SDK for iOS.

## Targets

* Sdk - The core library.
* SdkTests - the tests for the core library.

## Github CI

This repository is setup to run github actions that will build Sdk, run SdkTests, and lint check Sdk.

## Lint

Run `./lint.sh` to do a lint check locally.

# Coverage

A coverage report is regularly posted:

* [master](https://ergonlabs.github.io/spreedly-docs/coverage/master/core-sdk/ios/index.html).
* [latest branch](https://ergonlabs.github.io/spreedly-docs/coverage/pr/core-sdk/ios/index.html).

To see this locally run:

    make coverage

Then open [build/api-wrapper/reports/jacoco/test/html/index.html](build/api-wrapper/reports/jacoco/test/html/index.html)
