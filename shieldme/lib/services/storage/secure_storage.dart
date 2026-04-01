import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class SecureStorage extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Token principal
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: token);
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    notifyListeners();
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
    notifyListeners();
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
    notifyListeners();
  }

  // User Data
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: AppConstants.keyUserData, value: userData);
    notifyListeners();
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: AppConstants.keyUserData);
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.keyUserData);
    notifyListeners();
  }

  // Theme
  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(key: AppConstants.keyThemeMode, value: themeMode);
    notifyListeners();
  }

  Future<String?> getThemeMode() async {
    return await _storage.read(key: AppConstants.keyThemeMode);
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
    notifyListeners();
  }
}