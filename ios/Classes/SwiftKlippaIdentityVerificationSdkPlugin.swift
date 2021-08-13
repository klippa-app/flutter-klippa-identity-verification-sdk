import Flutter
import UIKit
import KlippaIdentityVerification

public class SwiftKlippaIdentityVerificationSdkPlugin: NSObject, FlutterPlugin, IdentityBuilderDelegate {
    private var resultHandler : FlutterResult? = nil
    private var E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
    private var E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
    private var E_CANCELED = "E_CANCELED"
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
        guard let args = call.arguments else {
            result(FlutterError.init(code: E_UNKNOWN_ERROR, message: "Unknown error", details: nil));
            return
        }
        
        let builderArgs = args as? [String: Any]
        if (builderArgs?["SessionToken"] == nil) {
            result(FlutterError.init(code: E_MISSING_SESSION_TOKEN, message: "Missing session token", details: nil));
            return
        }
        
        let builder = IdentityBuilder(builderDelegate: self, sessionKey: builderArgs?["SessionToken"] as? String ?? "")
        
        if (builderArgs?["Language"] != nil) {
            let language = builderArgs?["Language"] as? String ?? ""
            if (language == "KIVLanguage.English") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.English
            } else if (language == "KIVLanguage.Dutch") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.Dutch
            } else if (language == "KIVLanguage.Spanish") {
                builder.kivLanguage = IdentityBuilder.KIVLanguage.Spanish
            }

        }
        
        if (builderArgs?["HasIntroScreen"] != nil) {
            let hasIntroScreen = builderArgs?["HasIntroScreen"] as? Bool ?? true
            builder.hasIntroScreen = hasIntroScreen
        }
        
        if (builderArgs?["HasSuccessScreen"] != nil) {
            let hasSuccessScreen = builderArgs?["HasSuccessScreen"] as? Bool ?? true
            builder.hasSuccessScreen = hasSuccessScreen
        }
        
        if (builderArgs?["IsDebug"] != nil) {
            let isDebug = builderArgs?["IsDebug"] as? Bool ?? false
            builder.isDebug = isDebug
        }
        
        if (builderArgs?["Colors.textColor"] != nil) {
            let textColor = builderArgs?["Colors.textColor"] as? String ?? ""
            builder.kivColors.textColor = hexColorToUIColor(hex: textColor)
        }
        
        if (builderArgs?["Colors.backgroundColor"] != nil) {
            let backgroundColor = builderArgs?["Colors.backgroundColor"] as? String ?? ""
            builder.kivColors.backgroundColor = hexColorToUIColor(hex: backgroundColor)
        }
        
        if (builderArgs?["Colors.buttonSuccessColor"] != nil) {
            let buttonSuccessColor = builderArgs?["Colors.buttonSuccessColor"] as? String ?? ""
            builder.kivColors.buttonSuccessColor = hexColorToUIColor(hex: buttonSuccessColor)
        }
        
        if (builderArgs?["Colors.buttonErrorColor"] != nil) {
            let buttonErrorColor = builderArgs?["Colors.buttonErrorColor"] as? String ?? ""
            builder.kivColors.buttonErrorColor = hexColorToUIColor(hex: buttonErrorColor)
        }
        
        if (builderArgs?["Colors.buttonOtherColor"] != nil) {
            let buttonOtherColor = builderArgs?["Colors.buttonOtherColor"] as? String ?? ""
            builder.kivColors.buttonOtherColor = hexColorToUIColor(hex: buttonOtherColor)
        }
        
        if (builderArgs?["Colors.progressBarBackground"] != nil) {
            let progressBarBackground = builderArgs?["Colors.progressBarBackground"] as? String ?? ""
            builder.kivColors.progressBarBackground = hexColorToUIColor(hex: progressBarBackground)
        }
        
        if (builderArgs?["Colors.progressBarForeground"] != nil) {
            let progressBarForeground = builderArgs?["Colors.progressBarForeground"] as? String ?? ""
            builder.kivColors.progressBarForeground = hexColorToUIColor(hex: progressBarForeground)
        }
        
        if (builderArgs?["Fonts.fontName"] != nil) {
            let fontName = builderArgs?["Fonts.fontName"] as? String ?? ""
            builder.kivFonts.fontName = fontName
        }
        
        if (builderArgs?["Fonts.boldFontName"] != nil) {
            let boldFontName = builderArgs?["Fonts.boldFontName"] as? String ?? ""
            builder.kivFonts.boldFontName = boldFontName
        }

        if (builderArgs?["VerifyIncludeList"] != nil) {
            let includeList = builderArgs?["VerifyIncludeList"] as? [String] ?? []
            builder.kivVerifyIncludeList = includeList
        } 

        if (builderArgs?["VerifyExcludeList"] != nil) {
            let excludeList = builderArgs?["VerifyExcludeList"] as? [String] ?? []
            builder.kivVerifyExcludeList = excludeList
        } 
        
        resultHandler = result
        let viewController = builder.build()
        
        let rootViewController:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
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
    
    public func finishedWithSuccess(response: KIVResult) {
        let resultMap = Dictionary<String, Any>.init()
        resultHandler!(resultMap)
        resultHandler = nil;
    }
    
    public func canceled() {
        resultHandler!(FlutterError.init(code: E_CANCELED, message: "The user canceled", details: nil));
        resultHandler = nil;
    }

    public func contactSupportPressed() {
        resultHandler!(FlutterError.init(code: E_CANCELED, message: "The user pressed contact support", details: nil));
        resultHandler = nil;
    }
}
