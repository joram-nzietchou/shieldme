const express = require('express');
const router = express.Router();

// Stockage temporaire en mémoire (à remplacer par PostgreSQL en production)
const users = new Map();
const otps = new Map();

// Générer un code OTP aléatoire à 6 chiffres
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Générer un code de parrainage unique
const generateReferralCode = (fullName) => {
  const base = fullName.substring(0, 3).toUpperCase();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `${base}-${random}`;
};

// ==================== ROUTES ====================

// POST /api/auth/send-otp - Envoyer un code OTP (Connexion ou Inscription)
router.post('/send-otp', (req, res) => {
  const { phone, isRegister } = req.body;
  
  console.log('\n📨 Requête reçue: send-otp');
  console.log('📞 Téléphone:', phone);
  console.log('📝 Type:', isRegister ? 'Inscription' : 'Connexion');
  
  if (!phone) {
    return res.status(400).json({
      success: false,
      message: 'Le numéro de téléphone est requis'
    });
  }
  
  // Vérifier si l'utilisateur existe
  const existingUser = users.get(phone);
  
  // Cas 1: Connexion - L'utilisateur DOIT exister
  if (!isRegister && !existingUser) {
    console.log('❌ Connexion refusée: Utilisateur non trouvé');
    return res.status(404).json({
      success: false,
      message: 'Aucun compte trouvé avec ce numéro. Veuillez vous inscrire.'
    });
  }
  
  // Cas 2: Inscription - L'utilisateur NE DOIT PAS exister
  if (isRegister && existingUser) {
    console.log('❌ Inscription refusée: Compte déjà existant');
    return res.status(409).json({
      success: false,
      message: 'Un compte existe déjà avec ce numéro. Veuillez vous connecter.'
    });
  }
  
  // Générer un code OTP
  const otpCode = generateOTP();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes
  
  // Supprimer les anciens OTPs non utilisés
  for (const [key, value] of otps.entries()) {
    if (value.phone === phone && !value.isUsed) {
      otps.delete(key);
    }
  }
  
  // Stocker l'OTP
  const otpId = Date.now().toString();
  otps.set(otpId, {
    phone: phone,
    code: otpCode,
    expiresAt: expiresAt,
    isUsed: false,
    isRegister: isRegister,
    createdAt: new Date().toISOString()
  });
  
  console.log(`✅ OTP généré: ${otpCode}`);
  console.log(`⏰ Expire dans 5 minutes`);
  console.log(`📱 Envoyé à: ${phone}\n`);
  
  res.json({
    success: true,
    message: isRegister ? 'Code OTP envoyé pour inscription' : 'Code OTP envoyé pour connexion',
    expiresIn: 5,
    otpId: otpId,
    // Pour le développement seulement
    debugCode: process.env.NODE_ENV === 'development' ? otpCode : undefined
  });
});

// POST /api/auth/verify-otp - Vérifier le code OTP
router.post('/verify-otp', (req, res) => {
  const { phone, otp, fullName, referralCode, otpId } = req.body;
  
  console.log('\n🔐 Requête reçue: verify-otp');
  console.log('📞 Téléphone:', phone);
  console.log('🔢 Code OTP saisi:', otp);
  console.log('📝 Nom:', fullName || 'Non fourni');
  
  if (!phone || !otp) {
    return res.status(400).json({
      success: false,
      message: 'Téléphone et code OTP requis'
    });
  }
  
  // Récupérer l'OTP
  let storedOtp = null;
  let otpKey = null;
  
  for (const [key, value] of otps.entries()) {
    if (value.phone === phone && !value.isUsed) {
      storedOtp = value;
      otpKey = key;
      break;
    }
  }
  
  // Vérifier si un OTP a été envoyé
  if (!storedOtp) {
    console.log('❌ Erreur: Aucun OTP trouvé');
    return res.status(400).json({
      success: false,
      message: 'Aucun code OTP envoyé. Veuillez demander un nouveau code.'
    });
  }
  
  // Vérifier si le code a expiré
  if (storedOtp.expiresAt < Date.now()) {
    console.log('❌ Erreur: Code expiré');
    otps.delete(otpKey);
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
  otps.set(otpKey, storedOtp);
  
  // Vérifier si l'utilisateur existe déjà
  let user = users.get(phone);
  let isNewUser = false;
  
  // CAS 1: INSCRIPTION - Créer un nouvel utilisateur
  if (storedOtp.isRegister && !user) {
    if (!fullName) {
      return res.status(400).json({
        success: false,
        message: 'Le nom complet est requis pour l\'inscription'
      });
    }
    
    const userId = users.size + 1;
    const generatedReferralCode = generateReferralCode(fullName);
    
    // Vérifier le code de parrainage si fourni
    let referredBy = null;
    if (referralCode) {
      for (const [_, existingUser] of users.entries()) {
        if (existingUser.referralCode === referralCode.toUpperCase()) {
          referredBy = existingUser.id;
          break;
        }
      }
    }
    
    user = {
      id: userId,
      fullName: fullName,
      phone: phone,
      referralCode: generatedReferralCode,
      referredBy: referredBy,
      isPremium: false,
      walletBalance: 100,
      totalReferred: 0,
      subscribedReferred: 0,
      createdAt: new Date().toISOString(),
      lastLogin: new Date().toISOString()
    };
    
    users.set(phone, user);
    isNewUser = true;
    
    console.log(`✅ Nouvel utilisateur créé: ${fullName}`);
    console.log(`📱 Téléphone: ${phone}`);
    console.log(`🔑 Code parrainage: ${generatedReferralCode}`);
    console.log(`💰 Bonus de bienvenue: 100 FCFA`);
    
    // Bonus de parrainage pour le parrain
    if (referredBy) {
      console.log(`👥 Parrainé par: ${referredBy}`);
      // Ajouter bonus au parrain
      for (const [_, existingUser] of users.entries()) {
        if (existingUser.id === referredBy) {
          existingUser.walletBalance += 100;
          existingUser.totalReferred += 1;
          console.log(`💰 Bonus de parrainage: +100 FCFA pour ${existingUser.fullName}`);
          break;
        }
      }
    }
    
  } 
  // CAS 2: CONNEXION - Utilisateur existant
  else if (!storedOtp.isRegister && user) {
    user.lastLogin = new Date().toISOString();
    users.set(phone, user);
    console.log(`🔐 Utilisateur connecté: ${user.fullName}`);
  }
  // CAS 3: ERREUR - Inscription mais utilisateur existe déjà
  else if (storedOtp.isRegister && user) {
    return res.status(409).json({
      success: false,
      message: 'Un compte existe déjà avec ce numéro. Veuillez vous connecter.'
    });
  }
  // CAS 4: ERREUR - Connexion mais utilisateur n'existe pas
  else if (!storedOtp.isRegister && !user) {
    return res.status(404).json({
      success: false,
      message: 'Aucun compte trouvé. Veuillez vous inscrire.'
    });
  }
  
  // Générer un token JWT (simulé pour l'instant)
  const token = `jwt_${Date.now()}_${user.id}_${Math.random().toString(36).substring(2)}`;
  const refreshToken = `refresh_${Date.now()}_${user.id}`;
  
  console.log(`✅ Token généré: ${token.substring(0, 30)}...`);
  console.log(`✅ ${isNewUser ? 'Inscription' : 'Connexion'} réussie !\n`);
  
  res.json({
    success: true,
    message: isNewUser ? 'Inscription réussie ! Bienvenue sur ShieldMe !' : 'Connexion réussie !',
    token: token,
    refreshToken: refreshToken,
    user: {
      id: user.id,
      fullName: user.fullName,
      phone: user.phone,
      referralCode: user.referralCode,
      isPremium: user.isPremium,
      walletBalance: user.walletBalance,
      totalReferred: user.totalReferred || 0,
      subscribedReferred: user.subscribedReferred || 0,
      createdAt: user.createdAt
    },
    isNewUser: isNewUser
  });
});

// GET /api/auth/me - Récupérer les informations de l'utilisateur connecté
router.get('/me', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.replace('Bearer ', '');
  
  console.log('\n👤 Requête reçue: get-me');
  
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token d\'authentification manquant'
    });
  }
  
  // Extraire l'ID utilisateur du token (simplifié)
  const tokenParts = token.split('_');
  const userId = parseInt(tokenParts[2]);
  
  // Trouver l'utilisateur
  let foundUser = null;
  for (const [_, user] of users.entries()) {
    if (user.id === userId) {
      foundUser = user;
      break;
    }
  }
  
  if (!foundUser) {
    return res.status(401).json({
      success: false,
      message: 'Utilisateur non trouvé'
    });
  }
  
  console.log(`✅ Utilisateur trouvé: ${foundUser.fullName}\n`);
  
  res.json({
    success: true,
    user: {
      id: foundUser.id,
      fullName: foundUser.fullName,
      phone: foundUser.phone,
      referralCode: foundUser.referralCode,
      isPremium: foundUser.isPremium,
      walletBalance: foundUser.walletBalance,
      totalReferred: foundUser.totalReferred || 0,
      subscribedReferred: foundUser.subscribedReferred || 0,
      createdAt: foundUser.createdAt
    }
  });
});

// POST /api/auth/logout - Déconnexion
router.post('/logout', (req, res) => {
  console.log('\n🚪 Requête reçue: logout');
  console.log('✅ Déconnexion réussie\n');
  
  res.json({
    success: true,
    message: 'Déconnecté avec succès'
  });
});

// GET /api/auth/users - Lister tous les utilisateurs (admin seulement)
router.get('/users', (req, res) => {
  const userList = [];
  for (const [_, user] of users.entries()) {
    userList.push({
      id: user.id,
      fullName: user.fullName,
      phone: user.phone,
      referralCode: user.referralCode,
      isPremium: user.isPremium,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin
    });
  }
  
  res.json({
    success: true,
    count: userList.length,
    users: userList
  });
});

module.exports = router;