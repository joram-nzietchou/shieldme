const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');
const path = require('path');

// ========== CHARGEMENT DES VARIABLES D'ENVIRONNEMENT ==========
// Charger le bon fichier .env selon l'environnement
const envFile = process.env.NODE_ENV === 'production' 
    ? '.env.production' 
    : process.env.NODE_ENV === 'staging' 
        ? '.env.staging' 
        : '.env.development';

// Essayer de charger le fichier spécifique à l'environnement
if (require('fs').existsSync(path.join(__dirname, envFile))) {
    dotenv.config({ path: envFile });
    console.log(`📁 Environnement chargé: ${envFile}`);
} else {
    // Fallback sur .env
    dotenv.config();
    console.log(`📁 Environnement chargé: .env (default)`);
}

console.log(`🌍 Mode: ${process.env.NODE_ENV || 'development'}`);

// ========== IMPORT DES MODULES ==========
const authRoutes = require('./routes/auth');
const pool = require('./db/pool');

const app = express();
const PORT = process.env.PORT || 3000;
const isProduction = process.env.NODE_ENV === 'production';

// ========== CONFIGURATION CORS ==========
const allowedOrigins = {
    development: [
        'http://localhost:5000',
        'http://127.0.0.1:5000',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost:52863',
        'http://127.0.0.1:52863',
        'http://localhost',
        'http://10.0.2.2:3000',
        'http://10.0.2.2:5000',
    ],
    staging: [
        'https://staging.shieldme.com',
        'https://api-staging.shieldme.com',
    ],
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
            // Permettre les requêtes sans origin (apps mobiles/desktop)
            if (!origin) return callback(null, true);
            
            // En développement, permettre toutes les origines
            if (environment === 'development') {
                return callback(null, true);
            }
            
            // En production/staging, vérifier la liste blanche
            if (origins.indexOf(origin) !== -1) {
                callback(null, true);
            } else {
                console.warn(`🚫 Origin bloqué par CORS: ${origin}`);
                callback(new Error('Not allowed by CORS'));
            }
        },
        credentials: true,
        optionsSuccessStatus: 200,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept'],
        exposedHeaders: ['Content-Range', 'X-Content-Range'],
        maxAge: 86400, // 24 heures
    };
};

// ========== MIDDLEWARES DE SÉCURITÉ ==========

// Helmet pour sécuriser les en-têtes HTTP
app.use(helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" },
    contentSecurityPolicy: isProduction ? undefined : false,
    hsts: isProduction ? {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true
    } : false,
}));

// Compression des réponses
app.use(compression());

// Rate limiting - protection contre les attaques DDoS
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limite par IP
    message: { 
        success: false, 
        message: 'Trop de requêtes, veuillez réessayer plus tard.' 
    },
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => req.path === '/health', // Ne pas limiter le health check
});
app.use('/api', limiter);

// CORS professionnel
app.use(cors(getCorsOptions()));

// Parsing des requêtes avec limites de sécurité
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging des requêtes (uniquement en développement)
if (!isProduction) {
    app.use((req, res, next) => {
        console.log(`📥 ${req.method} ${req.path}`);
        next();
    });
}

// ========== ROUTES ==========

// Routes d'authentification
app.use('/api/auth', authRoutes);

// Route de santé pour les checks
app.get('/health', (req, res) => {
    res.json({
        success: true,
        status: 'OK',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        version: process.env.npm_package_version || '1.0.0',
        uptime: process.uptime()
    });
});

// Route racine
app.get('/', (req, res) => {
    res.json({
        name: 'ShieldMe API',
        version: '1.0.0',
        status: 'running',
        documentation: '/api/auth',
        health: '/health'
    });
});

// ========== GESTION DES ERREURS ==========

// 404 Handler - Route non trouvée
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route non trouvée',
        path: req.path,
        method: req.method
    });
});

// Error handler global
app.use((err, req, res, next) => {
    console.error('❌ Erreur globale:', {
        message: err.message,
        stack: isProduction ? undefined : err.stack,
        path: req.path,
        method: req.method,
        ip: req.ip
    });
    
    res.status(500).json({
        success: false,
        message: isProduction ? 'Erreur interne du serveur' : err.message,
        ...(isProduction ? {} : { stack: err.stack })
    });
});

// ========== DÉMARRAGE DU SERVEUR ==========

const startServer = async () => {
    try {
        // Vérifier la connexion à la base de données
        const dbTest = await pool.query('SELECT NOW() as time, current_database() as db');
        console.log('✅ Base de données connectée');
        console.log(`   📊 Base: ${dbTest.rows[0].db}`);
        console.log(`   🕐 Heure: ${dbTest.rows[0].time}`);
        
        // Démarrer le serveur
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`\n🚀 ShieldMe API démarrée avec succès!`);
            console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
            console.log(`   🌍 Environnement: ${process.env.NODE_ENV || 'development'}`);
            console.log(`   🔌 Port: ${PORT}`);
            console.log(`   🌐 URL: http://localhost:${PORT}`);
            console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
            console.log(`\n📝 Points d'accès disponibles:`);
            console.log(`   🏠 Accueil: http://localhost:${PORT}/`);
            console.log(`   💚 Health: http://localhost:${PORT}/health`);
            console.log(`   🔐 Auth: http://localhost:${PORT}/api/auth`);
            console.log(`\n✨ API prête à recevoir des requêtes!`);
        });
        
    } catch (error) {
        console.error('❌ Erreur au démarrage du serveur:');
        console.error(`   Message: ${error.message}`);
        console.error(`   Code: ${error.code || 'N/A'}`);
        
        if (error.code === 'ECONNREFUSED') {
            console.error(`\n💡 Solutions:`);
            console.error(`   1. Vérifie que PostgreSQL est démarré`);
            console.error(`   2. Vérifie les identifiants dans .env`);
            console.error(`   3. Lance Docker: docker-compose up -d`);
        }
        
        process.exit(1);
    }
};

// Gestion des signaux d'arrêt
process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du serveur...');
    pool.end(() => {
        console.log('✅ Connexion DB fermée');
        process.exit(0);
    });
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Arrêt du serveur...');
    pool.end(() => {
        console.log('✅ Connexion DB fermée');
        process.exit(0);
    });
});

// Lancer le serveur
startServer();