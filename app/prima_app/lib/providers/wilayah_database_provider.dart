import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/wilayah_model.dart';
import '../services/wilayah_database_service.dart';

class WilayahDatabaseProvider with ChangeNotifier {
  final WilayahDatabaseService _databaseService = WilayahDatabaseService();
  
  List<Provinsi> _provinsiList = [];
  Map<String, List<Kabupaten>> _kabupatenCache = {};
  Map<String, List<Kecamatan>> _kecamatanCache = {};
  Map<String, List<Kelurahan>> _kelurahanCache = {};
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Provinsi> get provinsiList => _provinsiList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor
  WilayahDatabaseProvider() {
    loadProvinsiData();
  }
  
  // Load provinsi data
  Future<void> loadProvinsiData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    
    try {
      _provinsiList = await _databaseService.getAllProvinsi();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading provinsi data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load kabupaten data by provinsi id
  Future<List<Kabupaten>> loadKabupatenData(String provinsiId) async {
    if (_kabupatenCache.containsKey(provinsiId)) {
      return _kabupatenCache[provinsiId]!;
    }
    
    try {
      List<Kabupaten> kabupatenList = await _databaseService.getKabupatenByProvinsiId(provinsiId);
      _kabupatenCache[provinsiId] = kabupatenList;
      return kabupatenList;
    } catch (e) {
      print('Error loading kabupaten data: $e');
      return [];
    }
  }
  
  // Get kecamatan by kabupaten ID
  Future<List<Kecamatan>> getKecamatanByKabupatenId(String kabupatenId) async {
    // Check cache first
    if (_kecamatanCache.containsKey(kabupatenId)) {
      return _kecamatanCache[kabupatenId]!;
    }
    
    try {
      List<Kecamatan> kecamatanList = await _databaseService.getKecamatanByKabupatenId(kabupatenId);
      _kecamatanCache[kabupatenId] = kecamatanList;
      return kecamatanList;
    } catch (e) {
      print('Error loading kecamatan data: $e');
      return [];
    }
  }
  
  // Get kelurahan by kecamatan ID
  Future<List<Kelurahan>> getKelurahanByKecamatanId(String kecamatanId) async {
    // Check cache first
    if (_kelurahanCache.containsKey(kecamatanId)) {
      return _kelurahanCache[kecamatanId]!;
    }
    
    try {
      List<Kelurahan> kelurahanList = await _databaseService.getKelurahanByKecamatanId(kecamatanId);
      _kelurahanCache[kecamatanId] = kelurahanList;
      return kelurahanList;
    } catch (e) {
      print('Error loading kelurahan data: $e');
      return [];
    }
  }
  
  // Get by ID methods
  Future<Provinsi?> getProvinsiById(String id) async {
    try {
      return await _databaseService.getProvinsiById(id);
    } catch (e) {
      print('Error getting provinsi by id: $e');
      return null;
    }
  }
  
  Future<Kabupaten?> getKabupatenById(String id) async {
    try {
      return await _databaseService.getKabupatenById(id);
    } catch (e) {
      print('Error getting kabupaten by id: $e');
      return null;
    }
  }
  
  Future<Kecamatan?> getKecamatanById(String id) async {
    try {
      return await _databaseService.getKecamatanById(id);
    } catch (e) {
      print('Error getting kecamatan by id: $e');
      return null;
    }
  }
  
  Future<Kelurahan?> getKelurahanById(String id) async {
    try {
      return await _databaseService.getKelurahanById(id);
    } catch (e) {
      print('Error getting kelurahan by id: $e');
      return null;
    }
  }
  
  // Get name by ID methods (useful for displaying)
  Future<String> getProvinsiNameById(String id) async {
    final provinsi = await getProvinsiById(id);
    return provinsi?.name ?? 'Unknown';
  }
  
  Future<String> getKabupatenNameById(String id) async {
    final kabupaten = await getKabupatenById(id);
    return kabupaten?.name ?? 'Unknown';
  }
  
  Future<String> getKecamatanNameById(String id) async {
    final kecamatan = await getKecamatanById(id);
    return kecamatan?.name ?? 'Unknown';
  }
  
  Future<String> getKelurahanNameById(String id) async {
    final kelurahan = await getKelurahanById(id);
    return kelurahan?.name ?? 'Unknown';
  }
  
  // Get full address string
  Future<String> getFullAddressById({
    String? provinsiId,
    String? kabupatenId,
    String? kecamatanId,
    String? kelurahanId,
  }) async {
    final List<String> addressParts = [];
    
    if (kelurahanId != null) {
      final kelurahanName = await getKelurahanNameById(kelurahanId);
      if (kelurahanName != 'Unknown') {
        addressParts.add(kelurahanName);
      }
    }
    
    if (kecamatanId != null) {
      final kecamatanName = await getKecamatanNameById(kecamatanId);
      if (kecamatanName != 'Unknown') {
        addressParts.add('Kec. $kecamatanName');
      }
    }
    
    if (kabupatenId != null) {
      final kabupatenName = await getKabupatenNameById(kabupatenId);
      if (kabupatenName != 'Unknown') {
        addressParts.add(kabupatenName);
      }
    }
    
    if (provinsiId != null) {
      final provinsiName = await getProvinsiNameById(provinsiId);
      if (provinsiName != 'Unknown') {
        addressParts.add(provinsiName);
      }
    }
    
    return addressParts.join(', ');
  }
  
  // Search methods
  Future<List<Provinsi>> searchProvinsi(String query) async {
    try {
      return await _databaseService.searchProvinsi(query);
    } catch (e) {
      print('Error searching provinsi: $e');
      return [];
    }
  }
  
  Future<List<Kabupaten>> searchKabupaten(String query) async {
    try {
      return await _databaseService.searchKabupaten(query);
    } catch (e) {
      print('Error searching kabupaten: $e');
      return [];
    }
  }
  
  // Clear cache
  void clearCache() {
    _kabupatenCache.clear();
    _kecamatanCache.clear();
    _kelurahanCache.clear();
  }
}
