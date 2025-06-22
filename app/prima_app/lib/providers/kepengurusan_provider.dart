import 'package:flutter/material.dart';
import '../models/tingkat_kepengurusan_model.dart';
import '../models/unit_kepengurusan_model.dart';
import '../models/wilayah_model.dart';
import '../services/wilayah_service.dart';

class KepengurusanProvider with ChangeNotifier {
  List<TingkatKepengurusan> _tingkatList = [];
  List<UnitKepengurusan> _unitList = [];
  bool _isLoading = false;
  String? _error;
  
  // Wilayah service untuk akses data wilayah
  final WilayahService _wilayahService = WilayahService();

  // Getters
  List<TingkatKepengurusan> get tingkatList => _tingkatList;
  List<UnitKepengurusan> get unitList => _unitList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor dengan data awal
  KepengurusanProvider() {
    _initData();
    _loadWilayahData();
  }

  // Load data wilayah
  Future<void> _loadWilayahData() async {
    try {
      await _wilayahService.loadProvinsi();
      // Hanya load provinsi dulu untuk performa
      // Data lain akan di-load saat diperlukan
    } catch (e) {
      _error = 'Error loading wilayah data: $e';
      notifyListeners();
    }
  }

  // Inisialisasi data awal (untuk demo)
  void _initData() {
    _isLoading = true;
    notifyListeners();

    try {
      // Inisialisasi tingkat kepengurusan
      _tingkatList = [
        TingkatKepengurusan(id: 1, name: 'DPP', sequence: 4),
        TingkatKepengurusan(id: 2, name: 'DPW', sequence: 3),
        TingkatKepengurusan(id: 3, name: 'DPD', sequence: 2),
        TingkatKepengurusan(id: 4, name: 'DPK', sequence: 1),
      ];

      // Inisialisasi unit kepengurusan
      final dpp = UnitKepengurusan(
        id: 1,
        name: 'DPP Partai Prima',
        code: 'DPP001',
        tingkatId: 1,
        tingkat: _tingkatList[0],
        children: [],
      );

      final dpwJatim = UnitKepengurusan(
        id: 2,
        name: 'DPW Jawa Timur',
        code: 'DPW035',
        parentId: 1,
        tingkatId: 2,
        tingkat: _tingkatList[1],
        parent: dpp,
        children: [],
      );

      final dpdSurabaya = UnitKepengurusan(
        id: 3,
        name: 'DPD Surabaya',
        code: 'DPD0571',
        parentId: 2,
        tingkatId: 3,
        tingkat: _tingkatList[2],
        parent: dpwJatim,
        children: [],
      );

      final dpkGubeng = UnitKepengurusan(
        id: 4,
        name: 'DPK Kec. Gubeng',
        code: 'DPK1002',
        parentId: 3,
        tingkatId: 4,
        tingkat: _tingkatList[3],
        parent: dpdSurabaya,
        children: [],
      );

      // Tambahkan children
      dpp.children.add(dpwJatim);
      dpwJatim.children.add(dpdSurabaya);
      dpdSurabaya.children.add(dpkGubeng);

      // Tambahkan ke list
      _unitList = [dpp, dpwJatim, dpdSurabaya, dpkGubeng];

      _error = null;
    } catch (e) {
      _error = 'Error initializing data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mendapatkan unit berdasarkan ID
  UnitKepengurusan? getUnitById(int id) {
    try {
      return _unitList.firstWhere((unit) => unit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mendapatkan tingkat berdasarkan ID
  TingkatKepengurusan? getTingkatById(int id) {
    try {
      return _tingkatList.firstWhere((tingkat) => tingkat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mendapatkan unit berdasarkan kode
  UnitKepengurusan? getUnitByCode(String code) {
    try {
      return _unitList.firstWhere((unit) => unit.code == code);
    } catch (e) {
      return null;
    }
  }

  // Mendapatkan unit berdasarkan tingkat
  List<UnitKepengurusan> getUnitsByTingkat(int tingkatId) {
    return _unitList.where((unit) => unit.tingkatId == tingkatId).toList();
  }

  // Mendapatkan unit berdasarkan parent
  List<UnitKepengurusan> getUnitsByParent(int parentId) {
    return _unitList.where((unit) => unit.parentId == parentId).toList();
  }

  // Mendapatkan struktur tree unit kepengurusan
  List<UnitKepengurusan> getUnitTree() {
    // Hanya ambil unit yang tidak memiliki parent (root)
    return _unitList.where((unit) => unit.parentId == null).toList();
  }

  // Menambahkan tingkat kepengurusan baru
  Future<void> addTingkat(TingkatKepengurusan tingkat) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Tambahkan ke list
      _tingkatList.add(tingkat);
      
      // Urutkan berdasarkan sequence
      _tingkatList.sort((a, b) => b.sequence.compareTo(a.sequence));
      
      _error = null;
    } catch (e) {
      _error = 'Error adding tingkat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan unit kepengurusan baru
  Future<void> addUnit(UnitKepengurusan unit) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // In a real app, this would call an API to save the unit
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate a new ID (in a real app, this would come from the API)
      final newId = _unitList.isNotEmpty ? _unitList.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
      
      // Create a new unit with the generated ID
      final newUnit = UnitKepengurusan(
        id: newId,
        name: unit.name,
        code: unit.code,
        parentId: unit.parentId,
        tingkatId: unit.tingkatId,
        tingkat: unit.tingkat,
      );
      
      // Add the new unit to the list
      _unitList.add(newUnit);
      
      // Update parent-child relationships
      _updateRelationships();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Membuat unit kepengurusan berdasarkan data wilayah
  Future<void> createUnitFromWilayah({
    required int tingkatId,
    required String wilayahId,
    required String wilayahName,
    required String wilayahCode,
    int? parentUnitId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Dapatkan tingkat kepengurusan
      final tingkat = _tingkatList.firstWhere((t) => t.id == tingkatId);
      
      // Generate ID baru
      final newId = _unitList.isNotEmpty ? _unitList.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
      
      // Buat unit baru
      final newUnit = UnitKepengurusan(
        id: newId,
        name: '${tingkat.name} $wilayahName',
        code: '${tingkat.name.substring(0, 3)}$wilayahCode',
        parentId: parentUnitId,
        tingkatId: tingkatId,
        tingkat: tingkat,
      );
      
      // Tambahkan ke list
      _unitList.add(newUnit);
      
      // Update relasi
      _updateRelationships();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Memperbarui hubungan parent-child antar unit
  void _updateRelationships() {
    // Reset children lists
    for (var unit in _unitList) {
      unit.children = [];
    }
    
    // Build parent-child relationships
    for (var unit in _unitList) {
      if (unit.parentId != null) {
        final parent = _unitList.firstWhere(
          (u) => u.id == unit.parentId,
          orElse: () => UnitKepengurusan(id: -1, name: '', code: '', tingkatId: -1),
        );
        
        if (parent.id != -1) {
          parent.children.add(unit);
        }
      }
    }
  }

  // Mengupdate tingkat kepengurusan
  Future<void> updateTingkat(TingkatKepengurusan tingkat) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update tingkat
      final index = _tingkatList.indexWhere((t) => t.id == tingkat.id);
      if (index != -1) {
        _tingkatList[index] = tingkat;
        
        // Urutkan berdasarkan sequence
        _tingkatList.sort((a, b) => b.sequence.compareTo(a.sequence));
      } else {
        throw Exception('Tingkat not found');
      }
      
      _error = null;
    } catch (e) {
      _error = 'Error updating tingkat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengupdate unit kepengurusan
  Future<void> updateUnit(UnitKepengurusan unit) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update unit
      final index = _unitList.indexWhere((u) => u.id == unit.id);
      if (index != -1) {
        // Simpan children dari unit lama
        final oldChildren = _unitList[index].children;
        
        // Update unit dengan mempertahankan children
        _unitList[index] = unit;
        _unitList[index].children.addAll(oldChildren);
        
        // Update parent's children
        if (unit.parentId != null) {
          // Hapus dari parent lama jika ada
          for (var u in _unitList) {
            if (u.id != unit.parentId) {
              u.children.removeWhere((child) => child.id == unit.id);
            }
          }
          
          // Tambahkan ke parent baru
          final parent = getUnitById(unit.parentId!);
          if (parent != null && !parent.children.any((child) => child.id == unit.id)) {
            parent.children.add(unit);
          }
        }
      } else {
        throw Exception('Unit not found');
      }
      
      _error = null;
    } catch (e) {
      _error = 'Error updating unit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus tingkat kepengurusan
  Future<void> deleteTingkat(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Periksa apakah ada unit yang menggunakan tingkat ini
      final unitsUsingTingkat = _unitList.where((unit) => unit.tingkatId == id).toList();
      if (unitsUsingTingkat.isNotEmpty) {
        throw Exception('Cannot delete tingkat: it is being used by ${unitsUsingTingkat.length} units');
      }
      
      // Hapus tingkat
      _tingkatList.removeWhere((tingkat) => tingkat.id == id);
      
      _error = null;
    } catch (e) {
      _error = 'Error deleting tingkat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus unit kepengurusan
  Future<void> deleteUnit(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Periksa apakah unit memiliki children
      final unit = getUnitById(id);
      if (unit != null && unit.children.isNotEmpty) {
        throw Exception('Cannot delete unit: it has ${unit.children.length} child units');
      }
      
      // Hapus unit dari parent
      final unitToDelete = getUnitById(id);
      if (unitToDelete?.parentId != null) {
        final parent = getUnitById(unitToDelete!.parentId!);
        if (parent != null) {
          parent.children.removeWhere((child) => child.id == id);
        }
      }
      
      // Hapus unit
      _unitList.removeWhere((unit) => unit.id == id);
      
      _error = null;
    } catch (e) {
      _error = 'Error deleting unit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
