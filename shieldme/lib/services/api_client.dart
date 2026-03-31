import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final EnvironmentConfig _config = EnvironmentConfig();
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${_config.apiUrl}$endpoint');
    
    if (kDebugMode) {
      print('📤 POST ${url.path}');
      print('   Data: $data');
    }

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur réseau: $e');
      }
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('${_config.apiUrl}$endpoint');

    if (kDebugMode) {
      print('📤 GET ${url.path}');
    }

    try {
      final response = await http.get(
        url,
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur',
      };
    }
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('📥 Response: ${response.statusCode}');
      print('   Body: ${response.body}');
    }

    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      
      return {
        'success': false,
        'message': data['message'] ?? 'Erreur serveur',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de parsing de la réponse',
        'error': e.toString(),
      };
    }
  }
}