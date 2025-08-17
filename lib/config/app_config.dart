
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = "Focus Timer";
  static const String appVersion = "1.0.0";
  static const int buildNumber = 1;
  static const String description = "A simple and effective Pomodoro timer for focused work sessions";
  
  // Developer Information
  static const String developerName = "BashTech";
  static const String developerWebsite = "https://www.bashtech.info/";
  static const String developerEmail = "support@bashtech.info";
  
  // URLs
  static const String privacyPolicy = "https://www.bashtech.info/privacy";
  static const String termsOfService = "https://www.bashtech.info/terms";
  static const String support = "https://www.bashtech.info/support";
  static const String buyCoffee = "https://www.bashtech.info/buy-coffee";
  
  // Default Settings
  static const int defaultWorkDuration = 25;
  static const int defaultShortBreakDuration = 5;
  static const int defaultLongBreakDuration = 15;
  static const int defaultSessionsBeforeLongBreak = 4;
  static const bool defaultAutoStartBreaks = true;
  static const bool defaultAutoStartWork = true;
  static const bool defaultSoundEnabled = true;
  static const bool defaultVibrationEnabled = true;
  
  // Theme Colors
  static const String primaryColor = "#00BCD4";
  static const String secondaryColor = "#009688";
  static const String backgroundColor = "#1E1E1E";
  static const String surfaceColor = "#2D2D2D";
  static const String textColor = "#FFFFFF";
  
  // Test IDs for Development
  static const String testAdMobAppId = "ca-app-pub-3940256099942544~3347511713";
  static const String testAdMobBannerId = "ca-app-pub-3940256099942544/6300978111";
  static const String testAdMobInterstitialId = "ca-app-pub-3940256099942544/1033173712";
  static const String testFacebookAppId = "123456789012345";
  static const String testFacebookBannerId = "123456789012345_123456789012345";
}
