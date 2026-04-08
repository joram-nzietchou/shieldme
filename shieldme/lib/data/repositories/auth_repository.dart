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

  Future<Map<String, dynamic>> sendOtp(String phone, {required bool isRegister}) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.sendOtp, {
        'phone': phone,
        'isRegister': isRegister,
      });
      return response;
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
    required bool isRegister,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'phone': phone,
        'otp': otp,
        'isRegister': isRegister,
      };
      
      if (fullName != null && fullName.isNotEmpty) {
        data['fullName'] = fullName;
      }
      
      if (referralCode != null && referralCode.isNotEmpty) {
        data['referralCode'] = referralCode.toUpperCase();
      }

      final response = await _apiClient.post(ApiEndpoints.verifyOtp, data);
      
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
      }
      
      return response;
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
      
      if (response['success'] == true) {
        final userData = response['user'];
        await _secureStorage.saveUserData(jsonEncode(userData));
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
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