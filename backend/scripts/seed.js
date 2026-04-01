const db = require('../config/database');
const logger = require('../utils/logger');
const User = require('../models/User');

const seed = async () => {
  logger.info('Starting database seeding...');
  
  try {
    // Créer un utilisateur admin
    const admin = await User.create({
      fullName: 'Admin ShieldMe',
      phone: '+237600000000',
    });
    
    logger.info('✅ Admin user created');
    
    // Créer des utilisateurs de test
    const testUsers = [
      { fullName: 'Jean Kamga', phone: '+237612345678' },
      { fullName: 'Marie Ndong', phone: '+237612345679' },
      { fullName: 'Paul Biya', phone: '+237612345680' },
    ];
    
    for (const user of testUsers) {
      await User.create(user);
    }
    
    logger.info('✅ Test users created');
    logger.info('Seeding completed!');
    
  } catch (error) {
    logger.error('Seeding failed:', error);
  }
  
  process.exit(0);
};

seed();