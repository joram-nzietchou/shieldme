class UserModel {
  final int id;
  final String fullName;
  final String phone;
  final String referralCode;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final DateTime createdAt;
  final int walletBalance;
  final int totalReferred;
  final int subscribedReferred;
  final int? referredBy;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.referralCode,
    required this.isPremium,
    this.premiumExpiresAt,
    required this.createdAt,
    required this.walletBalance,
    required this.totalReferred,
    required this.subscribedReferred,
    this.referredBy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'] ?? json['full_name'],
      phone: json['phone'],
      referralCode: json['referralCode'] ?? json['referral_code'],
      isPremium: json['isPremium'] ?? json['is_premium'] ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'])
          : json['premium_expires_at'] != null
              ? DateTime.parse(json['premium_expires_at'])
              : null,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      walletBalance: json['walletBalance'] ?? json['wallet_balance'] ?? 0,
      totalReferred: json['totalReferred'] ?? json['total_referred'] ?? 0,
      subscribedReferred: json['subscribedReferred'] ?? json['subscribed_referred'] ?? 0,
      referredBy: json['referredBy'] ?? json['referred_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'referralCode': referralCode,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'walletBalance': walletBalance,
      'totalReferred': totalReferred,
      'subscribedReferred': subscribedReferred,
      'referredBy': referredBy,
    };
  }
}