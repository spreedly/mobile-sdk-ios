# Types

  - [SpreedlySecurityError](/reference/ios/SpreedlySecurityError)
  - [ClientConfiguration](/reference/ios/ClientConfiguration):
    Contains configuration values used by the SpreedlyClient implementation.
  - [ClientError](/reference/ios/ClientError)
  - [ClientFactory](/reference/ios/ClientFactory):
    Creator class for creating instances of SpreedlyClient
  - [CreditCardNumberTextField](/reference/ios/CreditCardNumberTextField):
    Handles credit card number input from the user.
  - [ExpirationPickerField](/reference/ios/ExpirationPickerField):
    A `UITextField` with `UIPickerView` spinners allowing the user to select a month and year.
  - [SecureForm](/reference/ios/SecureForm):
    Coordinates with form controls to collect user input, manage API calls with Spreedly, and validate inputs.
  - [SecureTextField](/reference/ios/SecureTextField):
    Allows this control to return it's text property as a SpreedlySecureOpaqueString.
    Recommended for use with card verification value.
  - [ValidationState](/reference/ios/ValidationState)
  - [ValidatedTextField](/reference/ios/ValidatedTextField):
    A UITextField which is aware of its validation state and updates its appearance commensurately.
  - [ApplePayHandler](/reference/ios/ApplePayHandler)
  - [ExpirationDate](/reference/ios/ExpirationDate)
  - [ExpressBuilder](/reference/ios/ExpressBuilder):
    ExpressBuilder is the entrypoint for the Express UI workflow.
  - [ExpressBuilder.PresentationStyle](/reference/ios/ExpressBuilder_PresentationStyle)
  - [ExpressContext](/reference/ios/ExpressContext)
  - [PaymentMethodItem](/reference/ios/PaymentMethodItem):
    Contains basic information about a payment method.
  - [SelectedPaymentMethod](/reference/ios/SelectedPaymentMethod):
    Contains data about the payment method selected by the user from the `PaymentSelectionViewController`.
  - [Address](/reference/ios/Address)
  - [Address.AddressType](/reference/ios/Address_AddressType)
  - [ApplePayInfo](/reference/ios/ApplePayInfo):
    A set of information used when creating an Apple Pay payment method with Spreedly.
  - [BankAccountType](/reference/ios/BankAccountType)
  - [BankAccountHolderType](/reference/ios/BankAccountHolderType)
  - [BankAccountInfo](/reference/ios/BankAccountInfo):
    A set of information used when creating a bank account payment method with Spreedly.
  - [CardBrand](/reference/ios/CardBrand):
    Card brands supported by Spreedly.
  - [CreditCardInfo](/reference/ios/CreditCardInfo):
    A set of information used when creating a credit card payment method with Spreedly.
  - [PaymentMethodInfo](/reference/ios/PaymentMethodInfo):
    A set of information used when creating payment methods with Spreedly.
  - [StorageState](/reference/ios/StorageState):
    The current state of a gateway, receiver or payment method in the Spreedly database.
  - [\_ObjCStorageState](/reference/ios/_ObjCStorageState):
    The current state of a gateway, receiver or payment method in the Spreedly database.
  - [PaymentMethodType](/reference/ios/PaymentMethodType)
  - [\_ObjCPaymentMethodType](/reference/ios/_ObjCPaymentMethodType)
  - [SpreedlyError](/reference/ios/SpreedlyError)
  - [PaymentMethodResult](/reference/ios/PaymentMethodResult):
    Contains information returned from Spreedly after attempting to create a payment method.
  - [CreditCardResult](/reference/ios/CreditCardResult):
    Contains information returned from Spreedly after attempting to create a credit card payment method.
  - [BankAccountResult](/reference/ios/BankAccountResult):
    Contains information returned from Spreedly after attempting to create a bank account payment method.
  - [ApplePayResult](/reference/ios/ApplePayResult):
    Contains information returned from Spreedly after attempting to create an Apple Pay payment method.
  - [Transaction](/reference/ios/Transaction):
    Contains response information and metadata pertaining to the payment method creation attempt.
  - [SingleTransactionSource](/reference/ios/SingleTransactionSource)
  - [SingleTransaction](/reference/ios/SingleTransaction):
    Represents a push style sequence containing one `Transaction` element.
  - [SpreedlySecureOpaqueStringBuilder](/reference/ios/SpreedlySecureOpaqueStringBuilder)
  - [SpreedlyThreeDSError](/reference/ios/SpreedlyThreeDSError)
  - [SpreedlyThreeDS](/reference/ios/SpreedlyThreeDS)
  - [SpreedlyThreeDSTransactionRequest](/reference/ios/SpreedlyThreeDSTransactionRequest)

# Protocols

  - [SpreedlyClient](/reference/ios/SpreedlyClient):
    A set of methods used to create payment methods and recache verification values.
    Returns single-element sequences of `Transaction` to be handled asynchronously.
  - [\_ObjCClient](/reference/ios/_ObjCClient):
    A set of methods used to create payment methods and recache verification values.
    Returns single-element sequences of `SPRTransaction` to be handled asynchronously.
  - [CreditCardNumberTextFieldDelegate](/reference/ios/CreditCardNumberTextFieldDelegate)
  - [SecureFormDelegate](/reference/ios/SecureFormDelegate):
    A set of methods that you use to receive successfully created payment methods from Spreedly and provide
    client configuration for that communication.
  - [ExpirationDateProvider](/reference/ios/ExpirationDateProvider)
  - [UITextFieldXIBLocalizable](/reference/ios/UITextFieldXIBLocalizable)
  - [XIBMultiLocalizable](/reference/ios/XIBMultiLocalizable)
  - [SpreedlySecureOpaqueString](/reference/ios/SpreedlySecureOpaqueString):
    A representation of a String where the content of that String is intentionally obscured both reminding the
    developer that it should be carefully handled and to limit the possibility of it being recorded in logs, dumps,
    or prints.
  - [SpreedlyThreeDSTransactionRequestDelegate](/reference/ios/SpreedlyThreeDSTransactionRequestDelegate)

# Global Typealiases

  - [PaymentCompletionHandler](/reference/ios/PaymentCompletionHandler)
  - [Metadata](/reference/ios/Metadata):
    Metadata key-value pairs (limit 25). Keys are limited to 50 characters.
    Values are limited to 500 characters and cannot contain compounding data types.
