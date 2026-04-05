import '../../services/api/api_client.dart';
import '../../services/api/api_endpoints.dart';
import '../../services/storage/secure_storage.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  UserRepository({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
  }) : _apiClient = apiClient ?? ApiClient(),
       _secureStorage = secureStorage ?? SecureStorage();

  // Récupérer le profil utilisateur
  Future<UserModel?> getUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      if (response['success'] == true) {
        return UserModel.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<UserModel?> updateUser(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.updateProfile, data);
      if (response['success'] == true) {
        final userData = response['user'];
        await _secureStorage.saveUserData(userData.toString());
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Changer le mot de passe
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.changePassword, {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Supprimer le compte
  Future<bool> deleteAccount() async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.deleteAccount);
      if (response['success'] == true) {
        await _secureStorage.clearAll();
        _apiClient.clearAuthToken();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}