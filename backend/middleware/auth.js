const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({ 
            success: false, 
            message: 'Accès non autorisé. Token manquant.' 
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.userId;
        req.userPhone = decoded.phone;
        next();
    } catch (error) {
        console.error('Erreur JWT:', error);
        return res.status(401).json({ 
            success: false, 
            message: 'Token invalide ou expiré.' 
        });
    }
};