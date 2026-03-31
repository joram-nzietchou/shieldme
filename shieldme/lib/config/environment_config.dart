import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  // Singleton
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();
  factory EnvironmentConfig() => _instance;
  EnvironmentConfig._internal();

  // URLs par environnement
  static const Map<String, String> _urls = {
    'development': 'http://localhost:3000/api',
    'staging': 'https://api-staging.shieldme.com/api',
    'production': 'https://api.shieldme.com/api',
  };

  // URLs pour émulateurs Android
  static const Map<String, String> _androidEmulatorUrls = {
    'development': 'http://10.0.2.2:3000/api',
    'staging': 'https://api-staging.shieldme.com/api',
    'production': 'https://api.shieldme.com/api',
  };

  // URLs pour iOS Simulator
  static const Map<String, String> _iosSimulatorUrls = {
    'development': 'http://localhost:3000/api',
    'staging': 'https://api-staging.shieldme.com/api',
    'production': 'https://api.shieldme.com/api',
  };

  String get apiUrl {
    final environment = _getEnvironment();
    
    // Android Emulator
    if (kIsWeb == false && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorUrls[environment] ?? _urls[environment]!;
    }
    
    // iOS Simulator
    if (kIsWeb == false && defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosSimulatorUrls[environment] ?? _urls[environment]!;
    }
    
    // Web, Windows, MacOS
    return _urls[environment]!;
  }

  String _getEnvironment() {
    // Production (release build)
    if (bool.fromEnvironment('dart.vm.product')) {
      return 'production';
    }
    
    // Staging (via flag --dart-define=ENV=staging)
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    if (env == 'staging') return 'staging';
    
    return 'development';
  }

  bool get isDevelopment => _getEnvironment() == 'development';
  bool get isStaging => _getEnvironment() == 'staging';
  bool get isProduction => _getEnvironment() == 'production';
}