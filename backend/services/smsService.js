const env = require('../config/env');
const logger = require('../utils/logger');

class SMSService {
  static async sendSMS(phone, message) {
    // Nettoyer le numéro
    const cleanPhone = phone.replace(/\D/g, '');
    const formattedPhone = cleanPhone.startsWith('237') ? cleanPhone : `237${cleanPhone}`;
    
    if (env.NODE_ENV === 'development') {
      logger.info(`[DEV SMS] To: ${formattedPhone} | Message: ${message}`);
      return true;
    }
    
    try {
      // Configuration pour Africa's Talking
      if (env.SMS.provider === 'africastalking') {
        const url = 'https://api.africastalking.com/version1/messaging';
        const auth = Buffer.from(`${env.SMS.username}:${env.SMS.apiKey}`).toString('base64');
        
        const response = await fetch(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': `Basic ${auth}`,
          },
          body: new URLSearchParams({
            username: env.SMS.username,
            to: formattedPhone,
            message: message,
            from: env.SMS.sender,
          }),
        });
        
        const data = await response.json();
        return data.SMSMessageData?.Recipients?.length > 0;
      }
      
      // Configuration pour Twilio
      if (env.SMS.provider === 'twilio') {
        // Implémentation Twilio
        return true;
      }
      
      return true;
    } catch (error) {
      logger.error('SMS sending error:', error);
      return false;
    }
  }
}

module.exports = SMSService;