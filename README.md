# spreedly-ios

The Spreedly mobile SDK for iOS simplifies your mobile application's integration with Spreedly by providing pre-built UIs for a quick start and low-level APIs deeper integrations.

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

# Integration
All integration options require a Spreedly account and an environment key. See [Create Your API Credentials](https://docs.spreedly.com/basics/credentials/#environment-key) for details.

## Installation
We recommend using [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) to integrate the Spreedly SDK with your project. The `Spreedly` pod provides basic, low-level APIs for custom integrations. The `SpreedlyCocoa` pod provides custom controls and the Spreedly Express workflow, a prebuild UI for collecting and selecting payment methods.

Add the following to your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):
```ruby
# Core SDK
pod 'Spreedly'

# Express prebuilt UIs and controls
pod 'SpreedlyCocoa' 
```

## Express
Collect and select payment methods including Apple Pay with the SDK's Express tools.

Use this integration if you want a ready-made UI that:
* Accepts cards, Apple Pay, and bank accounts (where available).
* Can display saved payment methods for reuse.
* Supports limited customization of headers, footers, and payment methods allowed.
* Displays full-screen view controllers to select or add payment methods.

### Add `Spreedly-env.plist` to your app target
When the `Spreedly-env.plist` file is present, it will be used to get values for the environment key and other configuration values. A template is located at `CocoaSample/Spreedly-env.plist`.

The file supports the following settings:
- `ENV_KEY` Your Spreedly environment key.
- `TEST` Yes/true if the app is non-production.
- `TEST_CARD_NUMBER` The card number passed to Spreedly when creating an Apple Pay payment method. 


### Set up an `ExpressBuilder` and launch the Express workflow
To send users into the Express workflow, initialize and configure an `ExpressBuilder` instance. Be sure to set the `didSelectPaymentMethod` property to receive the payment method token and dismiss the payment selection view controller.

```swift
// When used within your navigation stack
func showPaymentSelection() {
    var builder = ExpressBuilder()
    builder.didSelectPaymentMethod = { item in
        print("User wants to use a payment method with token: \(item.token)")
        
        // pop all the way back to this view controller
        self.navigationController?.popToViewController(self, animated: true) 
    }
    let express = builder.buildViewController()
    
    // present the Express workflow within the existing navigation stack
    navigationController?.show(express, sender: self) 
}

// When shown with a modal presentation
func showPaymentSelection() {
    var builder = ExpressBuilder()
    builder.didSelectPaymentMethod = { item in
        print("User wants to use a payment method with token: \(item.token)")
        
        // dismiss the modal
        self.dismiss(animated: true) 
    }
    builder.presentationStyle = .asModal
    let express = builder.buildViewController()
    
    // present the Express workflow via modal    
    present(express, animated: true) 
}
```

If you support Apple Pay for pay-ins, you must create and configure a `PKPaymentRequest` instance then set it on the `ExpressBuilder` instance.

```swift
let request = PKPaymentRequest()
request.merchantIdentifier = "merchant.com.your_company.app"
request.countryCode = "US"
request.currencyCode = "USD"
request.supportedNetworks = [.amex, .discover, .masterCard, .visa]
request.merchantCapabilities = [.capabilityCredit, .capabilityDebit]
request.paymentSummaryItems = [
    PKPaymentSummaryItem(label: "Amount", amount: NSDecimalNumber(string: "322.38"), type: .final),
    PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "32.24"), type: .final),
    PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "354.62"), type: .final)
]
let builder = ExpressBuilder()
builder.paymentRequest = request
``` 

## Custom with `SecureForm`
The `SecureForm` is a `UIView` useful for collecting payment method information on behalf of a view controller and handling the create payment method API call to Spreedly. It can be used as the base view in a Storyboard-backed scene and exposes all appropriate fields using `@IBOutlet`. 

The `SecureForm` expects to use some of the custom controls included with this SDK.
- `ValidatedTextField` - A `UITextField` which is aware of its validation state and visually displays that state with a changing background color and status icon.
- `SecureTextField` - A `ValidatedTextField` with the `secureText` method which returns its text contents as a `SpreedlySecureOpaqueString` giving sensitive data extra protection from inadvertent logging or printing.
- `CreditCardNumberTextField` - A `SecureTextField` which auto-formats card number input, displays a card brand icon for identified brands, and masks the content when the user is not interacting with it.
- `ExpirationPickerField` - A `ValidatedTextField` which allows the user to select a month and year using a `UIPickerView`.

## Full custom
If you prefer a completely customized payment method collection and selection experience, you can use the APIs within the `Spreedly` target for low-level interactions.

For example, to create a new credit card payment method with Spreedly, create and configure a `CreditCardInfo` instance then use the `SpreedlyClient` to send it to Spreedly.
```swift
let creditCard = CreditCardInfo()
creditCard.number = SpreedlySecureOpaqueStringBuilder.build(from: "4111111111111111")
creditCard.verificationValue = SpreedlySecureOpaqueStringBuilder.build(from: "987")
creditCard.month = 12
creditCard.year = 2030
creditCard.fullName = "Happy Cardholder"

let config = ClientConfiguration(envKey: "your_env_key")
let client: SpreedlyClient = ClientFactory.create(with: config)
client.createPaymentMethodFrom(creditCard: creditCard).subscribe(onSuccess: { transaction in
    if let errors = transaction.errors, errors.count > 0 {
        // handle the errors
    } else {
        let result: CreditCardResult = transaction.creditCard
        let token = result.token
        // send the token back to your server to perform a payment transaction 
    }
})
```

See the code documentation for SpreedlyClient for more information.
