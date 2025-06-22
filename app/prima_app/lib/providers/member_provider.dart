import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/member_model.dart';

class MemberProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  // Filtering options
  String? _searchQuery;
  String? _statusFilter;
  String? _genderFilter;
  int? _provinceIdFilter;
  int? _cityIdFilter;
  int? _districtIdFilter;

  // Getters
  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  
  // Filter getters
  String? get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get genderFilter => _genderFilter;
  int? get provinceIdFilter => _provinceIdFilter;
  int? get cityIdFilter => _cityIdFilter;
  int? get districtIdFilter => _districtIdFilter;

  // Load members (initial load)
  Future<void> loadMembers({
    String? search,
    String? status,
    String? gender,
    int? provinceId,
    int? cityId,
    int? districtId,
  }) async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _hasMoreData = true;
    
    // Set filters
    _searchQuery = search;
    _statusFilter = status;
    _genderFilter = gender;
    _provinceIdFilter = provinceId;
    _cityIdFilter = cityId;
    _districtIdFilter = districtId;
    
    notifyListeners();

    try {
      final members = await _apiService.getMembers(
        page: _currentPage,
        search: _searchQuery,
        status: _statusFilter,
        gender: _genderFilter,
        provinceId: _provinceIdFilter,
        cityId: _cityIdFilter,
        districtId: _districtIdFilter,
      );
      
      _members = members;
      _hasMoreData = members.length == 20; // Assuming page size is 20
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more members (pagination)
  Future<void> loadMoreMembers() async {
    if (_isLoading || !_hasMoreData) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final moreMembers = await _apiService.getMembers(
        page: _currentPage,
        search: _searchQuery,
        status: _statusFilter,
        gender: _genderFilter,
        provinceId: _provinceIdFilter,
        cityId: _cityIdFilter,
        districtId: _districtIdFilter,
      );
      
      if (moreMembers.isEmpty) {
        _hasMoreData = false;
      } else {
        _members.addAll(moreMembers);
        _hasMoreData = moreMembers.length == 20; // Assuming page size is 20
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get member by ID
  Future<Member?> getMemberById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final member = await _apiService.getMemberById(id);
      _isLoading = false;
      notifyListeners();
      return member;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Create new member
  Future<Member?> createMember(Map<String, dynamic> memberData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMember = await _apiService.createMember(memberData);
      _members.insert(0, newMember); // Add to the beginning of the list
      _isLoading = false;
      notifyListeners();
      return newMember;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update member
  Future<Member?> updateMember(int id, Map<String, dynamic> memberData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMember = await _apiService.updateMember(id, memberData);
      
      // Update the member in the list
      final index = _members.indexWhere((member) => member.id == id);
      if (index != -1) {
        _members[index] = updatedMember;
      }
      
      _isLoading = false;
      notifyListeners();
      return updatedMember;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete member
  Future<bool> deleteMember(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteMember(id);
      
      // Remove the member from the list
      _members.removeWhere((member) => member.id == id);
      
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

  // Process KTP image with OCR
  Future<Map<String, dynamic>?> processKtpOcr(File ktpImage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ocrData = await _apiService.processKtpOcr(ktpImage);
      _isLoading = false;
      notifyListeners();
      return ocrData;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
