import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

/// Available languages for the Identity Verification SDK.
enum KIVLanguage { English, Dutch }

/// Custom fonts for the SDK.
class KIVFonts {
  /// The normal font that the SDK uses.
  String fontName;

  /// The bold font that the SDK uses.
  String boldFontName;
}

/// Custom colors for the SDK.
class KIVColors {
  /// The color that the SDK uses for text.
  Color textColor;

  /// The color that the SDK uses for the background.
  Color backgroundColor;

  /// The color that the SDK uses for success buttons.
  Color buttonSuccessColor;

  /// The color that the SDK uses for error buttons.
  Color buttonErrorColor;

  /// The color that the SDK uses for other buttons.
  Color buttonOtherColor;

  /// The color that the SDK uses for the progress bar background.
  Color progressBarBackground;

  /// The color that the SDK uses for the progress bar foreground.
  Color progressBarForeground;
}

/// The builder to start a new session.
class IdentityBuilder {
  /// The colors that the SDK uses.
  KIVColors colors = new KIVColors();

  /// The fonts that the SDK uses.
  KIVFonts fonts = new KIVFonts();

  /// The language that the SDK uses.
  KIVLanguage language;

  /// Whether the SDK shows an intro screen.
  bool hasIntroScreen;

  /// Whether the SDK shows an success screen.
  bool hasSuccessScreen;

  /// Whether the SDK should report debug information.
  bool isDebug;

  /// Overwrite the fonts object with a new one.
  setFonts(KIVFonts newFonts) {
    this.fonts = newFonts;
  }

  /// Overwrite the colors object with a new one.
  setColors(KIVColors newColors) {
    this.colors = newColors;
  }

  /// Overwrite the language for the builder.
  setLanguage(KIVLanguage newLanguage) {
    this.language = newLanguage;
  }
}

/// The main plugin class.
class KlippaIdentityVerificationSdk {
  static const MethodChannel _channel =
      const MethodChannel('klippa_identity_verification_sdk');

  /// Start the session given a builder and a session.
  static Future<Map> startSession(
      IdentityBuilder builder, String sessionToken) async {
    Map<String, dynamic> parameters = {};
    parameters['SessionToken'] = sessionToken;
    if (builder.language != null) {
      parameters['Language'] = builder.language.toString();
    }

    if (builder.colors != null) {
      if (builder.colors.textColor != null) {
        parameters['Colors.textColor'] = builder.colors.textColor.toString();
      }
      if (builder.colors.backgroundColor != null) {
        parameters['Colors.backgroundColor'] =
            builder.colors.backgroundColor.toString();
      }
      if (builder.colors.buttonSuccessColor != null) {
        parameters['Colors.buttonSuccessColor'] =
            builder.colors.buttonSuccessColor.toString();
      }
      if (builder.colors.buttonErrorColor != null) {
        parameters['Colors.buttonErrorColor'] =
            builder.colors.buttonErrorColor.toString();
      }
      if (builder.colors.buttonOtherColor != null) {
        parameters['Colors.buttonOtherColor'] =
            builder.colors.buttonOtherColor.toString();
      }
      if (builder.colors.progressBarBackground != null) {
        parameters['Colors.progressBarBackground'] =
            builder.colors.progressBarBackground.toString();
      }
      if (builder.colors.progressBarForeground != null) {
        parameters['Colors.progressBarForeground'] =
            builder.colors.progressBarForeground.toString();
      }
    }

    if (builder.fonts != null) {
      if (builder.fonts.fontName != null) {
        parameters['Colors.fontName'] = builder.fonts.fontName;
      }
      if (builder.fonts.fontName != null) {
        parameters['Fonts.fontName'] = builder.fonts.boldFontName;
      }
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

    final Map startSessionResult =
        await _channel.invokeMethod('startSession', parameters);
    return startSessionResult;
  }
}
