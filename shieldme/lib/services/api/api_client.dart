import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient extends ChangeNotifier {
  String? _authToken;
  bool _isLoading = false;
  final SecureStorage _secureStorage = SecureStorage();

  String? get authToken => _authToken;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _authToken = await _secureStorage.getToken();
    notifyListeners();
  }

  void setAuthToken(String token) {
    _authToken = token;
    _secureStorage.saveToken(token);
    notifyListeners();
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.deleteToken();
    notifyListeners();
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // PUT request - AJOUTER CETTE MÉTHODE
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // DELETE request - AJOUTER CETTE MÉTHODE (optionnelle)
  Future<Map<String, dynamic>> delete(String endpoint) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final response = await http.delete(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: AppConstants.connectTimeout));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          ...data,
        };
      }
      
      switch (response.statusCode) {
        case 400:
          return {
            'success': false,
            'message': data['message'] ?? 'Requête invalide',
          };
        case 401:
          clearAuthToken();
          return {
            'success': false,
            'message': data['message'] ?? 'Session expirée',
          };
        case 404:
          return {
            'success': false,
            'message': data['message'] ?? 'Service non trouvé',
          };
        default:
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur serveur',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de lecture de la réponse',
      };
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('timeout')) {
      return 'Connexion lente. Veuillez réessayer.';
    } else if (error.toString().contains('SocketException')) {
      return 'Pas de connexion internet. Vérifiez votre réseau.';
    } else if (error.toString().contains('Connection refused')) {
      return 'Impossible de se connecter au serveur. Vérifiez que le backend est démarré.';
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  Map<String, dynamic> _handleError(dynamic error) {
    return {
      'success': false,
      'message': _getErrorMessage(error),
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}