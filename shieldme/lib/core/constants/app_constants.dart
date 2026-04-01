class AppConstants {
  static const String appName = 'ShieldMe';
  static const String appVersion = '1.0.0';
  
  // Pour Chrome (backend sur localhost:3000)
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Pour émulateur Android (si vous testez sur mobile plus tard)
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Auth
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';
  
  // Referral
  static const int referralBonus = 100;
  static const int monthlyCommission = 200;
  
  // Premium
  static const int premiumPrice = 1200;
  static const String premiumCurrency = 'FCFA';
}