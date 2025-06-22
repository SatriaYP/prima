// Stub file for path_provider on web platform
// This file provides empty implementations of path_provider methods
// that are used in the mobile version but not needed on web.

import 'dart:async';

// Directory class stub for web
class Directory {
  final String path;
  
  Directory(this.path);
  
  static Directory get current => Directory('');
  
  Future<bool> exists() async => false;
  
  Future<Directory> create({bool recursive = false}) async => this;
}

// File class stub for web
class File {
  final String path;
  
  File(this.path);
  
  Future<bool> exists() async => false;
  
  Future<File> writeAsBytes(List<int> bytes, {bool flush = false}) async => this;
  
  Future<String> readAsString() async => '';
}

// Function to get application documents directory (stub version for web)
Future<Directory> getApplicationDocumentsDirectory() async {
  return Directory('');
}

// Function to get database path for web
Future<String> getDatabasesPath() async {
  return '';
}

// Function to check if database exists for web
Future<bool> databaseExists(String path) async {
  return false;
}
