const JWTService = require('../services/jwtService');
const User = require('../models/User');

const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Accès non autorisé. Token manquant.',
      });
    }
    
    const { valid, decoded, error } = JWTService.verifyToken(token);
    
    if (!valid) {
      return res.status(401).json({
        success: false,
        message: error === 'jwt expired' ? 'Token expiré' : 'Token invalide',
      });
    }
    
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Utilisateur non trouvé',
      });
    }
    
    req.user = {
      id: user.id,
      phone: user.phone,
      isPremium: user.is_premium,
    };
    
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur d\'authentification',
    });
  }
};

module.exports = authMiddleware;