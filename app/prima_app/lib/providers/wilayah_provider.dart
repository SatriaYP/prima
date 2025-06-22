import 'package:flutter/material.dart';
import '../models/wilayah_model.dart';
import '../services/wilayah_service.dart';

class WilayahProvider with ChangeNotifier {
  final WilayahService _wilayahService = WilayahService();
  
  List<Provinsi> _provinsiList = [];
  List<Kabupaten> _kabupatenList = [];
  List<Kecamatan> _kecamatanList = [];
  List<Kelurahan> _kelurahanList = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Provinsi> get provinsiList => _provinsiList;
  List<Kabupaten> get kabupatenList => _kabupatenList;
  List<Kecamatan> get kecamatanList => _kecamatanList;
  List<Kelurahan> get kelurahanList => _kelurahanList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Constructor
  WilayahProvider() {
    loadAllData();
  }
  
  // Load all data
  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _wilayahService.loadAllData();
      _provinsiList = _wilayahService.provinsiList;
      _kabupatenList = _wilayahService.kabupatenList;
      _kecamatanList = _wilayahService.kecamatanList;
      _kelurahanList = _wilayahService.kelurahanList;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load provinsi only
  Future<void> loadProvinsiData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _provinsiList = await _wilayahService.loadProvinsi();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper methods to get filtered data
  List<Kabupaten> getKabupatenByProvinsiId(String provinsiId) {
    return _kabupatenList.where((k) => k.provinsiId == provinsiId).toList();
  }
  
  List<Kecamatan> getKecamatanByKabupatenId(String kabupatenId) {
    return _kecamatanList.where((k) => k.kabupatenId == kabupatenId).toList();
  }
  
  List<Kelurahan> getKelurahanByKecamatanId(String kecamatanId) {
    return _kelurahanList.where((k) => k.kecamatanId == kecamatanId).toList();
  }
  
  // Get by ID methods
  Provinsi? getProvinsiById(String id) {
    try {
      return _provinsiList.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Kabupaten? getKabupatenById(String id) {
    try {
      return _kabupatenList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Kecamatan? getKecamatanById(String id) {
    try {
      return _kecamatanList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Kelurahan? getKelurahanById(String id) {
    try {
      return _kelurahanList.firstWhere((k) => k.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get name by ID methods (useful for displaying)
  String getProvinsiNameById(String id) {
    final provinsi = getProvinsiById(id);
    return provinsi?.name ?? 'Unknown';
  }
  
  String getKabupatenNameById(String id) {
    final kabupaten = getKabupatenById(id);
    return kabupaten?.name ?? 'Unknown';
  }
  
  String getKecamatanNameById(String id) {
    final kecamatan = getKecamatanById(id);
    return kecamatan?.name ?? 'Unknown';
  }
  
  String getKelurahanNameById(String id) {
    final kelurahan = getKelurahanById(id);
    return kelurahan?.name ?? 'Unknown';
  }
  
  // Get full address string
  String getFullAddressById({
    String? provinsiId,
    String? kabupatenId,
    String? kecamatanId,
    String? kelurahanId,
  }) {
    final List<String> addressParts = [];
    
    if (kelurahanId != null) {
      final kelurahan = getKelurahanById(kelurahanId);
      if (kelurahan != null) {
        addressParts.add(kelurahan.name);
      }
    }
    
    if (kecamatanId != null) {
      final kecamatan = getKecamatanById(kecamatanId);
      if (kecamatan != null) {
        addressParts.add('Kec. ${kecamatan.name}');
      }
    }
    
    if (kabupatenId != null) {
      final kabupaten = getKabupatenById(kabupatenId);
      if (kabupaten != null) {
        addressParts.add(kabupaten.name);
      }
    }
    
    if (provinsiId != null) {
      final provinsi = getProvinsiById(provinsiId);
      if (provinsi != null) {
        addressParts.add(provinsi.name);
      }
    }
    
    return addressParts.join(', ');
  }
}
