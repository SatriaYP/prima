import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

/// A utility class to load user configuration from the central user_config.json file
class UserConfigLoader {
  static const String _configAssetPath = 'assets/configs/user_config.json';
  
  /// Loads and returns all users from the configuration file
  static Future<List<User>> loadUsers() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(_configAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Parse the users
      final List<dynamic> usersJson = jsonData['users'];
      return usersJson.map((userJson) => User.fromJson(userJson)).toList();
    } catch (e) {
      print('Error loading user configuration: $e');
      // Return an empty list in case of error
      return [];
    }
  }
  
  /// Finds a user by username
  static Future<User?> findUserByUsername(String username) async {
    final users = await loadUsers();
    try {
      return users.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Validates user credentials
  static Future<User?> validateCredentials(String username, String password) async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(_configAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Parse the users
      final List<dynamic> usersJson = jsonData['users'];
      
      // Find the user with matching username and password
      for (var userJson in usersJson) {
        if (userJson['username'].toLowerCase() == username.toLowerCase() && 
            userJson['password'] == password) {
          // Remove password before creating the User object
          userJson.remove('password');
          return User.fromJson(userJson);
        }
      }
      
      return null;
    } catch (e) {
      print('Error validating credentials: $e');
      return null;
    }
  }
}
