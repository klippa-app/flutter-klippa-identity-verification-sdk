# flutter-klippa-identity-verification-sdk

## SDK usage
Please be aware you need to have a Klippa Identity Verification OCR API key to use this SDK.
If you would like to use our Identity Verification SDK, please contact us [here](https://www.klippa.com/en/ocr/identity-documents/)

## Getting started
### Android

Edit the file `android/key.properties`, if it doesn't exist yet, create it. Add the SDK credentials:

```
klippa.identity_verification.sdk.username={your-username}
klippa.identity_verification.sdk.password={your-password}
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

### iOS

Edit the file `ios/Podfile`, add the Klippa CocoaPod:
```
// Edit the platform to a minimum of 10.0, our SDK doesn't support earlier iOS versions.
platform :ios, '10.0'

target 'YourApplicationName' do
  # Pods for YourApplicationName
  // ... other pods

  pod 'Klippa-Scanner', podspec: 'https://custom-ocr.klippa.com/sdk/ios/specrepo/{your-username}/{your-password}/KlippaScanner/0.1.1.podspec'
end
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

Edit the file `ios/{project-name}/Info.plist` and add the `NSCameraUsageDescription` value:
```
...
<key>NSCameraUsageDescription</key>
<string>Access to your camera is needed to photograph documents.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Access to your photo library is used to save the images of documents.</string>
...
```

### Flutter

Add `

## Usage
```javascript
import KlippaScannerSDK from '@klippa/react-native-klippa-scanner-sdk';

// Ask for camera permission.
KlippaScannerSDK.getCameraPermission().then((authStatus) => {
    if (authStatus.Status !== "Authorized") {
        // Do something here to tell the user how they should enable the camera.
        Alert.alert("No access to camera");
        return;
    }

    // Start the scanner.
    KlippaScannerSDK.getCameraResult({
        // Required
        License: "{license-received-by-klippa}",
    
        // Optional.
        // Whether to show the icon to enable "multi-document-mode"
        AllowMultipleDocuments: true,
    
        // Whether the "multi-document-mode" should be enabled by default.
        DefaultMultipleDocuments: true,
    
        // Whether the crop mode (auto edge detection) should be enabled by default.
        DefaultCrop: true,
    
        // Define the max resolution of the output file. It’s possible to set only one of these values. We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image. Default is max resolution of camera.
        ImageMaxWidth: 1920,
        ImageMaxHeight: 1080,
    
        // Set the output quality (between 0-100) of the jpg encoder. Default is 100.
        ImageMaxQuality: 95,
    
        // The warning message when someone should move closer to a document, should be a string.
        MoveCloserMessage: "Move closer to the document",
    
        // Optional. Only affects Android.
    
        // What the default color conversion will be (grayscale, original).
        DefaultColor: "original",
    
        // Where to put the image results.
        StoragePath: "/sdcard/scanner",
    
        // The filename to use for the output images, supports replacement tokens %dateTime% and %randomUUID%.
        OutputFilename: "KlippaScannerExample-%dateTime%-%randomUUID%",
    
        // To limit the amount of images that can be taken.
        ImageLimit: 10,
        
        // The message to display when the limit has been reached.
        ImageLimitReachedMessage: "You have reached the image limit",
    
        // Optional. Only affects iOS.
        // The warning message when the camera result is too bright.
        ImageTooBrightMessage: "The image is too bright",
       
        // The warning message when the camera result is too dark.
        ImageTooDarkMessage: "The image is too dark",
        
        // The primary color of the interface, should be a UIColor.
        PrimaryColor: null,
       
        // The accent color of the interface, should be a UIColor.
        AccentColor: null,
    
        // The overlay color (when using document detection), should be a UIColor.
        OverlayColor: null,
    
        // The color of the background of the warning message, should be a UIColor.
        WarningBackgroundColor: null,
        
        // The color of the text of the warning message, should be a UIColor.
        WarningTextColor: null,
        
        // The amount of opacity for the overlay, should be a float.
        OverlayColorAlpha: 0.75,
    
        // The amount of seconds the preview should be visible for, should be a float.
        PreviewDuration: 1.0,
    
        // Whether the scanner automatically cuts out documents, should be a Boolean.
        IsCropEnabled: true,
     
        // Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
        IsViewFinderEnabled: true
    });
});
```

The result of `KlippaScannerSDK.getCameraResult()` is a Promise, so you can get the result with:
```javascript
KlippaScannerSDK.getCameraResult(options).then((result) => {
    console.log(result);
}).reject((reason) => {
    console.log(reason);
});
```

The content of the result object is:
```
{
  // Whether the MultipleDocuments option was turned on, so you can save it as default.
  "MultipleDocuments": true,

  // Whether the Crop option was turned on, so you can save it as default (Android only).
  "Crop": true,

  // What color option was used, so you can save it as default (Android only).
  "Color": "original",
 
  // An array of images.
  "Images": [
    {
      "Filepath": "/sdcard/scanner/dd0ca979-84e1-426e-8877-586e802fed1f.jpg"
    }
  ]
}
```

The reject reason object has a code and a message, the used codes are:
 - E_ACTIVITY_DOES_NOT_EXIST (Android only)
 - E_FAILED_TO_SHOW_CAMERA (Android only)
 - E_LICENSE_ERROR (on iOS license errors result in E_UNKNOWN_ERROR)
 - E_CANCELED
 - E_UNKNOWN_ERROR

## How to use a specific version of the SDK?

### Android

Edit the file `android/build.gradle`, add the following:

```maven
allprojects {
  // ... other definitions
  project.ext {
      klippaScannerVersion = "{version}"
  }
}
```

Replace the `{version}` value with the version you want to use.

### iOS

Edit the file `ios/Podfile`, change the pod line of `Klippa-Scanner` and replace `0.1.1.podspec` with `{version}.podspec`, replace the `{version}` value with the version you want to use.

## How to change the colors of the scanner?

### Android

Add or edit the file `android/app/src/main/res/values/colors.xml`, add the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="klippa_scanner_sdk_color_Primary">#2dc36a</color>
    <color name="klippa_scanner_sdk_color_PrimaryDark">#308D53</color>
    <color name="klippa_scanner_sdk_color_Accent">#2dc36a</color>
    <color name="klippa_scanner_sdk_color_Overlay">#2dc36a</color>
    <color name="klippa_scanner_sdk_color_Warning">#BFFF0000</color>
</resources>
```

### iOS
Use the following properties in the config when running `getCameraResult`: `PrimaryColor`, `AccentColor`, `OverlayColor`, `WarningBackgroundColor`, `WarningTextColor`, `OverlayColorAlpha`.

## Important iOS notes
Older iOS versions do not ship the Swift libraries. To make sure the SDK works on older iOS versions, you can configure the build to embed the Swift libraries using the build setting `EMBEDDED_CONTENT_CONTAINS_SWIFT = YES`.

We started using XCFrameworks from version 0.1.0, if you want to use that version or up, you need CocoaPod version 1.9.0 or higher.

## About Klippa

[Klippa](https://www.klippa.com/en) is a scale-up from [Groningen, The Netherlands](https://goo.gl/maps/CcCGaPTBz3u8noSd6) and was founded in 2015 by six Dutch IT specialists with the goal to digitize paper processes with modern technologies.

We help clients enhance the effectiveness of their organization by using machine learning and OCR. Since 2015 more than a 1000 happy clients have been served with a variety of the software solutions that Klippa offers. Our passion is to help our clients to digitize paper processes by using smart apps, accounts payable software and data extraction by using OCR.

## License

The MIT License (MIT)
