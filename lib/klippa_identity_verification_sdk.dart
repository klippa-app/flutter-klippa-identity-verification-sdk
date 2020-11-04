import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

enum KIVLanguage {
  English,
  Dutch
}

class KIVFonts {
  String fontName;
  String boldFontName;
}

class KIVColors {
  Color textColor;
  Color backgroundColor;
  Color buttonSuccessColor;
  Color buttonErrorColor;
  Color buttonOtherColor;
  Color progressBarBackground;
  Color progressBarForeground;
}

class IdentityBuilder {
  KIVColors colors = new KIVColors();
  KIVFonts fonts = new KIVFonts();
  KIVLanguage language;
  bool hasIntroScreen;
  bool hasSuccessScreen;
  bool isDebug;

  setFonts(KIVFonts newFonts) {
    this.fonts = newFonts;
  }

  setColors(KIVColors newColors) {
    this.colors = newColors;
  }

  setLanguage(KIVLanguage newLanguage) {
    this.language = newLanguage;
  }
}

class KlippaIdentityVerificationSdk {
  static const MethodChannel _channel =
      const MethodChannel('klippa_identity_verification_sdk');

  static Future<Map> startSession(IdentityBuilder builder, String sessionToken) async {
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
        parameters['Colors.backgroundColor'] = builder.colors.backgroundColor.toString();
      }
      if (builder.colors.buttonSuccessColor != null) {
        parameters['Colors.buttonSuccessColor'] = builder.colors.buttonSuccessColor.toString();
      }
      if (builder.colors.buttonErrorColor != null) {
        parameters['Colors.buttonErrorColor'] = builder.colors.buttonErrorColor.toString();
      }
      if (builder.colors.buttonOtherColor != null) {
        parameters['Colors.buttonOtherColor'] = builder.colors.buttonOtherColor.toString();
      }
      if (builder.colors.progressBarBackground != null) {
        parameters['Colors.progressBarBackground'] = builder.colors.progressBarBackground.toString();
      }
      if (builder.colors.progressBarForeground != null) {
        parameters['Colors.progressBarForeground'] = builder.colors.progressBarForeground.toString();
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

    final Map startSessionResult = await _channel.invokeMethod('startSession', parameters);
    return startSessionResult;
  }
}
