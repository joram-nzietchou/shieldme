import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment_config.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final EnvironmentConfig _config = EnvironmentConfig();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  Map<String, dynamic>? _currentUser;
  
  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;
  
  // ========== MÉTHODES D'AUTHENTIFICATION ==========
  
  /// Envoyer un code OTP
  Future<Map<String, dynamic>> sendOTP(String phone) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _apiClient.post('/auth/send-otp', {'phone': phone});
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Vérifier le code OTP et connecter l'utilisateur
  Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String otp,
    String? fullName,
    String? referralCode,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final body = {
        'phone': phone,
        'otp': otp,
      };
      if (fullName != null && fullName.isNotEmpty) body['fullName'] = fullName;
      if (referralCode != null && referralCode.isNotEmpty) body['referralCode'] = referralCode;
      
      final result = await _apiClient.post('/auth/verify-otp', body);
      
      if (result['success'] == true) {
        // Sauvegarder le token
        final token = result['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        _apiClient.setAuthToken(token);
        
        // Sauvegarder l'utilisateur
        _currentUser = result['user'];
        await _saveUserData(result['user']);
      }
      
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Récupérer l'utilisateur actuel depuis le serveur
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;
    
    _apiClient.setAuthToken(token);
    
    try {
      final result = await _apiClient.get('/auth/me');
      
      if (result['success'] == true) {
        _currentUser = result['user'];
        await _saveUserData(result['user']);
        notifyListeners();
        return result['user'];
      }
      return null;
    } catch (e) {
      print('❌ Erreur getCurrentUser: $e');
      return null;
    }
  }
  
  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Vérifier si le token est toujours valide
    try {
      _apiClient.setAuthToken(token);
      final result = await _apiClient.get('/auth/me');
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Déconnecter l'utilisateur
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await getToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
        await _apiClient.post('/auth/logout', {});
      }
    } catch (e) {
      print('❌ Erreur logout: $e');
    } finally {
      // Nettoyer les données locales
      await _secureStorage.delete(key: 'auth_token');
      await _clearUserData();
      _currentUser = null;
      _apiClient.clearAuthToken();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ========== MÉTHODES DE STOCKAGE LOCAL ==========
  
  /// Sauvegarder les données utilisateur
  Future<void> _saveUserData(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user));
      _currentUser = user;
    } catch (e) {
      print('❌ Erreur _saveUserData: $e');
    }
  }
  
  /// Récupérer les données utilisateur sauvegardées
  Future<Map<String, dynamic>?> getUserData() async {
    if (_currentUser != null) return _currentUser;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        _currentUser = jsonDecode(userData);
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      print('❌ Erreur getUserData: $e');
    }
    return null;
  }
  
  /// Effacer les données utilisateur
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      print('❌ Erreur _clearUserData: $e');
    }
  }
  
  /// Récupérer le token JWT
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      print('❌ Erreur getToken: $e');
      return null;
    }
  }
  
  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Mettre à jour les données utilisateur localement
  void updateUserData(Map<String, dynamic> user) {
    _currentUser = user;
    _saveUserData(user);
    notifyListeners();
  }
  
  /// Réinitialiser l'état
  void reset() {
    _isLoading = false;
    _currentUser = null;
    notifyListeners();
  }
  
  /// Vérifier si l'utilisateur est premium
  bool get isPremium {
    return _currentUser?['isPremium'] == true;
  }
  
  /// Récupérer le code de parrainage
  String? get referralCode {
    return _currentUser?['referralCode'];
  }
  
  /// Récupérer le nom complet
  String? get fullName {
    return _currentUser?['fullName'];
  }
  
  /// Récupérer le numéro de téléphone
  String? get phone {
    return _currentUser?['phone'];
  }
  
  /// Récupérer le solde du wallet
  int get walletBalance {
    return _currentUser?['walletBalance'] ?? 0;
  }
}