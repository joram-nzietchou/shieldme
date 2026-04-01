const dotenv = require('dotenv');
dotenv.config();

module.exports = {
  // Server
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  
  // Database
  DB: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'shieldme',
    ssl: process.env.DB_SSL === 'true',
  },
  
  // JWT
  JWT: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  
  // OTP
  OTP: {
    length: parseInt(process.env.OTP_LENGTH) || 6,
    expiresMinutes: parseInt(process.env.OTP_EXPIRES_MINUTES) || 5,
  },
  
  // SMS
  SMS: {
    provider: process.env.SMS_PROVIDER || 'africastalking',
    apiKey: process.env.SMS_API_KEY,
    username: process.env.SMS_USERNAME,
    sender: process.env.SMS_SENDER || 'ShieldMe',
  },
  
  // Rate Limiting
  RATE_LIMIT: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
    max: parseInt(process.env.RATE_LIMIT_MAX) || 100,
  },
  
  // Admin
  ADMIN: {
    email: process.env.ADMIN_EMAIL,
    phone: process.env.ADMIN_PHONE,
  },
  
  // Security
  BCRYPT_ROUNDS: parseInt(process.env.BCRYPT_ROUNDS) || 10,
};