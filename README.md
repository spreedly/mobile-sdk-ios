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

* Sdk - The core library.
* SdkTests - the tests for the core library.

## Github CI

This repository is setup to run github actions that will build Sdk, run SdkTests, and lint check Sdk.

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
