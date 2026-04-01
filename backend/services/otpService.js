const OTP = require('../models/OTP');
const smsService = require('./smsService');
const logger = require('../utils/logger');

class OTPService {
  static async sendOTP(phone) {
    try {
      const code = await OTP.generateCode();
      await OTP.create(phone, code);
      
      // Envoyer le SMS
      const message = `Votre code de vérification ShieldMe est: ${code}. Valable 5 minutes. Ne partagez jamais ce code.`;
      const smsSent = await smsService.sendSMS(phone, message);
      
      if (!smsSent && process.env.NODE_ENV === 'development') {
        logger.info(`[DEV] OTP for ${phone}: ${code}`);
      }
      
      return {
        success: true,
        message: 'Code OTP envoyé avec succès',
        expiresIn: 5,
      };
    } catch (error) {
      logger.error('Error sending OTP:', error);
      return {
        success: false,
        message: 'Erreur lors de l\'envoi du code',
      };
    }
  }
  
  static async verifyOTP(phone, code) {
    const otp = await OTP.verify(phone, code);
    
    if (!otp) {
      return {
        success: false,
        message: 'Code OTP invalide ou expiré',
      };
    }
    
    return {
      success: true,
      message: 'Code vérifié avec succès',
    };
  }
}

module.exports = OTPService;