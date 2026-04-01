const OTPService = require('../services/otpService');
const JWTService = require('../services/jwtService');
const User = require('../models/User');
const logger = require('../utils/logger');

class AuthController {
  static async sendOTP(req, res) {
    try {
      const { phone } = req.body;
      const result = await OTPService.sendOTP(phone);
      
      res.json(result);
    } catch (error) {
      logger.error('Send OTP error:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de l\'envoi du code',
      });
    }
  }
  
  static async verifyOTP(req, res) {
    try {
      const { phone, otp, fullName, referralCode } = req.body;
      
      // Vérifier l'OTP
      const otpResult = await OTPService.verifyOTP(phone, otp);
      
      if (!otpResult.success) {
        return res.status(400).json(otpResult);
      }
      
      // Vérifier si l'utilisateur existe
      let user = await User.findByPhone(phone);
      let isNewUser = false;
      
      if (!user) {
        // Nouvel utilisateur - vérifier le parrainage
        let referrerId = null;
        if (referralCode) {
          const referrer = await User.findByReferralCode(referralCode);
          if (referrer) {
            referrerId = referrer.id;
          }
        }
        
        // Créer l'utilisateur
        user = await User.create({
          fullName,
          phone,
          referredBy: referrerId,
        });
        
        isNewUser = true;
        
        // Bonus de parrainage
        if (referrerId) {
          await User.addReferralBonus(referrerId, user.id, 100);
          
          // Enregistrer la relation de parrainage
          await User.createReferral(referrerId, user.id);
        }
        
        // Bonus de bienvenue
        await User.addWelcomeBonus(user.id, 100);
      }
      
      // Générer les tokens
      const { accessToken, refreshToken } = JWTService.generateTokens(
        user.id,
        user.phone,
        user.is_premium
      );
      
      // Récupérer les données complètes de l'utilisateur
      const userData = await User.findById(user.id);
      const walletBalance = await User.getWalletBalance(user.id);
      
      res.json({
        success: true,
        message: isNewUser ? 'Inscription réussie!' : 'Connexion réussie!',
        token: accessToken,
        refreshToken,
        user: {
          id: userData.id,
          fullName: userData.full_name,
          phone: userData.phone,
          referralCode: userData.referral_code,
          isPremium: userData.is_premium,
          premiumExpiresAt: userData.premium_expires_at,
          createdAt: userData.created_at,
          walletBalance,
          totalReferred: parseInt(userData.total_referred) || 0,
          subscribedReferred: parseInt(userData.subscribed_referred) || 0,
        },
        isNewUser,
      });
    } catch (error) {
      logger.error('Verify OTP error:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur lors de la vérification',
      });
    }
  }
  
  static async getMe(req, res) {
    try {
      const user = await User.findById(req.user.id);
      const walletBalance = await User.getWalletBalance(req.user.id);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Utilisateur non trouvé',
        });
      }
      
      res.json({
        success: true,
        user: {
          id: user.id,
          fullName: user.full_name,
          phone: user.phone,
          referralCode: user.referral_code,
          isPremium: user.is_premium,
          premiumExpiresAt: user.premium_expires_at,
          createdAt: user.created_at,
          referredBy: user.referred_by,
          walletBalance,
          totalReferred: parseInt(user.total_referred) || 0,
          subscribedReferred: parseInt(user.subscribed_referred) || 0,
        },
      });
    } catch (error) {
      logger.error('Get me error:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur',
      });
    }
  }
  
  static async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;
      
      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          message: 'Refresh token requis',
        });
      }
      
      const { valid, decoded } = JWTService.verifyToken(refreshToken);
      
      if (!valid) {
        return res.status(401).json({
          success: false,
          message: 'Refresh token invalide',
        });
      }
      
      const user = await User.findById(decoded.userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Utilisateur non trouvé',
        });
      }
      
      const { accessToken } = JWTService.generateTokens(
        user.id,
        user.phone,
        user.is_premium
      );
      
      res.json({
        success: true,
        token: accessToken,
      });
    } catch (error) {
      logger.error('Refresh token error:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur',
      });
    }
  }
  
  static async logout(req, res) {
    try {
      // En production, on pourrait blacklister le token
      res.json({
        success: true,
        message: 'Déconnexion réussie',
      });
    } catch (error) {
      logger.error('Logout error:', error);
      res.status(500).json({
        success: false,
        message: 'Erreur serveur',
      });
    }
  }
}

module.exports = AuthController;