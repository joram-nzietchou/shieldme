import 'package:flutter/foundation.dart';

class AppLogger {
  static bool isDebugMode = kDebugMode;
  
  static void debug(String message) {
    if (isDebugMode) {
      print('\x1B[36m[DEBUG] $message\x1B[0m');
    }
  }
  
  static void info(String message) {
    print('\x1B[32m[INFO] $message\x1B[0m');
  }
  
  static void warning(String message) {
    print('\x1B[33m[WARNING] $message\x1B[0m');
  }
  
  static void error(String message) {
    print('\x1B[31m[ERROR] $message\x1B[0m');
  }
  
  static void api(String method, String url, int? statusCode, int? duration) {
    final color = statusCode != null && statusCode >= 200 && statusCode < 300 
        ? '\x1B[32m' 
        : '\x1B[31m';
    print('$color[API] $method $url -> $statusCode (${duration}ms)\x1B[0m');
  }
}