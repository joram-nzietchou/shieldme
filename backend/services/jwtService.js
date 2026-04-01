const jwt = require('jsonwebtoken');
const env = require('../config/env');

class JWTService {
  static generateTokens(userId, phone, isPremium = false) {
    const payload = { userId, phone, isPremium };
    
    const accessToken = jwt.sign(payload, env.JWT.secret, {
      expiresIn: env.JWT.expiresIn,
    });
    
    const refreshToken = jwt.sign({ userId }, env.JWT.secret, {
      expiresIn: env.JWT.refreshExpiresIn,
    });
    
    return { accessToken, refreshToken };
  }
  
  static verifyToken(token) {
    try {
      const decoded = jwt.verify(token, env.JWT.secret);
      return { valid: true, decoded };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }
  
  static decodeToken(token) {
    try {
      return jwt.decode(token);
    } catch (error) {
      return null;
    }
  }
}

module.exports = JWTService;