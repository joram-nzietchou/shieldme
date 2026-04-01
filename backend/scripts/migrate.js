const db = require('../config/database');
const logger = require('../utils/logger');

const migrations = [
  // Table users
  `
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    referral_code VARCHAR(20) UNIQUE NOT NULL,
    referred_by INTEGER REFERENCES users(id),
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
  `,
  
  // Table otps
  `
  CREATE TABLE IF NOT EXISTS otps (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
  `,
  
  // Table referrals
  `
  CREATE TABLE IF NOT EXISTS referrals (
    id SERIAL PRIMARY KEY,
    referrer_id INTEGER REFERENCES users(id),
    referred_id INTEGER REFERENCES users(id) UNIQUE,
    is_subscribed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
  `,
  
  // Table wallet_transactions
  `
  CREATE TABLE IF NOT EXISTS wallet_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    amount INTEGER NOT NULL,
    type VARCHAR(50) CHECK (type IN ('REFERRAL_BONUS', 'MONTHLY_COMMISSION', 'WITHDRAWAL', 'PURCHASE')),
    description TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
  `,
  
  // Index
  `
  CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone)
  `,
  `
  CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code)
  `,
  `
  CREATE INDEX IF NOT EXISTS idx_otps_phone ON otps(phone)
  `,
  `
  CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id)
  `,
];

const runMigrations = async () => {
  logger.info('Starting database migrations...');
  
  for (const migration of migrations) {
    try {
      await db.query(migration);
      logger.info('✅ Migration executed successfully');
    } catch (error) {
      logger.error('❌ Migration failed:', error);
    }
  }
  
  logger.info('All migrations completed!');
  process.exit(0);
};

runMigrations();