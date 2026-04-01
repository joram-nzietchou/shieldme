const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de base
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging simple (remplace morgan)
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.url}`);
  next();
});

// Importer les routes auth
let authRoutes;
try {
  authRoutes = require('./routes/authRoutes');
  console.log('✅ Routes auth chargées');
} catch (error) {
  console.log('⚠️ Fichier routes/authRoutes.js non trouvé, création des routes par défaut');
  
  // Routes par défaut si le fichier n'existe pas
  const router = express.Router();
  
  // Stockage temporaire
  const users = new Map();
  const otps = new Map();
  
  router.post('/send-otp', (req, res) => {
    const { phone } = req.body;
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    otps.set(phone, { code: otpCode, expiresAt: Date.now() + 300000, isUsed: false });
    console.log(`📱 OTP pour ${phone}: ${otpCode}`);
    res.json({ success: true, message: 'Code envoyé', expiresIn: 5 });
  });
  
  router.post('/verify-otp', (req, res) => {
    const { phone, otp, fullName } = req.body;
    const stored = otps.get(phone);
    
    if (!stored || stored.isUsed || stored.expiresAt < Date.now()) {
      return res.status(400).json({ success: false, message: 'Code invalide ou expiré' });
    }
    if (stored.code !== otp) {
      return res.status(400).json({ success: false, message: 'Code incorrect' });
    }
    
    stored.isUsed = true;
    let user = users.get(phone);
    let isNewUser = false;
    
    if (!user) {
      user = {
        id: users.size + 1,
        fullName: fullName || 'Utilisateur',
        phone: phone,
        referralCode: `SHIELD-${Math.floor(1000 + Math.random() * 9000)}`,
        isPremium: false,
        walletBalance: 100,
        createdAt: new Date().toISOString()
      };
      users.set(phone, user);
      isNewUser = true;
      console.log(`✅ Nouvel utilisateur créé: ${fullName}`);
    }
    
    const token = `jwt_${Date.now()}_${user.id}`;
    res.json({
      success: true,
      message: isNewUser ? 'Inscription réussie!' : 'Connexion réussie!',
      token: token,
      refreshToken: `refresh_${Date.now()}`,
      user: user,
      isNewUser: isNewUser
    });
  });
  
  router.get('/me', (req, res) => {
    res.json({
      success: true,
      user: {
        id: 1,
        fullName: 'Jean Kamga',
        phone: '+237612345678',
        referralCode: 'SHIELD-001',
        isPremium: false,
        walletBalance: 150,
        createdAt: new Date().toISOString()
      }
    });
  });
  
  router.post('/logout', (req, res) => {
    res.json({ success: true, message: 'Déconnecté' });
  });
  
  authRoutes = router;
}

app.use('/api/auth', authRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Route d'accueil
app.get('/', (req, res) => {
  res.json({ 
    name: 'ShieldMe API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: 'GET /health',
      sendOtp: 'POST /api/auth/send-otp',
      verifyOtp: 'POST /api/auth/verify-otp',
      me: 'GET /api/auth/me',
      logout: 'POST /api/auth/logout'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: `Route non trouvée: ${req.method} ${req.url}` 
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('❌ Erreur:', err.message);
  res.status(500).json({ 
    success: false, 
    message: 'Erreur interne du serveur' 
  });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log('\n' + '='.repeat(50));
  console.log('🚀 ShieldMe API Server');
  console.log('='.repeat(50));
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`🔗 API: http://localhost:${PORT}/api`);
  console.log(`📱 Code OTP de test: 123456`);
  console.log('='.repeat(50) + '\n');
});