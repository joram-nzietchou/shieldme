class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh-token';
  static const String users = '/auth/users'; // Pour admin
  
  // User
  static const String updateProfile = '/user/update';
  static const String changePassword = '/user/change-password';
  static const String deleteAccount = '/user/delete';
  
  // Wallet
  static const String wallet = '/user/wallet';
  static const String transactions = '/user/transactions';
  static const String withdraw = '/user/withdraw';
  
  // Referral
  static const String referralStats = '/referral/stats';
  static const String referralHistory = '/referral/history';
  
  // Scan
  static const String scanUrl = '/scan/url';
  static const String scanHistory = '/scan/history';
  
  // SMS
  static const String smsHistory = '/sms/history';
  static const String reportSms = '/sms/report';
  
  // Premium
  static const String subscribe = '/premium/subscribe';
  static const String cancelSubscription = '/premium/cancel';
}