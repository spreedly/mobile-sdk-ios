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

    public static func initialize(uiViewController: UIViewController, locale: String = "en_US") throws {
        let config = ConfigParameters()
        do {
            try _3ds2service.initialize(uiViewController: uiViewController, configParameters: config, locale: locale, uiCustomization: nil)
        } catch SDK3DSError.InvalidInputException(let message) {
            throw SpreedlyThreeDSError.invalidInput(message: message)
        } catch SDK3DSError.SDKAlreadyInitializedException {
            print("ERROR Already init")
            return
        }
    }

    static func cardTypeToDirectoryServerId(_ cardType: String) -> String {
        switch (cardType) {
//        case "visa":
//            return "A000000003"
//        case "mastercard":
//            return "A000000004"
        default:
            return "F000000000"
        }
    }

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
                self.delegate?.error(.invalidInput(message: "Bad sca_authentication JSON"))
            }
        }
    }

    public func doChallenge(withScaAuthentication auth: [String: Any]) {
        let parameters = SDK3DS.ChallengeParameters()
        do {
            parameters.threeDSServerTransactionID = try auth.string(for: "xid")
            parameters.acsTransactionID = try auth.string(for: "acs_transaction_id")
            parameters.acsRefNumber = try auth.string(for: "acs_reference_number")
            parameters.acsSignedContent = try auth.string(for: "acs_signed_content")
        } catch {
            DispatchQueue.main.async {
                self.delegate?.error(.invalidInput(message: "Bad sca_authentication JSON"))
            }
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

