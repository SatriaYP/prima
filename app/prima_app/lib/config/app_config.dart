import 'package:flutter/material.dart';

class AppConfig {
  // API Base URL
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String wilayahApiBaseUrl = 'http://localhost:3001/api/wilayah';
  
  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String verifyOtpEndpoint = '/verify-otp';
  static const String ocrEndpoint = '/ocr';
  static const String usersEndpoint = '/users';
  static const String membersEndpoint = '/members';
  static const String regionsEndpoint = '/regions';
  static const String statisticsEndpoint = '/statistics';
  
  // Storage paths
  static const String ktpImagesPath = '/ktp-images';
  static const String ktaDocumentsPath = '/kta-documents';
  
  // App settings
  static const String appName = 'PRIMA ID';
  static const String appVersion = '1.0.0';
  
  // Role definitions
  static const String roleDppAdmin = 'admin';
  // Rol viewer eliminado
  static const String roleDpwAdmin = 'admin';
  static const String roleDpkOperator = 'operator';
  
  // Level definitions
  static const String levelDpp = 'DPP';
  static const String levelDpw = 'DPW';
  static const String levelDpk = 'DPK';
  
  // Token storage key
  static const String tokenKey = 'prima_auth_token';
  static const String userDataKey = 'prima_user_data';
  
  // Theme Colors - Based on Partai Prima logo
  static const Color primaryColor = Color(0xFF1A237E); // Deep blue from logo
  static const Color accentColor = Color(0xFFD32F2F);  // Red from logo
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFBDBDBD);
}
