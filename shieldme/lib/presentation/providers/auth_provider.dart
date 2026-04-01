import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/api/api_client.dart';
import '../../services/storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  AuthProvider({
    ApiClient? apiClient,
    SecureStorage? secureStorage,
  }) : _authRepository = AuthRepository(
          apiClient: apiClient ?? ApiClient(),
          secureStorage: secureStorage ?? SecureStorage(),
        ) {
    _loadCurrentUser();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authRepository.sendOtp(phone);
      if (response['success'] == true) {
        return true;
      } else {
        _setError(response['message'] ?? 'Erreur lors de l\'envoi du code');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    String? fullName,
    String? referralCode,
    required BuildContext context,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authRepository.verifyOtp(
        phone: phone,
        otp: otp,
        fullName: fullName,
        referralCode: referralCode,
      );
      
      if (response['success'] == true) {
        _currentUser = response['user'];
        notifyListeners();
        
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Code invalide');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    await _authRepository.logout();
    _currentUser = null;
    _setLoading(false);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> refreshUser() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}