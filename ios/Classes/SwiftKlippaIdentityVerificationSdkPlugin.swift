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

        if let textColor = builderArgs["Colors.textColor"] as? String {
            builder.kivColors.textColor = hexColorToUIColor(hex: textColor)
        }

        if let backgroundColor = builderArgs["Colors.backgroundColor"] as? String {
            builder.kivColors.backgroundColor = hexColorToUIColor(hex: backgroundColor)
        }

        if let buttonSuccessColor = builderArgs["Colors.buttonSuccessColor"] as? String {
            builder.kivColors.buttonSuccessColor = hexColorToUIColor(hex: buttonSuccessColor)
        }

        if let buttonErrorColor = builderArgs["Colors.buttonErrorColor"] as? String {
            builder.kivColors.buttonErrorColor = hexColorToUIColor(hex: buttonErrorColor)
        }

        if let buttonOtherColor = builderArgs["Colors.buttonOtherColor"] as? String {
            builder.kivColors.buttonOtherColor = hexColorToUIColor(hex: buttonOtherColor)
        }

        if let progressBarBackground = builderArgs["Colors.progressBarBackground"] as? String {
            builder.kivColors.progressBarBackground = hexColorToUIColor(hex: progressBarBackground)
        }

        if let progressBarForeground = builderArgs["Colors.progressBarForeground"] as? String {
            builder.kivColors.progressBarForeground = hexColorToUIColor(hex: progressBarForeground)
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

        if let retryThreshold = builderArgs["RetryThreshold"] as? Int {
            builder.retryThreshold = retryThreshold
        }
        
        resultHandler = result
        let viewController = builder.build()

        let rootViewController = UIApplication.shared.windows.last!.rootViewController!
        rootViewController.present(viewController, animated:true, completion:nil)
    }
    
    private func hexColorToUIColor(hex: String) -> UIColor? {
        let r, g, b, a: CGFloat
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000ff) / 255
                
                return UIColor.init(red: r, green: g, blue: b, alpha: a)
            }
        }
        return nil
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
            case KlippaError.SessionToken:
                return "Invalid session token"
            case KlippaError.UserCanceled:
                return "User canceled session"
            case KlippaError.NoInternetConnection:
                return "No internet connection"
            default:
                return "The user canceled"
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
