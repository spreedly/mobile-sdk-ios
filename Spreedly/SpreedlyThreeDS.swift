//
// Created by Stefan Rusek on 10/21/20.
//

import Foundation
import SDK3DS

public enum SpreedlyThreeDSError: Error {
    case invalidInput(message: String)
    case protocolError(message: String)
    case runtimeError(message: String)
    case unknownError(error: Error)
}

public class SpreedlyThreeDS {
    static let _3ds2service: ThreeDS2Service = ThreeDS2ServiceImpl.sdk
    static var test: Bool!

    public static func initialize(uiViewController: UIViewController, locale: String = "en_US", test: Bool = false, theme: SpreedlyTheme? = nil) throws {
        SpreedlyThreeDS.test = test
        let config = ConfigParameters()
        try? config.addParam("CONF", "ENV", test ? "test" : "prod")
        let ui = theme.toSeglanTheme()
        do {
            try _3ds2service.initialize(uiViewController: uiViewController, configParameters: config, locale: locale, uiCustomization: ui)
        } catch SDK3DSError.InvalidInputException(let message) {
            throw SpreedlyThreeDSError.invalidInput(message: message)
        } catch SDK3DSError.SDKAlreadyInitializedException {
            ThreeDS2ServiceImpl.uiCustomization = ui
            print("ERROR Already init")
            return
        }
    }

    static func cardTypeToDirectoryServerId(_ cardType: String) -> String {
        switch (cardType) {
        case "visa":
            return "A000000003"
        case "master":
            return "A000000004"
        case "maestro":
            return "A000000005"
        case "american_express":
            return "A000000025"
        default:
            return "A000000003"
        }
    }

    /// Creates a transaction request that can be used to tell Spreedly that a 3DS2 challenge is supported.
    /// - Parameters:
    ///   - cardType: The name of the card time. see https://docs.spreedly.com/reference/supported-payment-methods/
    ///   - test: pass true for test transactions.
    public static func createTransactionRequest(cardType: String) throws -> SpreedlyThreeDSTransactionRequest {
        SpreedlyThreeDSTransactionRequest(_3ds2service, try _3ds2service.createTransaction(directoryServerID: cardTypeToDirectoryServerId(cardType), messageVersion: "2.1.0"))
    }
}

public protocol SpreedlyThreeDSTransactionRequestDelegate {
    func success(status: String)

    func cancelled()

    func timeout()

    func error(_ error: SpreedlyThreeDSError)
}

public class SpreedlyThreeDSTransactionRequest {

    let service: SDK3DS.ThreeDS2Service
    let transaction: SDK3DS.Transaction

    public var delegate: SpreedlyThreeDSTransactionRequestDelegate?

    public init(_ service: SDK3DS.ThreeDS2Service, _ transaction: SDK3DS.Transaction) {
        self.service = service
        self.transaction = transaction
    }

    public func serialize() -> String {
        let request = transaction.getAuthenticationRequestParameters()
        return (try? JSONSerialization.data(withJSONObject: [
            "sdk_app_id": request.getSDKAppID(),
            "sdk_enc_data": request.getDeviceData(),
            "sdk_ephem_pub_key": (try? JSONSerialization.jsonObject(with: request.sdkEphemeralPublicKey.data(using: .utf8)!, options: .allowFragments)) ?? "bad public key",
            "sdk_max_timeout": "15",
            "sdk_reference_number": request.sdkReferenceNumber,
            "sdk_trans_id": request.sdkTransactionID,
            "device_render_options": [
                "sdk_interface": "03",
                "sdk_ui_type": "01"
            ]
        ] as [String: Any]).base64EncodedString()) ?? ""
    }

    public func doChallenge(withScaAuthenticationJson auth: Data) {
        do {
            doChallenge(withScaAuthentication: try JSONSerialization.jsonObject(with: auth) as! [String: Any])
        } catch {
            DispatchQueue.main.async {
                self.delegate?.error(.invalidInput(message: "Bad sca_authentication JSON \(error)"))
            }
        }
    }

    public func doChallenge(withScaAuthentication auth: [String: Any]) {
        let parameters = SDK3DS.ChallengeParameters()
        do {
            parameters.threeDSServerTransactionID = try auth.string(for: "three_ds_server_trans_id")
            parameters.acsTransactionID = try auth.string(for: "acs_transaction_id")
            parameters.acsRefNumber = try auth.string(for: "acs_reference_number")
            parameters.acsSignedContent = try auth.string(for: "acs_signed_content")
        } catch {
            DispatchQueue.main.async {
                self.delegate?.error(.invalidInput(message: "Bad sca_authentication JSON \(error)"))
            }
            return
        }
        DispatchQueue.main.async {
            do {
                try self.transaction.doChallenge(challengeParameters: parameters, challengeStatusReceiver: self, timeout: 15)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.error(.unknownError(error: error))
                }
            }
        }
    }

}

extension SpreedlyThreeDSTransactionRequest: ChallengeStatusReceiver {

    public func completed(_ e: CompletionEvent) {
        DispatchQueue.main.async {
            self.delegate?.success(status: e.transactionStatus)
        }
    }

    public func cancelled() {
        DispatchQueue.main.async {
            self.delegate?.cancelled()
        }
    }

    public func timedout() {
        DispatchQueue.main.async {
            self.delegate?.timeout()
        }
    }

    public func protocolError(_ e: ProtocolErrorEvent) {
        DispatchQueue.main.async {
            self.delegate?.error(.protocolError(message: e.ErrorMsg.getErrorDescription()))
        }
    }

    public func runtimeError(_ e: RuntimeErrorEvent) {
        DispatchQueue.main.async {
            self.delegate?.error(.runtimeError(message: e.getErrorMessage()))
        }
    }
}

public class SpreedlyTheme {
    public var buttonCornerRadius: Int?
    public var buttonFontName: String?
    public var buttonFontSize: Int?
    public var buttonPositiveTextColor: String?
    public var buttonNeutralTextColor: String?
    public var buttonPositiveBackgroundColor: String?
    public var buttonNeutralBackgroundColor: String?

    public var toolbarColor: String?
    public var toolbarTextColor: String?
    public var toolbarHeaderText: String?
    public var toolbarButtonText: String?

    public var textFontName: String?
    public var textColor: String?
    public var textFontSize: Int?

    public var headingTextFontName: String?
    public var headingTextColor: String?
    public var headingTextFontSize: Int?

    public var textBoxBorderWidth: Int?
    public var textBoxBorderColor: String?
    public var textBoxCornerRadius: Int?
}

extension Optional where Wrapped: SpreedlyTheme {
    func toSeglanTheme() -> SDK3DS.UiCustomization {
        self?.toSeglanTheme() ?? UiCustomization()
    }
}

extension SpreedlyTheme {
    func toSeglanTheme() -> SDK3DS.UiCustomization {
        let ui = UiCustomization()

        if let button = toPositiveButton() {
            try? ui.setButtonCustomization(buttonCustomization: button, buttonType: .NEXT)
            try? ui.setButtonCustomization(buttonCustomization: button, buttonType: .CONTINUE)
            try? ui.setButtonCustomization(buttonCustomization: button, buttonType: .SUBMIT)
            try? ui.setButtonCustomization(buttonCustomization: button, buttonType: .VERIFY)
        }
        if let button = toNeutralButton() {
            try? ui.setButtonCustomization(buttonCustomization: button, buttonType: .CANCEL)
            try? ui.setButtonCustomization(buttonCustomization: button, buttonType: .RESEND)
        }
        if let label = toLabel() {
            try? ui.setLabelCustomization(labelCustomization: label)
        }
        if let textbox = toTextBox() {
            try? ui.setTextBoxCustomization(textBoxCustomization: textbox)
        }
        if let toolbar = toToolbar() {
            try? ui.setToolbarCustomization(toolbarCustomization: toolbar)
        }
        return ui
    }

    func toLabel() -> LabelCustomization? {
        guard headingTextColor != nil || headingTextFontName != nil || headingTextFontSize != nil || textColor != nil || textFontName != nil || textFontSize != nil else {
            return nil
        }

        let l = LabelCustomization()
        if let color = textColor {
            try? l.setTextColor(hexColorCode: color)
        }
        if let font = textFontName {
            try? l.setTextFontName(fontName: font)
        }
        if let size = textFontSize {
            try? l.setTextFontSize(fontSize: size)
        }
        if let color = headingTextColor {
            try? l.setHeadingTextColor(hexColorCode: color)
        }
        if let font = headingTextFontName {
            try? l.setHeadingTextFontName(fontName: font)
        }
        if let size = headingTextFontSize {
            try? l.setHeadingTextFontSize(fontSize: size)
        }
        return l
    }

    func toToolbar() -> ToolbarCustomization? {
        guard toolbarButtonText != nil || toolbarHeaderText != nil || toolbarColor != nil || toolbarTextColor != nil || textFontName != nil || textFontSize != nil else {
            return nil
        }

        let l = ToolbarCustomization()
        if let color = toolbarTextColor {
            try? l.setTextColor(hexColorCode: color)
        }
        if let font = textFontName {
            try? l.setTextFontName(fontName: font)
        }
        if let size = textFontSize {
            try? l.setTextFontSize(fontSize: size)
        }
        if let color = toolbarColor {
            try? l.setBackgroundColor(hexColorCode: color)
        }
        if let text = toolbarButtonText {
            try? l.setButtonText(buttonText: text)
        }
        if let text = toolbarHeaderText {
            try? l.setHeaderText(headerText: text)
        }
        return l
    }

    func toTextBox() -> TextBoxCustomization? {
        guard textBoxBorderColor != nil || textBoxBorderWidth != nil || textBoxCornerRadius != nil || textColor != nil || textFontName != nil || textFontSize != nil else {
            return nil
        }

        let l = TextBoxCustomization()
        if let color = textColor {
            try? l.setTextColor(hexColorCode: color)
        }
        if let font = textFontName {
            try? l.setTextFontName(fontName: font)
        }
        if let size = textFontSize {
            try? l.setTextFontSize(fontSize: size)
        }
        if let color = textBoxBorderColor {
            try? l.setBorderColor(hexColorCode: color)
        }
        if let width = textBoxBorderWidth {
            try? l.setBorderWidth(borderWidth: width)
        }
        if let radius = textBoxCornerRadius {
            try? l.setCornerRadius(cornerRadius: radius)
        }
        return l
    }

    func toPositiveButton() -> ButtonCustomization? {
        guard buttonCornerRadius != nil || buttonPositiveBackgroundColor != nil || buttonPositiveTextColor != nil || buttonFontName != nil || buttonFontSize != nil else {
            return nil
        }

        let b = ButtonCustomization()
        if let radius = buttonCornerRadius {
            try? b.setCornerRadius(cornerRadius: radius)
        }
        if let color = buttonPositiveTextColor {
            try? b.setTextColor(hexColorCode: color)
        }
        if let color = buttonPositiveBackgroundColor {
            try? b.setBackgroundColor(hexColorCode: color)
        }
        if let font = buttonFontName {
            try? b.setTextFontName(fontName: font)
        }
        if let size = buttonFontSize {
            try? b.setTextFontSize(fontSize: size)
        }
        return b
    }

    func toNeutralButton() -> ButtonCustomization? {
        guard buttonCornerRadius != nil || buttonNeutralBackgroundColor != nil || buttonNeutralTextColor != nil || buttonFontName != nil || buttonFontSize != nil else {
            return nil
        }

        let b = ButtonCustomization()
        if let radius = buttonCornerRadius {
           try?  b.setCornerRadius(cornerRadius: radius)
        }
        if let color = buttonNeutralTextColor {
           try?  b.setTextColor(hexColorCode: color)
        }
        if let color = buttonNeutralBackgroundColor {
            try? b.setBackgroundColor(hexColorCode: color)
        }
        if let font = buttonFontName {
            try? b.setTextFontName(fontName: font)
        }
        if let size = buttonFontSize {
            try? b.setTextFontSize(fontSize: size)
        }
        return b
    }
}
