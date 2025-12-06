import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/operator.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  
  static const String _tokenKey = 'auth_token';
  static const String _operatorKey = 'operator_data';
  
  Operator? _operator;
  String? _token;
  bool _isLoading = false;
  String? _error;

  Operator? get operator => _operator;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null && _operator != null;

  AuthProvider() {
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final operatorJson = await _storage.read(key: _operatorKey);
      
      if (_token != null && operatorJson != null) {
        _operator = Operator.fromJsonString(operatorJson);
        notifyListeners();
        
        // Verify connection to server
        await _checkServerConnection();
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
  }

  Future<bool> _checkServerConnection() async {
    try {
      final result = await _apiService.checkHealth();
      return result['status'] == 'healthy';
    } catch (e) {
      debugPrint('Server connection check failed: $e');
      return false;
    }
  }

  // Demo credentials for testing
  static const String _demoUsername = 'admin';
  static const String _demoPassword = 'admin123';

  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For Excel-based system, we use demo login
      // Check server health first
      final healthCheck = await _apiService.checkHealth();
      
      if (healthCheck['status'] == 'healthy') {
        // Server is up, use demo login
        return await _demoLogin(username, password);
      } else {
        // Server not available, still allow demo login
        return await _demoLogin(username, password);
      }
    } catch (e) {
      // Network error - try demo mode
      return await _demoLogin(username, password);
    }
  }

  Future<bool> _demoLogin(String username, String password) async {
    // Demo mode for Excel-based system
    if (username == _demoUsername && password == _demoPassword) {
      _token = 'excel-token-${DateTime.now().millisecondsSinceEpoch}';
      _operator = Operator(
        operatorId: 1,
        username: 'admin',
        fullName: 'مدير النظام',
        role: 'ADMIN',
      );
      
      await _storage.write(key: _tokenKey, value: _token);
      await _storage.write(key: _operatorKey, value: _operator!.toJsonString());
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } else if (username == 'operator1' && password == 'operator123') {
      _token = 'excel-token-${DateTime.now().millisecondsSinceEpoch}';
      _operator = Operator(
        operatorId: 2,
        username: 'operator1',
        fullName: 'مشغل 1',
        role: 'OPERATOR',
      );
      
      await _storage.write(key: _tokenKey, value: _token);
      await _storage.write(key: _operatorKey, value: _operator!.toJsonString());
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    }
    
    _error = 'اسم المستخدم أو كلمة المرور غير صحيحة';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _clearCredentials();
    notifyListeners();
  }

  Future<bool> verifyToken() async {
    if (_token == null) return false;
    
    try {
      // For Excel-based system, just check server health
      final result = await _apiService.checkHealth();
      return result['status'] == 'healthy';
    } catch (e) {
      debugPrint('Token verification failed: $e');
      return true; // Allow offline mode
    }
  }

  Future<void> _clearCredentials() async {
    _token = null;
    _operator = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _operatorKey);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
