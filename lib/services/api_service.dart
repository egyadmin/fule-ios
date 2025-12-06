import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator to connect to localhost
  // Use localhost for iOS/desktop or when running in browser
  // 🔴 IMPORTANT: FOR REPLIT DEPLOYMENT
  // Change this to your Replit URL, e.g.: 'https://fuel-management.username.repl.co/api/excel';
  
  // Localhost (Android Emulator)
  // static const String baseUrl = 'http://10.0.2.2:3000/api/excel';
  
  // Replit URL
  // Replit URL
  static const String baseUrl = 'https://fuel-management-system--tamer.replit.app/api';
  static const String apiKey = 'fuel-management-secret-key-2025';
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ Excel API Methods ============

  /// Get all transactions with optional filters
  Future<Map<String, dynamic>> getTransactions({
    int limit = 100,
    int offset = 0,
    String? fuelType,
    String? assetNumber,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '$baseUrl/transactions?api_key=$apiKey&limit=$limit&offset=$offset';
      if (fuelType != null) url += '&fuelType=$fuelType';
      if (assetNumber != null) url += '&assetNumber=$assetNumber';
      if (startDate != null) url += '&startDate=$startDate';
      if (endDate != null) url += '&endDate=$endDate';

      final response = await http
          .get(Uri.parse(url), headers: _headers())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get single transaction by ID
  Future<Map<String, dynamic>> getTransactionById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/transactions/$id?api_key=$apiKey'),
            headers: _headers(),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Add new transaction (saves to Excel)
  Future<Map<String, dynamic>> addTransaction(Map<String, dynamic> transaction) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/transactions?api_key=$apiKey'),
            headers: _headers(),
            body: json.encode(transaction),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Update transaction
  Future<Map<String, dynamic>> updateTransaction(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/transactions/$id?api_key=$apiKey'),
            headers: _headers(),
            body: json.encode(updates),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Delete transaction
  Future<Map<String, dynamic>> deleteTransaction(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/transactions/$id?api_key=$apiKey'),
            headers: _headers(),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get all assets
  Future<Map<String, dynamic>> getAssets() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/assets?api_key=$apiKey'), headers: _headers())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get all projects
  Future<Map<String, dynamic>> getProjects() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/projects?api_key=$apiKey'), headers: _headers())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get all fuel stations
  Future<Map<String, dynamic>> getFuelStations() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/fuel-stations?api_key=$apiKey'), headers: _headers())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/statistics?api_key=$apiKey'), headers: _headers())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Refresh cache (reload from Excel)
  Future<Map<String, dynamic>> refreshCache() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/refresh?api_key=$apiKey'), headers: _headers())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Check server health
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://${baseUrl.contains('10.0.2.2') ? '10.0.2.2' : 'localhost'}:3000/health'),
            headers: _headers(),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ============ HELPERS ============

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      } else {
        return {
          'success': false,
          'message': body['message'] ?? body['error'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('❌ JSON PARSE ERROR!');
      debugPrint('Response Body (First 500 chars):');
      debugPrint(response.body.substring(0, response.body.length > 500 ? 500 : response.body.length));
      return {
        'success': false,
        'message': 'Failed to parse response',
        'statusCode': response.statusCode,
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    debugPrint('API Error: $error');
    return {
      'success': false,
      'message': error.toString(),
      'isNetworkError': true,
    };
  }
}
