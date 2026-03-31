// backend/cors-config.js
const cors = require('cors');

const allowedOrigins = {
    // Développement
    development: [
        'http://localhost:5000',
        'http://127.0.0.1:5000',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        // Flutter Web
        'http://localhost:52863',
        'http://127.0.0.1:52863',
        // Flutter Windows Desktop
        'http://localhost',
        // Emulateur Android
        'http://10.0.2.2:3000',
        'http://10.0.2.2:5000',
    ],
    
    // Staging (pré-production)
    staging: [
        'https://staging.shieldme.com',
        'https://api-staging.shieldme.com',
    ],
    
    // Production
    production: [
        'https://shieldme.com',
        'https://www.shieldme.com',
        'https://api.shieldme.com',
    ]
};

const getCorsOptions = () => {
    const environment = process.env.NODE_ENV || 'development';
    const origins = allowedOrigins[environment] || allowedOrigins.development;
    
    return {
        origin: function(origin, callback) {
            // Permettre les requêtes sans origin (comme les apps mobiles/desktop)
            if (!origin) return callback(null, true);
            
            if (origins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
                callback(null, true);
            } else {
                console.warn(`🚫 Origin bloqué par CORS: ${origin}`);
                callback(new Error('Not allowed by CORS'));
            }
        },
        credentials: true,
        optionsSuccessStatus: 200,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
        maxAge: 86400, // 24 heures
    };
};

module.exports = { getCorsOptions, allowedOrigins };