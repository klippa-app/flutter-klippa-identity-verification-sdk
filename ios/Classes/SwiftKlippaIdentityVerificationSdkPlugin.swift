import Flutter
import UIKit

public class SwiftKlippaIdentityVerificationSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "klippa_identity_verification_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftKlippaIdentityVerificationSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
