class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // ============= AUTHENTIFICATION =============
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh-token';
  
  // ============= UTILISATEUR =============
  static const String updateProfile = '/user/update';
  static const String changePassword = '/user/change-password';  // AJOUTER CETTE LIGNE
  static const String deleteAccount = '/user/delete';
  static const String uploadAvatar = '/user/avatar';
  
  // ============= PORTEFEUILLE =============
  static const String wallet = '/user/wallet';
  static const String transactions = '/user/transactions';
  static const String withdraw = '/user/withdraw';
  
  // ============= PARRAINAGE =============
  static const String referralStats = '/referral/stats';
  static const String referralHistory = '/referral/history';
  static const String referralRanking = '/referral/ranking';
  
  // ============= SCAN =============
  static const String scanUrl = '/scan/url';
  static const String scanHistory = '/scan/history';
  static const String reportPhishing = '/scan/report';
  
  // ============= SMS =============
  static const String smsHistory = '/sms/history';
  static const String reportSms = '/sms/report';
  static const String smsSettings = '/sms/settings';
  
  // ============= PREMIUM =============
  static const String subscribe = '/premium/subscribe';
  static const String cancelSubscription = '/premium/cancel';
  static const String subscriptionStatus = '/premium/status';
  static const String paymentHistory = '/premium/payments';
}