import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String getApiAuthority() {
    final env = dotenv.env['ENV'] ?? 'development';
    final isDev = env == 'development';

    if (kIsWeb) {
      return isDev
          ? dotenv.env['WEB_URL_DEV']?.replaceFirst('http://', '') ?? 'localhost:8080'
          : dotenv.env['WEB_URL_PROD']?.replaceFirst('https://', '') ?? 'prod.web.url';
    } else if (Platform.isAndroid) {
      return isDev
          ? dotenv.env['ANDROID_URL_DEV']?.replaceFirst('http://', '') ?? '10.0.2.2:8080'
          : dotenv.env['ANDROID_URL_PROD']?.replaceFirst('https://', '') ?? 'prod.android.url';
    } else if (Platform.isIOS) {
      return isDev
          ? dotenv.env['IOS_URL_DEV']?.replaceFirst('http://', '') ?? 'localhost:8080'
          : dotenv.env['IOS_URL_PROD']?.replaceFirst('https://', '') ?? 'prod.ios.url';
    } else {
      return 'Unknown platform';
    }
  }

  static bool isSecure() {
    final env = dotenv.env['ENV'] ?? 'development';
    return env != 'development'; // Suppose que la production est sécurisée
  }

  static const String webSocketUrl = 'ws://localhost:8080/api/ws/';
}