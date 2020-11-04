import Flutter
import UIKit

public class SwiftKlippaIdentityValidationSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "klippa_identity_validation_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftKlippaIdentityValidationSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
