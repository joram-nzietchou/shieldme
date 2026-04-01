const db = require('../config/database');
const bcrypt = require('bcryptjs');
const env = require('../config/env');
const { v4: uuidv4 } = require('uuid');

class User {
  static async create(userData) {
    const { fullName, phone, referredBy = null } = userData;
    const referralCode = this.generateReferralCode(fullName);
    
    const query = `
      INSERT INTO users (full_name, phone, referral_code, referred_by, created_at, updated_at)
      VALUES ($1, $2, $3, $4, NOW(), NOW())
      RETURNING id, full_name, phone, referral_code, is_premium, created_at
    `;
    
    const values = [fullName, phone, referralCode, referredBy];
    const result = await db.query(query, values);
    return result.rows[0];
  }
  
  static async findByPhone(phone) {
    const query = `
      SELECT id, full_name, phone, referral_code, is_premium, premium_expires_at, 
             created_at, referred_by
      FROM users 
      WHERE phone = $1
    `;
    const result = await db.query(query, [phone]);
    return result.rows[0];
  }
  
  static async findById(id) {
    const query = `
      SELECT u.id, u.full_name, u.phone, u.referral_code, u.is_premium, 
             u.premium_expires_at, u.created_at, u.referred_by,
             COALESCE(SUM(CASE WHEN wt.type IN ('REFERRAL_BONUS', 'MONTHLY_COMMISSION') 
                         THEN wt.amount ELSE 0 END), 0) as total_earned,
             COALESCE(SUM(CASE WHEN wt.type = 'WITHDRAWAL' 
                         THEN wt.amount ELSE 0 END), 0) as total_withdrawn,
             COUNT(DISTINCT r.referred_id) as total_referred,
             COUNT(CASE WHEN r.is_subscribed THEN 1 END) as subscribed_referred
      FROM users u
      LEFT JOIN wallet_transactions wt ON u.id = wt.user_id AND wt.status = 'COMPLETED'
      LEFT JOIN referrals r ON u.id = r.referrer_id
      WHERE u.id = $1
      GROUP BY u.id
    `;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }
  
  static async updatePremiumStatus(userId, isPremium, expiresAt = null) {
    const query = `
      UPDATE users 
      SET is_premium = $1, premium_expires_at = $2, updated_at = NOW()
      WHERE id = $3
      RETURNING *
    `;
    const result = await db.query(query, [isPremium, expiresAt, userId]);
    return result.rows[0];
  }
  
  static async getWalletBalance(userId) {
    const query = `
      SELECT COALESCE(SUM(CASE WHEN type IN ('REFERRAL_BONUS', 'MONTHLY_COMMISSION') 
                         THEN amount ELSE -amount END), 0) as balance
      FROM wallet_transactions 
      WHERE user_id = $1 AND status = 'COMPLETED'
    `;
    const result = await db.query(query, [userId]);
    return result.rows[0]?.balance || 0;
  }
  
  static generateReferralCode(fullName) {
    const base = fullName.substring(0, 3).toUpperCase();
    const random = Math.floor(1000 + Math.random() * 9000);
    return `${base}-${random}`;
  }
  
  static async addReferralBonus(referrerId, referredId, amount = 100) {
    const query = `
      INSERT INTO wallet_transactions (user_id, amount, type, description, status, created_at)
      VALUES ($1, $2, 'REFERRAL_BONUS', $3, 'COMPLETED', NOW())
      RETURNING *
    `;
    return await db.query(query, [referrerId, amount, `Bonus parrainage #${referredId}`]);
  }
  
  static async addWelcomeBonus(userId, amount = 100) {
    const query = `
      INSERT INTO wallet_transactions (user_id, amount, type, description, status, created_at)
      VALUES ($1, $2, 'REFERRAL_BONUS', $3, 'COMPLETED', NOW())
      RETURNING *
    `;
    return await db.query(query, [userId, amount, 'Bienvenue sur ShieldMe!']);
  }
}

module.exports = User;