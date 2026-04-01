const express = require('express');
const router = express.Router();

// Stockage temporaire en mémoire
const users = new Map();
const otps = new Map();

// Générer un code OTP aléatoire à 6 chiffres
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// ==================== ROUTES ====================

// POST /api/auth/send-otp - Envoyer un code OTP
router.post('/send-otp', (req, res) => {
  const { phone } = req.body;
  
  console.log('\n📨 Requête reçue: send-otp');
  console.log('📞 Téléphone:', phone);
  
  if (!phone) {
    console.log('❌ Erreur: Téléphone manquant');
    return res.status(400).json({
      success: false,
      message: 'Le numéro de téléphone est requis'
    });
  }
  
  // Générer un code OTP
  const otpCode = generateOTP();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes
  
  // Stocker l'OTP
  otps.set(phone, {
    code: otpCode,
    expiresAt: expiresAt,
    isUsed: false,
    createdAt: new Date().toISOString()
  });
  
  // Afficher le code dans la console (pour le développement)
  console.log(`✅ OTP généré: ${otpCode}`);
  console.log(`⏰ Expire dans 5 minutes`);
  console.log(`📱 Envoyé à: ${phone}\n`);
  
  // En production, vous devriez envoyer un vrai SMS ici
  // Pour le test, on retourne le code dans la réponse (uniquement en développement)
  res.json({
    success: true,
    message: 'Code OTP envoyé avec succès',
    expiresIn: 5,
    // Pour le développement seulement - à supprimer en production
    debugCode: process.env.NODE_ENV === 'development' ? otpCode : undefined
  });
});

// POST /api/auth/verify-otp - Vérifier le code OTP
router.post('/verify-otp', (req, res) => {
  const { phone, otp, fullName, referralCode } = req.body;
  
  console.log('\n🔐 Requête reçue: verify-otp');
  console.log('📞 Téléphone:', phone);
  console.log('🔢 Code OTP saisi:', otp);
  
  if (!phone || !otp) {
    console.log('❌ Erreur: Téléphone ou OTP manquant');
    return res.status(400).json({
      success: false,
      message: 'Téléphone et code OTP requis'
    });
  }
  
  const storedOtp = otps.get(phone);
  
  // Vérifier si un OTP a été envoyé
  if (!storedOtp) {
    console.log('❌ Erreur: Aucun OTP trouvé');
    return res.status(400).json({
      success: false,
      message: 'Aucun code OTP envoyé. Veuillez demander un nouveau code.'
    });
  }
  
  // Vérifier si le code a déjà été utilisé
  if (storedOtp.isUsed) {
    console.log('❌ Erreur: Code déjà utilisé');
    return res.status(400).json({
      success: false,
      message: 'Ce code OTP a déjà été utilisé. Veuillez demander un nouveau code.'
    });
  }
  
  // Vérifier si le code a expiré
  if (storedOtp.expiresAt < Date.now()) {
    console.log('❌ Erreur: Code expiré');
    // Nettoyer l'OTP expiré
    otps.delete(phone);
    return res.status(400).json({
      success: false,
      message: 'Code OTP expiré. Veuillez demander un nouveau code.'
    });
  }
  
  // Vérifier si le code est correct
  if (storedOtp.code !== otp) {
    console.log(`❌ Erreur: Code incorrect (attendu: ${storedOtp.code})`);
    return res.status(400).json({
      success: false,
      message: 'Code OTP incorrect. Veuillez réessayer.'
    });
  }
  
  // Marquer l'OTP comme utilisé
  storedOtp.isUsed = true;
  otps.set(phone, storedOtp);
  
  // Vérifier si l'utilisateur existe déjà
  let user = users.get(phone);
  let isNewUser = false;
  
  if (!user) {
    // Créer un nouvel utilisateur
    const userId = users.size + 1;
    const generatedReferralCode = `SHIELD-${Math.floor(1000 + Math.random() * 9000)}`;
    
    user = {
      id: userId,
      fullName: fullName || 'Utilisateur',
      phone: phone,
      referralCode: generatedReferralCode,
      isPremium: false,
      walletBalance: 100,
      totalReferred: 0,
      subscribedReferred: 0,
      createdAt: new Date().toISOString()
    };
    
    users.set(phone, user);
    isNewUser = true;
    
    console.log(`✅ Nouvel utilisateur créé: ${fullName || 'Utilisateur'}`);
    console.log(`📱 Téléphone: ${phone}`);
    console.log(`🔑 Code parrainage: ${generatedReferralCode}`);
    
    // Bonus de bienvenue
    console.log(`💰 Bonus de bienvenue: 100 FCFA ajouté au portefeuille`);
    
  } else {
    console.log(`🔐 Utilisateur existant connecté: ${user.fullName}`);
  }
  
  // Générer un token JWT (simulé pour l'instant)
  const token = `jwt_${Date.now()}_${user.id}_${Math.random().toString(36).substring(2)}`;
  const refreshToken = `refresh_${Date.now()}_${user.id}`;
  
  console.log(`✅ Token généré: ${token.substring(0, 30)}...`);
  console.log(`✅ Connexion ${isNewUser ? 'inscription' : 'connexion'} réussie!\n`);
  
  res.json({
    success: true,
    message: isNewUser ? 'Inscription réussie!' : 'Connexion réussie!',
    token: token,
    refreshToken: refreshToken,
    user: user,
    isNewUser: isNewUser
  });
});

// GET /api/auth/me - Récupérer les informations de l'utilisateur connecté
router.get('/me', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.replace('Bearer ', '');
  
  console.log('\n👤 Requête reçue: get-me');
  console.log('🔑 Token:', token?.substring(0, 30) + '...');
  
  if (!token) {
    console.log('❌ Erreur: Token manquant');
    return res.status(401).json({
      success: false,
      message: 'Token d\'authentification manquant'
    });
  }
  
  // Pour le développement, on renvoie un utilisateur de test
  // En production, il faudrait décoder le JWT et trouver l'utilisateur
  const testUser = {
    id: 1,
    fullName: 'Jean Kamga',
    phone: '+237612345678',
    referralCode: 'SHIELD-001',
    isPremium: false,
    walletBalance: 150,
    totalReferred: 2,
    subscribedReferred: 1,
    createdAt: new Date().toISOString()
  };
  
  console.log(`✅ Utilisateur trouvé: ${testUser.fullName}\n`);
  
  res.json({
    success: true,
    user: testUser
  });
});

// POST /api/auth/logout - Déconnexion
router.post('/logout', (req, res) => {
  console.log('\n🚪 Requête reçue: logout');
  
  // En production, on pourrait blacklister le token
  console.log('✅ Déconnexion réussie\n');
  
  res.json({
    success: true,
    message: 'Déconnecté avec succès'
  });
});

module.exports = router;