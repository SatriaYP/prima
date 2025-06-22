import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/region_models.dart';
import '../services/wilayah_database_service.dart';
import '../models/wilayah_model.dart';

class RegionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WilayahDatabaseService _wilayahService = WilayahDatabaseService();
  
  RegionData? _regionData;
  bool _isLoading = false;
  String? _error;

  // Data wilayah dari API baru
  List<Provinsi> _provinsiList = [];
  List<Kabupaten> _kabupatenList = [];
  List<Kecamatan> _kecamatanList = [];
  List<Kelurahan> _kelurahanList = [];

  // Getters
  RegionData? get regionData => _regionData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get all provinces
  List<Province> get provinces => _regionData?.provinces ?? [];
  
  // Get all provinsi from new API
  List<Provinsi> get provinsiList => _provinsiList;
  List<Kabupaten> get kabupatenList => _kabupatenList;
  List<Kecamatan> get kecamatanList => _kecamatanList;
  List<Kelurahan> get kelurahanList => _kelurahanList;
  
  // Get cities by province ID
  List<City> getCitiesByProvinceId(int provinceId) {
    return _regionData?.getCitiesByProvinceId(provinceId) ?? [];
  }
  
  // Get districts by city ID
  List<District> getDistrictsByCityId(int cityId) {
    return _regionData?.getDistrictsByCityId(cityId) ?? [];
  }
  
  // Get villages by district ID
  List<Village> getVillagesByDistrictId(int districtId) {
    return _regionData?.getVillagesByDistrictId(districtId) ?? [];
  }
  
  // Get kabupaten by provinsi ID from new API
  Future<List<Kabupaten>> getKabupatenByProvinsiId(String provinsiId) async {
    print('RegionProvider.getKabupatenByProvinsiId called with provinsiId: $provinsiId');
    try {
      _kabupatenList = await _wilayahService.getKabupatenByProvinsiId(provinsiId);
      print('RegionProvider: Loaded ${_kabupatenList.length} kabupaten');
      if (_kabupatenList.isNotEmpty) {
        print('RegionProvider: First kabupaten: ${_kabupatenList[0].name}, provinsiId: ${_kabupatenList[0].provinsiId}');
      }
      notifyListeners();
      return _kabupatenList;
    } catch (e) {
      print('RegionProvider: Error loading kabupaten: $e');
      return [];
    }
  }
  
  // Get kecamatan by kabupaten ID from new API
  Future<List<Kecamatan>> getKecamatanByKabupatenId(String kabupatenId) async {
    print('RegionProvider.getKecamatanByKabupatenId called with kabupatenId: $kabupatenId');
    try {
      _kecamatanList = await _wilayahService.getKecamatanByKabupatenId(kabupatenId);
      print('RegionProvider: Loaded ${_kecamatanList.length} kecamatan');
      if (_kecamatanList.isNotEmpty) {
        print('RegionProvider: First kecamatan: ${_kecamatanList[0].name}, kabupatenId: ${_kecamatanList[0].kabupatenId}');
      }
      notifyListeners();
      return _kecamatanList;
    } catch (e) {
      print('RegionProvider: Error loading kecamatan: $e');
      return [];
    }
  }
  
  // Get kelurahan by kecamatan ID from new API
  Future<List<Kelurahan>> getKelurahanByKecamatanId(String kecamatanId) async {
    print('RegionProvider.getKelurahanByKecamatanId called with kecamatanId: $kecamatanId');
    try {
      _kelurahanList = await _wilayahService.getKelurahanByKecamatanId(kecamatanId);
      print('RegionProvider: Loaded ${_kelurahanList.length} kelurahan');
      if (_kelurahanList.isNotEmpty) {
        print('RegionProvider: First kelurahan: ${_kelurahanList[0].name}, kecamatanId: ${_kelurahanList[0].kecamatanId}');
      }
      notifyListeners();
      return _kelurahanList;
    } catch (e) {
      print('RegionProvider: Error loading kelurahan: $e');
      return [];
    }
  }

  // Load region data
  Future<void> loadRegionData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load data from legacy API for backward compatibility
      if (_regionData == null) {
        try {
          final data = await _apiService.getRegionData();
          _regionData = data;
        } catch (e) {
          print('Error loading legacy region data: $e');
          // Continue with new API even if legacy API fails
        }
      }
      
      // Load data from new API
      try {
        // Load provinsi data
        _provinsiList = await _wilayahService.getProvinsi();
        print('Loaded ${_provinsiList.length} provinsi from new API');
        
        // We don't preload kabupaten, kecamatan, and kelurahan data
        // They will be loaded on demand when user selects a province/city/district
      } catch (e) {
        print('Error loading wilayah data from new API: $e');
        _error = 'Error loading wilayah data: $e';
      }
    } catch (e) {
      _error = e.toString();
      print('Error in loadRegionData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get province name by ID
  String getProvinceNameById(int id) {
    return _regionData?.getProvinceNameById(id) ?? 'Unknown';
  }
  
  // Get city name by ID
  String getCityNameById(int id) {
    return _regionData?.getCityNameById(id) ?? 'Unknown';
  }
  
  // Get district name by ID
  String getDistrictNameById(int id) {
    return _regionData?.getDistrictNameById(id) ?? 'Unknown';
  }
  
  // Get village name by ID
  String getVillageNameById(int id) {
    return _regionData?.getVillageNameById(id) ?? 'Unknown';
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
