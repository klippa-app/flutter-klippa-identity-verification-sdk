#import "KlippaIdentityValidationSdkPlugin.h"
#if __has_include(<klippa_identity_validation_sdk/klippa_identity_validation_sdk-Swift.h>)
#import <klippa_identity_validation_sdk/klippa_identity_validation_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "klippa_identity_validation_sdk-Swift.h"
#endif

@implementation KlippaIdentityValidationSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKlippaIdentityValidationSdkPlugin registerWithRegistrar:registrar];
}
@end
