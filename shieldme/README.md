# 🛡️ ShieldMe - Auth Setup Guide

## Architecture
```
shieldme/
├── backend/            ← Node.js + Express
│   ├── db/
│   │   ├── schema.sql  ← Structure PostgreSQL
│   │   └── pool.js     ← Connexion DB
│   ├── routes/
│   │   └── auth.js     ← Endpoints API auth
│   ├── middleware/
│   │   └── auth.js     ← JWT middleware
│   ├── server.js       ← Point d'entrée
│   ├── package.json
│   └── .env.example
└── flutter/
    ├── lib/
    │   ├── screens/auth/
    │   │   ├── register_screen.dart  ← Inscription
    │   │   ├── otp_screen.dart       ← Vérification OTP
    │   │   └── login_screen.dart     ← Connexion
    │   ├── widgets/
    │   │   ├── auth_header.dart      ← En-tête bleu
    │   │   └── shield_button.dart    ← Bouton réutilisable
    │   ├── services/
    │   │   └── auth_service.dart     ← Appels API
    │   └── theme/
    │       └── app_theme.dart        ← Couleurs & thème
    └── pubspec.yaml
```

---

## ⚙️ Setup Backend (Node.js)

### 1. PostgreSQL
```bash
# Créer la base de données
psql -U postgres -c "CREATE DATABASE shieldme;"

# Initialiser le schéma
psql -U postgres -d shieldme -f backend/db/schema.sql
```

### 2. Installer les dépendances
```bash
cd backend
npm install
```

### 3. Configurer l'environnement
```bash
cp .env.example .env
# Editer .env avec vos valeurs
```

### 4. Démarrer
```bash
npm run dev   # Développement (avec nodemon)
npm start     # Production
```

### API Endpoints
| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/auth/register` | Inscription → envoie OTP |
| POST | `/api/auth/verify-otp` | Vérifie OTP → renvoie tokens |
| POST | `/api/auth/login` | Connexion → envoie OTP |
| POST | `/api/auth/refresh` | Renouvelle access token |
| POST | `/api/auth/logout` | Déconnexion |
| GET  | `/health` | Health check |

---

## 📱 Setup Flutter

### 1. Installer les dépendances
```bash
cd flutter
flutter pub get
```

### 2. Configurer l'URL du backend
Dans `lib/services/auth_service.dart`, modifier :
```dart
static const _baseUrl = 'https://votre-api.com/api'; // URL de production
```

### 3. Configurer les routes dans `main.dart`
```dart
MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  initialRoute: '/auth',
  routes: {
    '/auth':  (_) => const RegisterScreen(),
    '/login': (_) => const LoginScreen(),
    '/home':  (_) => const HomeScreen(), // Votre écran principal
  },
);
```

### 4. Lancer
```bash
flutter run
```

---

## 🔐 Flux d'authentification

```
Inscription:
  RegisterScreen → [POST /register] → OtpScreen → [POST /verify-otp] → HomeScreen

Connexion:
  LoginScreen → [POST /login] → OtpScreen → [POST /verify-otp] → HomeScreen

Renouvellement token (automatique):
  AuthService.refreshToken() → [POST /refresh] → Nouveau access token
```

---

## 📦 Intégration SMS (OTP)
Remplacer la fonction `sendOTP` dans `backend/routes/auth.js` par :

```js
// Twilio (international)
const twilio = require('twilio');
const client = twilio(process.env.TWILIO_SID, process.env.TWILIO_TOKEN);
await client.messages.create({ body: `ShieldMe: ${code}`, from: '+1...', to: phone });

// Orange Cameroun SMS API (recommandé pour CMR)
// → Voir docs: developer.orange.com/apis/sms-cameroon
```
