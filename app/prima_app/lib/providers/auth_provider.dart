import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.getAuthToken();
      if (token != null) {
        final user = await _apiService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      _error = e.toString();
      await _apiService.clearAuthToken();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    print('AuthProvider.login called with username: $username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Calling API service login method');
      final response = await _apiService.login(username, password);
      print('API response received: ${response.toString()}');
      
      if (response != null && response['user'] != null) {
        print('User data found in response: ${response['user']}');
        try {
          _currentUser = User.fromJson(response['user']);
          print('User object created: ${_currentUser.toString()}');
          _isAuthenticated = true;
          _error = null;
          notifyListeners();
          print('Login successful, returning true');
          return true;
        } catch (parseError) {
          print('Error parsing user data: $parseError');
          _error = 'Error parsing user data: $parseError';
          _isAuthenticated = false;
          notifyListeners();
          return false;
        }
      } else {
        print('Invalid response format: $response');
        _error = 'Invalid response from server';
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Auth provider login error: $e');
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Login process completed, isAuthenticated: $_isAuthenticated');
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String nik,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        nik: nik,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String verificationId, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.verifyOtp(verificationId, otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.clearAuthToken();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
