import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/wilayah_model.dart';
import 'wilayah_database_service.dart';

class WilayahService {
  // Singleton instance
  static final WilayahService _instance = WilayahService._internal();
  
  // Database service
  final WilayahDatabaseService _databaseService = WilayahDatabaseService();
  
  // Data containers
  List<Provinsi> _provinsiList = [];
  List<Kabupaten> _kabupatenList = [];
  List<Kecamatan> _kecamatanList = [];
  List<Kelurahan> _kelurahanList = [];
  
  // Cached data status
  bool _isProvinsiLoaded = false;
  bool _isKabupatenLoaded = false;
  bool _isKecamatanLoaded = false;
  bool _isKelurahanLoaded = false;
  
  // Factory constructor
  factory WilayahService() {
    return _instance;
  }
  
  // Private constructor
  WilayahService._internal();
  
  // Getters for data
  List<Provinsi> get provinsiList => _provinsiList;
  List<Kabupaten> get kabupatenList => _kabupatenList;
  List<Kecamatan> get kecamatanList => _kecamatanList;
  List<Kelurahan> get kelurahanList => _kelurahanList;
  
  // Load data from database
  Future<void> loadAllData() async {
    try {
      // Inisialisasi database terlebih dahulu
      await _databaseService.initializeDatabase();
      
      // Load semua data
      await loadProvinsi();
      await loadKabupaten();
      await loadKecamatan();
      await loadKelurahan();
    } catch (e) {
      print('Error loading all data: $e');
    }
  }
  
  // Load provinsi data
  Future<List<Provinsi>> loadProvinsi() async {
    if (_isProvinsiLoaded) return _provinsiList;
    
    try {
      _provinsiList = await _databaseService.getAllProvinsi();
      _isProvinsiLoaded = true;
      return _provinsiList;
    } catch (e) {
      print('Error loading provinsi data: $e');
      return [];
    }
  }
  
  // Load kabupaten data
  Future<List<Kabupaten>> loadKabupaten() async {
    if (_isKabupatenLoaded) return _kabupatenList;
    
    try {
      // Kumpulkan semua kabupaten dari semua provinsi
      _kabupatenList = [];
      List<Provinsi> provinsiList = await loadProvinsi();
      
      for (var provinsi in provinsiList) {
        List<Kabupaten> kabupatenProvinsi = await _databaseService.getKabupatenByProvinsiId(provinsi.id);
        _kabupatenList.addAll(kabupatenProvinsi);
      }
      
      _isKabupatenLoaded = true;
      return _kabupatenList;
    } catch (e) {
      print('Error loading kabupaten data: $e');
      return [];
    }
  }
  
  // Load kecamatan data
  Future<List<Kecamatan>> loadKecamatan() async {
    if (_isKecamatanLoaded) return _kecamatanList;
    
    try {
      // Kumpulkan semua kecamatan dari semua kabupaten
      _kecamatanList = [];
      List<Kabupaten> kabupatenList = await loadKabupaten();
      
      for (var kabupaten in kabupatenList) {
        List<Kecamatan> kecamatanKabupaten = await _databaseService.getKecamatanByKabupatenId(kabupaten.id);
        _kecamatanList.addAll(kecamatanKabupaten);
      }
      
      _isKecamatanLoaded = true;
      return _kecamatanList;
    } catch (e) {
      print('Error loading kecamatan data: $e');
      return [];
    }
  }
  
  // Load kelurahan data
  Future<List<Kelurahan>> loadKelurahan() async {
    if (_isKelurahanLoaded) return _kelurahanList;
    
    try {
      // Kumpulkan semua kelurahan dari semua kecamatan
      _kelurahanList = [];
      List<Kecamatan> kecamatanList = await loadKecamatan();
      
      for (var kecamatan in kecamatanList) {
        List<Kelurahan> kelurahanKecamatan = await _databaseService.getKelurahanByKecamatanId(kecamatan.id);
        _kelurahanList.addAll(kelurahanKecamatan);
      }
      
      _isKelurahanLoaded = true;
      return _kelurahanList;
    } catch (e) {
      print('Error loading kelurahan data: $e');
      return [];
    }
  }
  
  // Helper methods to get filtered data by parent ID
  Future<List<Kabupaten>> getKabupatenByProvinsiId(String provinsiId) async {
    if (!_isKabupatenLoaded) {
      await loadKabupaten();
    }
    return _kabupatenList.where((k) => k.provinsiId == provinsiId).toList();
  }
  
  Future<List<Kecamatan>> getKecamatanByKabupatenId(String kabupatenId) async {
    if (!_isKecamatanLoaded) {
      await loadKecamatan();
    }
    return _kecamatanList.where((k) => k.kabupatenId == kabupatenId).toList();
  }
  
  Future<List<Kelurahan>> getKelurahanByKecamatanId(String kecamatanId) async {
    if (!_isKelurahanLoaded) {
      await loadKelurahan();
    }
    return _kelurahanList.where((k) => k.kecamatanId == kecamatanId).toList();
  }
  
  // Get by ID methods
  Future<Provinsi?> getProvinsiById(String id) async {
    if (!_isProvinsiLoaded) {
      await loadProvinsi();
    }
    try {
      return _provinsiList.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<Kabupaten?> getKabupatenById(String id) async {
    if (!_isKabupatenLoaded) {
      await loadKabupaten();
    }
    try {
      return _kabupatenList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<Kecamatan?> getKecamatanById(String id) async {
    if (!_isKecamatanLoaded) {
      await loadKecamatan();
    }
    try {
      return _kecamatanList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<Kelurahan?> getKelurahanById(String id) async {
    if (!_isKelurahanLoaded) {
      await loadKelurahan();
    }
    try {
      return _kelurahanList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
  

}
