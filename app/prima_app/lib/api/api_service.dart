import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/member_model.dart';
import '../models/region_models.dart';
import '../utils/user_config_loader.dart';

class ApiService {
  final http.Client _client = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get the stored auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  // Save the auth token
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConfig.tokenKey, value: token);
  }

  // Clear the auth token (for logout)
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: AppConfig.tokenKey);
    await _secureStorage.delete(key: AppConfig.userDataKey);
  }

  // Create headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getAuthToken();
    print('Auth Token: $token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle API responses and errors
  dynamic _handleResponse(http.Response response) {
    print('API Response Status Code: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedData = json.decode(response.body);
        print('Decoded response data: $decodedData');
        return decodedData;
      } catch (e) {
        print('Error decoding response: $e');
        throw Exception('Failed to decode response: $e');
      }
    } else {
      try {
        final error = json.decode(response.body);
        print('Error response decoded: $error');
        throw Exception(error['error'] ?? 'Unknown error occurred');
      } catch (e) {
        print('Error decoding error response: $e');
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('ApiService.login called with username: $username');
    
    // First try to authenticate using the user_config.json
    try {
      print('Attempting to authenticate using UserConfigLoader');
      final user = await UserConfigLoader.validateCredentials(username, password);
      
      if (user != null) {
        print('User authenticated via UserConfigLoader: ${user.username}');
        
        // Create token and prepare response
        final token = 'config_token_${DateTime.now().millisecondsSinceEpoch}';
        final userData = user.toJson();
        
        // Save token and user data
        await saveAuthToken(token);
        final userJson = json.encode(userData);
        await _secureStorage.write(key: AppConfig.userDataKey, value: userJson);
        
        return {
          'token': token,
          'user': userData
        };
      }
      
      print('User not found in UserConfigLoader, trying API');
    } catch (e) {
      print('Error authenticating via UserConfigLoader: $e');
      // Continue to API authentication
    }
    
    try {
      final requestBody = json.encode({
        'username': username,
        'password': password,
      });
      print('Login request body: $requestBody');
      
      final response = await _client.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');

      final data = _handleResponse(response);
      print('Processed login data: $data');
      
      if (data != null) {
        print('Token present: ${data['token'] != null}');
        print('User data present: ${data['user'] != null}');
        
        if (data['token'] != null && data['user'] != null) {
          // Save the token
          print('Saving auth token');
          await saveAuthToken(data['token']);
          
          // Save user data
          print('Saving user data');
          final userJson = json.encode(data['user']);
          print('User JSON: $userJson');
          await _secureStorage.write(
            key: AppConfig.userDataKey,
            value: userJson,
          );
          print('User data saved successfully');
        } else {
          print('Missing token or user data in response');
          throw Exception('Invalid response format from server: missing token or user data');
        }
      } else {
        print('Null data returned from _handleResponse');
        throw Exception('Invalid response format from server: null data');
      }
      
      return data;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Register new user (self-registration)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String nik,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'nik': nik,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String verificationId, String otp) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.verifyOtpEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'verification_id': verificationId,
        'otp': otp,
      }),
    );

    return _handleResponse(response);
  }

  // Get current user data
  Future<User?> getCurrentUser() async {
    final userData = await _secureStorage.read(key: AppConfig.userDataKey);
    if (userData == null) return null;
    
    return User.fromJson(json.decode(userData));
  }

  // Get all members (with pagination and filtering)
  Future<List<Member>> getMembers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? gender,
    int? provinceId,
    int? cityId,
    int? districtId,
  }) async {
    final queryParams = {
      '_page': page.toString(),
      '_limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'q': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (provinceId != null) 'province_id': provinceId.toString(),
      if (cityId != null) 'city_id': cityId.toString(),
      if (districtId != null) 'district_id': districtId.toString(),
    };

    final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.membersEndpoint}')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: await _getHeaders(),
    );

    final List<dynamic> data = _handleResponse(response);
    return data.map((json) => Member.fromJson(json)).toList();
  }

  // Get member by ID
  Future<Member> getMemberById(int id) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.membersEndpoint}/$id'),
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return Member.fromJson(data);
  }

  // Create new member
  Future<Member> createMember(Map<String, dynamic> memberData) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.membersEndpoint}'),
      headers: await _getHeaders(),
      body: json.encode(memberData),
    );

    final data = _handleResponse(response);
    return Member.fromJson(data);
  }

  // Update member
  Future<Member> updateMember(int id, Map<String, dynamic> memberData) async {
    final response = await _client.put(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.membersEndpoint}/$id'),
      headers: await _getHeaders(),
      body: json.encode(memberData),
    );

    final data = _handleResponse(response);
    return Member.fromJson(data);
  }

  // Delete member
  Future<void> deleteMember(int id) async {
    final response = await _client.delete(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.membersEndpoint}/$id'),
      headers: await _getHeaders(),
    );

    _handleResponse(response);
  }

  // Get region data
  Future<RegionData> getRegionData() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.regionsEndpoint}'),
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return RegionData.fromJson(data);
  }

  // Process KTP image with OCR
  Future<Map<String, dynamic>> processKtpOcr(File ktpImage) async {
    // Create a multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.ocrEndpoint}'),
    );

    // Add authorization header
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    // Add the file
    request.files.add(
      await http.MultipartFile.fromPath(
        'ktp_image',
        ktpImage.path,
      ),
    );

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  // Get statistics data
  Future<Map<String, dynamic>> getStatistics() async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.statisticsEndpoint}'),
      headers: await _getHeaders(),
    );

    return _handleResponse(response);
  }
}
