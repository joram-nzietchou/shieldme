const db = require('../config/database');
const env = require('../config/env');

class OTP {
  static async create(phone, code) {
    const expiresAt = new Date(Date.now() + env.OTP.expiresMinutes * 60000);
    
    // Supprimer les anciens OTPs non utilisés
    await db.query(
      'DELETE FROM otps WHERE phone = $1 AND is_used = false',
      [phone]
    );
    
    const query = `
      INSERT INTO otps (phone, code, expires_at, created_at)
      VALUES ($1, $2, $3, NOW())
      RETURNING id, phone, expires_at
    `;
    
    const result = await db.query(query, [phone, code, expiresAt]);
    return result.rows[0];
  }
  
  static async verify(phone, code) {
    const query = `
      SELECT id, phone, code, expires_at, is_used
      FROM otps 
      WHERE phone = $1 AND code = $2 AND is_used = false 
      AND expires_at > NOW()
      ORDER BY created_at DESC
      LIMIT 1
    `;
    
    const result = await db.query(query, [phone, code]);
    
    if (result.rows.length === 0) {
      return null;
    }
    
    const otp = result.rows[0];
    
    // Marquer comme utilisé
    await db.query(
      'UPDATE otps SET is_used = true, updated_at = NOW() WHERE id = $1',
      [otp.id]
    );
    
    return otp;
  }
  
  static async generateCode() {
    const digits = '0123456789';
    let code = '';
    for (let i = 0; i < env.OTP.length; i++) {
      code += digits[Math.floor(Math.random() * digits.length)];
    }
    return code;
  }
  
  static async cleanupExpired() {
    const query = `
      DELETE FROM otps 
      WHERE expires_at < NOW() AND is_used = false
    `;
    const result = await db.query(query);
    return result.rowCount;
  }
}

module.exports = OTP;