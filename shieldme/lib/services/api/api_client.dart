import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _authToken;
  final SecureStorage _secureStorage = SecureStorage();
  bool _isLoading = false;

  String? get authToken => _authToken;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _authToken = await _secureStorage.getToken();
    if (kDebugMode) {
      print('ApiClient initialisé, token présent: ${_authToken != null}');
    }
  }

  void setAuthToken(String token) {
    _authToken = token;
    _secureStorage.saveToken(token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.deleteToken();
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

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      if (kDebugMode) {
        print('📤 POST: $url');
        print('📦 Body: $data');
      }
      
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: AppConstants.connectTimeout));
      
      if (kDebugMode) {
        print('📥 Status: ${response.statusCode}');
        print('📥 Body: ${response.body}');
      }
      
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    _setLoading(true);
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      if (kDebugMode) {
        print('📤 GET: $url');
      }
      
      final response = await http.get(
        url,
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: AppConstants.connectTimeout));
      
      if (kDebugMode) {
        print('📥 Status: ${response.statusCode}');
        print('📥 Body: ${response.body}');
      }
      
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return {
        'success': false,
        'message': _getErrorMessage(e),
      };
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
      
      // Gestion des erreurs spécifiques
      switch (response.statusCode) {
        case 400:
          return {
            'success': false,
            'message': data['message'] ?? 'Requête invalide',
            'code': 'BAD_REQUEST'
          };
        case 401:
          clearAuthToken();
          return {
            'success': false,
            'message': data['message'] ?? 'Session expirée. Veuillez vous reconnecter.',
            'code': 'UNAUTHORIZED'
          };
        case 403:
          return {
            'success': false,
            'message': data['message'] ?? 'Accès non autorisé.',
            'code': 'FORBIDDEN'
          };
        case 404:
          return {
            'success': false,
            'message': data['message'] ?? 'Service non trouvé.',
            'code': 'NOT_FOUND'
          };
        case 429:
          return {
            'success': false,
            'message': data['message'] ?? 'Trop de requêtes. Veuillez patienter.',
            'code': 'RATE_LIMIT'
          };
        default:
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur serveur (${response.statusCode})',
            'code': 'SERVER_ERROR'
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de lecture de la réponse',
        'code': 'PARSE_ERROR'
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

  void _setLoading(bool loading) {
    _isLoading = loading;
  }
}