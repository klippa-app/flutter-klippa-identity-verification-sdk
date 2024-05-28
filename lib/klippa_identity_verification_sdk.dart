import 'dart:async';
import 'package:flutter/services.dart';

/// Available languages for the Identity Verification SDK.
enum KIVLanguage { English, Dutch, Spanish, German, French }

/// Custom fonts for the SDK.
class KIVFonts {
  /// The normal font that the SDK uses.
  String? fontName;

  /// The bold font that the SDK uses.
  String? boldFontName;
}

/// Custom colors for the SDK.
class KIVColors {
  /// The color that the SDK uses for text.
  Color? textColor;

  /// The color that the SDK uses for the background.
  Color? backgroundColor;

  /// The color that the SDK uses for success buttons.
  Color? buttonSuccessColor;

  /// The color that the SDK uses for error buttons.
  Color? buttonErrorColor;

  /// The color that the SDK uses for other buttons.
  Color? buttonOtherColor;

  /// The color that the SDK uses for the progress bar background.
  Color? progressBarBackground;

  /// The color that the SDK uses for the progress bar foreground.
  Color? progressBarForeground;
}

/// The builder to start a new session.
class IdentityBuilder {
  /// The colors that the SDK uses.
  KIVColors colors = new KIVColors();

  /// The fonts that the SDK uses.
  KIVFonts fonts = new KIVFonts();

  /// The list of items to include in the data verification screen.
  List<String>? verifyIncludeList;

  /// The list of items to exclude in the data verification screen.
  List<String>? verifyExcludeList;

  /// The list of validations to include.
  List<String>? validationIncludeList;

  /// The list of validations to exclude.
  List<String>? validationExcludeList;

  /// The language that the SDK uses.
  KIVLanguage? language;

  /// Whether the SDK shows an intro screen.
  bool? hasIntroScreen;

  /// Whether the SDK shows an success screen.
  bool? hasSuccessScreen;

  /// Whether the SDK should report debug information.
  bool? isDebug;

  /// Whether the SDK should automatically take photos when conditions are right.
  bool? enableAutoCapture;

  /// The threshold the user can attempt a task before a contact support button is shown.
  int? retryThreshold;

  /// Overwrite the fonts object with [newFonts] for the builder.
  setFonts(KIVFonts newFonts) {
    this.fonts = newFonts;
  }

  /// Overwrite the colors object with [newColors] for the builder.
  setColors(KIVColors newColors) {
    this.colors = newColors;
  }

  /// Overwrite the language with [newLanguage] for the builder.
  setLanguage(KIVLanguage newLanguage) {
    this.language = newLanguage;
  }
}

/// A helper to convert flutter Color to a hex ARGB.
class KIVHexColor {
  /// Convert the given Flutter [color] object to a hex ARGB string. With our without a leading hash sign based on [leadingHashSign].
  static String flutterColorToHex(Color color, bool leadingHashSign) {
    return '${leadingHashSign ? '#' : ''}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }
}

/// The main plugin class.
class KlippaIdentityVerificationSdk {
  static const MethodChannel _channel =
      const MethodChannel('klippa_identity_verification_sdk');

  /// Start the session given a [builder] and a [sessionToken].
  static Future<Map> startSession(
      IdentityBuilder builder, String sessionToken) async {
    Map<String, dynamic> parameters = {};
    parameters['SessionToken'] = sessionToken;
    if (builder.language != null) {
      parameters['Language'] = builder.language.toString();
    }

    if (builder.colors.textColor != null) {
      parameters['Colors.textColor'] =
          KIVHexColor.flutterColorToHex(builder.colors.textColor!, true);
    }

    if (builder.colors.backgroundColor != null) {
      parameters['Colors.backgroundColor'] =
          KIVHexColor.flutterColorToHex(builder.colors.backgroundColor!, true);
    }

    if (builder.colors.buttonSuccessColor != null) {
      parameters['Colors.buttonSuccessColor'] = KIVHexColor.flutterColorToHex(
          builder.colors.buttonSuccessColor!, true);
    }

    if (builder.colors.buttonErrorColor != null) {
      parameters['Colors.buttonErrorColor'] =
          KIVHexColor.flutterColorToHex(builder.colors.buttonErrorColor!, true);
    }

    if (builder.colors.buttonOtherColor != null) {
      parameters['Colors.buttonOtherColor'] =
          KIVHexColor.flutterColorToHex(builder.colors.buttonOtherColor!, true);
    }

    if (builder.colors.progressBarBackground != null) {
      parameters['Colors.progressBarBackground'] =
          KIVHexColor.flutterColorToHex(
              builder.colors.progressBarBackground!, true);
    }

    if (builder.colors.progressBarForeground != null) {
      parameters['Colors.progressBarForeground'] =
          KIVHexColor.flutterColorToHex(
              builder.colors.progressBarForeground!, true);
    }

    if (builder.fonts.fontName != null) {
      parameters['Fonts.fontName'] = builder.fonts.fontName;
    }

    if (builder.fonts.boldFontName != null) {
      parameters['Fonts.boldFontName'] = builder.fonts.boldFontName;
    }

    if (builder.hasIntroScreen != null) {
      parameters['HasIntroScreen'] = builder.hasIntroScreen;
    }

    if (builder.hasSuccessScreen != null) {
      parameters['HasSuccessScreen'] = builder.hasSuccessScreen;
    }

    if (builder.isDebug != null) {
      parameters['IsDebug'] = builder.isDebug;
    }

    if (builder.enableAutoCapture != null) {
      parameters['EnableAutoCapture'] = builder.enableAutoCapture;
    }

    if (builder.verifyIncludeList != null) {
      parameters['VerifyIncludeList'] = builder.verifyIncludeList;
    }

    if (builder.verifyExcludeList != null) {
      parameters['VerifyExcludeList'] = builder.verifyExcludeList;
    }

    if (builder.validationIncludeList != null) {
      parameters['ValidationIncludeList'] = builder.validationIncludeList;
    }

    if (builder.validationExcludeList != null) {
      parameters['ValidationExcludeList'] = builder.validationExcludeList;
    }

    if (builder.retryThreshold != null) {
      parameters["RetryThreshold"] = builder.retryThreshold;
    }

    final Map startSessionResult =
        await _channel.invokeMethod('startSession', parameters);
    return startSessionResult;
  }
}
