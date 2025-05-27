import Flutter
import UIKit
import KlippaIdentityVerification

public class SwiftKlippaIdentityVerificationSdkPlugin: NSObject, FlutterPlugin, IdentityBuilderDelegate {
    private var resultHandler : FlutterResult? = nil
    private var E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
    private var E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
    private var E_CANCELED = "E_CANCELED"
    private var E_SUPPORT_PRESSED = "E_SUPPORT_PRESSED"
    private var E_UNKNOWN_ERROR = "E_UNKNOWN_ERROR"
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "klippa_identity_verification_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftKlippaIdentityVerificationSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "startSession" {
            startSession(call, result: result)
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
    
    private func startSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let builderArgs = call.arguments as? [String: Any] else {
            result(FlutterError.init(code: E_UNKNOWN_ERROR, message: "Unknown error", details: nil));
            return
        }

        guard let sessionToken = builderArgs["SessionToken"] as? String else {
            result(FlutterError.init(code: E_MISSING_SESSION_TOKEN, message: "Missing session token", details: nil));
            return
        }

        let builder = IdentityBuilder(builderDelegate: self, sessionKey: sessionToken)

        if let language = builderArgs["Language"] as? String {
            if (language == "KIVLanguage.English") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.English
            } else if (language == "KIVLanguage.Dutch") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.Dutch
            } else if (language == "KIVLanguage.Spanish") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.Spanish
            } else if (language == "KIVLanguage.German") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.German
            } else if (language == "KIVLanguage.French") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.French
            }
        }

        if let hasIntroScreen = builderArgs["HasIntroScreen"] as? Bool {
            builder.hasIntroScreen = hasIntroScreen
        }

        if let hasSuccessScreen = builderArgs["HasSuccessScreen"] as? Bool {
            builder.hasSuccessScreen = hasSuccessScreen
        }

        if let isDebug = builderArgs["IsDebug"] as? Bool {
            builder.isDebug = isDebug
        }

        if let enableAutoCapture = builderArgs["EnableAutoCapture"] as? Bool {
            builder.enableAutoCapture = enableAutoCapture
        }
        if let textColor = builderArgs["Colors.textColor"] as? String {
            builder.kivColors.textColor = UIColor(hexString: textColor) 
        }

        if let backgroundColor = builderArgs["Colors.backgroundColor"] as? String {
            builder.kivColors.backgroundColor = UIColor(hexString: backgroundColor)
        }

        if let buttonSuccessColor = builderArgs["Colors.buttonSuccessColor"] as? String {
            builder.kivColors.buttonSuccessColor = UIColor(hexString: buttonSuccessColor)
        }

        if let buttonErrorColor = builderArgs["Colors.buttonErrorColor"] as? String {
            builder.kivColors.buttonErrorColor = UIColor(hexString: buttonErrorColor)
        }

        if let buttonOtherColor = builderArgs["Colors.buttonOtherColor"] as? String {
            builder.kivColors.buttonOtherColor = UIColor(hexString: buttonOtherColor)
        }

        if let progressBarBackground = builderArgs["Colors.progressBarBackground"] as? String {
            builder.kivColors.progressBarBackground = UIColor(hexString: progressBarBackground)
        }

        if let progressBarForeground = builderArgs["Colors.progressBarForeground"] as? String {
            builder.kivColors.progressBarForeground = UIColor(hexString: progressBarForeground)
        }

        if let fontName = builderArgs["Fonts.fontName"] as? String {
            builder.kivFonts.fontName = fontName
        }

        if let boldFontName = builderArgs["Fonts.boldFontName"] as? String {
            builder.kivFonts.boldFontName = boldFontName
        }

        if let includeList = builderArgs["VerifyIncludeList"] as? [String] {
            builder.kivVerifyIncludeList = includeList
        }

        if let excludeList = builderArgs["VerifyExcludeList"] as? [String] {
            builder.kivVerifyExcludeList = excludeList
        }

        if let validationIncludeList = builderArgs["ValidationIncludeList"] as? [String] {
            builder.kivValidationIncludeList = validationIncludeList
        }

        if let validationExcludeList = builderArgs["ValidationExcludeList"] as? [String] {
            builder.kivValidationExcludeList = validationExcludeList
        }

        if let retryThreshold = builderArgs["RetryThreshold"] as? Int {
            builder.retryThreshold = retryThreshold
        }

        if let allowCameraOnNFCTask = builderArgs["AllowCameraOnNFCTask"] as? Bool {
            builder.allowCameraOnNFCTask = allowCameraOnNFCTask
        }

        if let exitOnRetryThresholdReached = builderArgs["ExitOnRetryThresholdReached"] as? Bool {
            builder.exitOnRetryThresholdReached = exitOnRetryThresholdReached
        }

        if let nfcTimeoutThreshold = builderArgs["NfcTimeoutThreshold"] as? Double {
            builder.nfcTimeoutThreshold = nfcTimeoutThreshold
        }
        
        resultHandler = result
        let viewController = builder.build()

        let rootViewController = UIApplication.shared.windows.last!.rootViewController!
        rootViewController.present(viewController, animated:true, completion:nil)
    }
    
    public func identityVerificationFinished() {
        let resultMap = Dictionary<String, Any>.init()
        resultHandler!(resultMap)
        resultHandler = nil;
    }

    public func identityVerificationCanceled(withError error: KlippaError) {

        let errorMessage: String = {
            switch error {
            case KlippaError.InsufficientPermissions:
                return "Insufficient permissions"
            case KlippaError.InputDeviceError:
                return "Invalid input device"
            case KlippaError.SessionToken:
                return "Invalid session token"
            case KlippaError.UserCanceled:
                return "User canceled session"
            case KlippaError.NoInternetConnection:
                return "No internet connection"
            case KlippaError.NfcNotSupported:
                return "NFC not supported"
            case KlippaError.AllowPictureFallbackDisabled:
                return "Allow Picture Fallback Disabled"
            case KlippaError.RetryLimitReached:
                return "Retry Limit Reached"
            }
        }()

        resultHandler!(FlutterError.init(code: E_CANCELED, message: errorMessage, details: nil));
        resultHandler = nil;
    }

    public func identityVerificationContactSupportPressed() {
        resultHandler!(FlutterError.init(code: E_SUPPORT_PRESSED, message: "The user pressed contact support", details: nil));
        resultHandler = nil;
    }

}

extension UIColor {
    convenience init(hexString: String) {
        var newString = hexString
        if newString.first != "#" {
            newString.insert("#", at: newString.startIndex)
        }
        let hex = newString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
