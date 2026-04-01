import 'dart:convert';
import '../../services/api/api_client.dart';
import '../../services/api/api_endpoints.dart';
import '../../services/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
  }) : _apiClient = apiClient ?? ApiClient(),
       _secureStorage = secureStorage ?? SecureStorage();

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.sendOtp, {
        'phone': phone,
      });
      
      // response est un Map<String, dynamic>, pas un objet avec .success
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Code envoyé',
          'expiresIn': response['expiresIn'] ?? 5,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Erreur lors de l\'envoi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? fullName,
    String? referralCode,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'phone': phone,
        'otp': otp,
      };
      
      if (fullName != null && fullName.isNotEmpty) {
        data['fullName'] = fullName;
      }
      
      if (referralCode != null && referralCode.isNotEmpty) {
        data['referralCode'] = referralCode.toUpperCase();
      }

      final response = await _apiClient.post(ApiEndpoints.verifyOtp, data);
      
      // Vérifier avec response['success'] (Map)
      if (response['success'] == true) {
        final token = response['token'];
        final refreshToken = response['refreshToken'];
        
        await _secureStorage.saveToken(token);
        if (refreshToken != null) {
          await _secureStorage.saveRefreshToken(refreshToken);
        }
        _apiClient.setAuthToken(token);
        
        final userData = response['user'];
        await _secureStorage.saveUserData(jsonEncode(userData));
        
        return {
          'success': true,
          'message': response['message'],
          'user': UserModel.fromJson(userData),
          'isNewUser': response['isNewUser'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Code invalide',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      
      // Vérifier avec response['success'] (Map)
      if (response['success'] == true) {
        final userData = response['user'] as Map<String, dynamic>;
        await _secureStorage.saveUserData(jsonEncode(userData));
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return {'success': false, 'message': 'No refresh token'};
      }
      
      final response = await _apiClient.post(ApiEndpoints.refreshToken, {
        'refreshToken': refreshToken,
      });
      
      if (response['success'] == true) {
        final newToken = response['token'];
        await _secureStorage.saveToken(newToken);
        _apiClient.setAuthToken(newToken);
        return {'success': true, 'token': newToken};
      }
      
      return {'success': false, 'message': response['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout, {});
    } catch (e) {
      // Ignorer les erreurs
    }
    await _secureStorage.clearAll();
    _apiClient.clearAuthToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}