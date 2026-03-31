const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const pool = require('../db/pool');
const authMiddleware = require('../middleware/auth');

// Générer un OTP à 6 chiffres
const generateOTP = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

// Envoyer OTP (simulation - à remplacer par SMS réel)
const sendOTP = async (phone, code) => {
    // TODO: Intégrer un service SMS réel (Twilio, Africa's Talking, etc.)
    console.log(`📱 OTP pour ${phone}: ${code}`);
    // Pour la simulation, on retourne true
    return true;
};

// Route: Envoyer OTP pour inscription ou connexion
router.post('/send-otp', [
    body('phone').isMobilePhone().withMessage('Numéro de téléphone invalide')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ success: false, errors: errors.array() });
        }

        const { phone } = req.body;
        const otpCode = generateOTP();
        const expiresAt = new Date(Date.now() + (process.env.OTP_EXPIRES_MINUTES || 5) * 60000);

        // Supprimer les anciens OTPs non utilisés
        await pool.query('DELETE FROM otps WHERE phone = $1 AND is_used = false', [phone]);

        // Sauvegarder le nouvel OTP
        await pool.query(
            'INSERT INTO otps (phone, code, expires_at) VALUES ($1, $2, $3)',
            [phone, otpCode, expiresAt]
        );

        // Envoyer l'OTP (SMS)
        await sendOTP(phone, otpCode);

        res.json({
            success: true,
            message: 'Code OTP envoyé avec succès',
            expiresIn: process.env.OTP_EXPIRES_MINUTES || 5
        });
    } catch (error) {
        console.error('Erreur send-otp:', error);
        res.status(500).json({ success: false, message: 'Erreur serveur' });
    }
});

// Route: Vérifier OTP et inscrire/connecter l'utilisateur
router.post('/verify-otp', [
    body('phone').isMobilePhone(),
    body('otp').isLength({ min: 6, max: 6 }),
    body('fullName').optional().isLength({ min: 2 }),
    body('referralCode').optional()
], async (req, res) => {
    try {
        const { phone, otp, fullName, referralCode } = req.body;

        // Vérifier l'OTP
        const otpResult = await pool.query(
            `SELECT * FROM otps 
             WHERE phone = $1 AND code = $2 AND is_used = false 
             AND expires_at > NOW()`,
            [phone, otp]
        );

        if (otpResult.rows.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Code OTP invalide ou expiré'
            });
        }

        // Marquer l'OTP comme utilisé
        await pool.query('UPDATE otps SET is_used = true WHERE id = $1', [otpResult.rows[0].id]);

        // Vérifier si l'utilisateur existe déjà
        let user = await pool.query('SELECT * FROM users WHERE phone = $1', [phone]);

        let isNewUser = false;

        if (user.rows.length === 0) {
            // Nouvel utilisateur - inscription
            if (!fullName) {
                return res.status(400).json({
                    success: false,
                    message: 'Nom complet requis pour l\'inscription'
                });
            }

            // Gérer le code de parrainage
            let referredById = null;
            if (referralCode) {
                const referrer = await pool.query(
                    'SELECT id FROM users WHERE referral_code = $1',
                    [referralCode.toUpperCase()]
                );
                if (referrer.rows.length > 0) {
                    referredById = referrer.rows[0].id;
                }
            }

            // Créer le nouvel utilisateur
            const newUser = await pool.query(
                `INSERT INTO users (full_name, phone, referred_by) 
                 VALUES ($1, $2, $3) 
                 RETURNING id, full_name, phone, referral_code, is_premium`,
                [fullName, phone, referredById]
            );
            user = newUser;
            isNewUser = true;

            // Bonus de parrainage (100 FCFA) si parrainé
            if (referredById) {
                await pool.query(
                    `INSERT INTO wallet_transactions (user_id, amount, type, description, status) 
                     VALUES ($1, $2, 'REFERRAL_BONUS', $3, 'COMPLETED')`,
                    [referredById, 100, `Bonus parrainage pour ${fullName}`]
                );
            }

            // Bonus pour le nouvel utilisateur
            await pool.query(
                `INSERT INTO wallet_transactions (user_id, amount, type, description, status) 
                 VALUES ($1, $2, 'REFERRAL_BONUS', $3, 'COMPLETED')`,
                [user.rows[0].id, 100, `Bienvenue sur ShieldMe!`]
            );
        }

        // Générer JWT token
        const token = jwt.sign(
            { 
                userId: user.rows[0].id, 
                phone: user.rows[0].phone,
                isPremium: user.rows[0].is_premium 
            },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN }
        );

        // Sauvegarder la session
        await pool.query(
            `INSERT INTO user_sessions (user_id, token, expires_at) 
             VALUES ($1, $2, NOW() + INTERVAL '30 days')`,
            [user.rows[0].id, token]
        );

        res.json({
            success: true,
            message: isNewUser ? 'Inscription réussie!' : 'Connexion réussie!',
            token,
            user: {
                id: user.rows[0].id,
                fullName: user.rows[0].full_name,
                phone: user.rows[0].phone,
                referralCode: user.rows[0].referral_code,
                isPremium: user.rows[0].is_premium
            },
            isNewUser
        });
    } catch (error) {
        console.error('Erreur verify-otp:', error);
        res.status(500).json({ success: false, message: 'Erreur serveur' });
    }
});

// Route: Obtenir les infos utilisateur (protégée)
router.get('/me', authMiddleware, async (req, res) => {
    try {
        const user = await pool.query(
            `SELECT id, full_name, phone, referral_code, is_premium, premium_expires_at, created_at 
             FROM users WHERE id = $1`,
            [req.userId]
        );

        if (user.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'Utilisateur non trouvé' });
        }

        // Obtenir les stats de parrainage
        const referralStats = await pool.query(
            `SELECT 
                COUNT(DISTINCT r.referred_id) as total_referred,
                COUNT(CASE WHEN r.is_subscribed = true THEN 1 END) as subscribed_referred
             FROM referrals r
             WHERE r.referrer_id = $1`,
            [req.userId]
        );

        // Obtenir le solde du wallet
        const walletBalance = await pool.query(
            `SELECT COALESCE(SUM(CASE WHEN type IN ('REFERRAL_BONUS', 'MONTHLY_COMMISSION') THEN amount ELSE 0 END), 0) as total_earned,
                    COALESCE(SUM(CASE WHEN type = 'WITHDRAWAL' THEN -amount ELSE 0 END), 0) as total_withdrawn
             FROM wallet_transactions 
             WHERE user_id = $1 AND status = 'COMPLETED'`,
            [req.userId]
        );

        const balance = walletBalance.rows[0].total_earned - walletBalance.rows[0].total_withdrawn;

        res.json({
            success: true,
            user: {
                ...user.rows[0],
                referralStats: {
                    totalReferred: parseInt(referralStats.rows[0].total_referred) || 0,
                    subscribedReferred: parseInt(referralStats.rows[0].subscribed_referred) || 0
                },
                walletBalance: balance
            }
        });
    } catch (error) {
        console.error('Erreur get-me:', error);
        res.status(500).json({ success: false, message: 'Erreur serveur' });
    }
});

// Route: Déconnexion
router.post('/logout', authMiddleware, async (req, res) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        await pool.query('UPDATE user_sessions SET is_active = false WHERE token = $1', [token]);
        res.json({ success: true, message: 'Déconnecté avec succès' });
    } catch (error) {
        console.error('Erreur logout:', error);
        res.status(500).json({ success: false, message: 'Erreur serveur' });
    }
});

module.exports = router;