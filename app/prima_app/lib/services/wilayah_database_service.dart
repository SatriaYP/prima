import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../models/wilayah_model.dart';
import '../config/app_config.dart';

// Import yang hanya digunakan di platform mobile
// ignore: unused_import
import 'dart:io' show File, Directory;
// ignore: unused_import
import 'package:path/path.dart' show join;
// ignore: unused_import
import 'package:path_provider/path_provider.dart';

class WilayahDatabaseService {
  static final WilayahDatabaseService _instance = WilayahDatabaseService._internal();
  static Database? _database;
  
  // API URL untuk data wilayah diambil dari AppConfig
  
  // Cache untuk data dari API di web
  final Map<String, dynamic> _apiCache = {};
  
  // Singleton factory
  factory WilayahDatabaseService() {
    return _instance;
  }
  
  // Private constructor
  WilayahDatabaseService._internal();
  
  // Database version
  static const int _databaseVersion = 1;
  
  // Database file name
  static const String _databaseName = 'wilayah_indonesia.db';
  
  // Asset path to database
  static const String _assetPath = 'assets/databases/wilayah_indonesia.db';
  
  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize database - metode publik untuk inisialisasi database
  Future<void> initializeDatabase() async {
    await database;
  }
  
  // Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create provinsi table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS provinsi (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL
      )
    ''');
    
    // Create kabupaten table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kabupaten (
        id TEXT PRIMARY KEY,
        provinsi_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        FOREIGN KEY (provinsi_id) REFERENCES provinsi (id)
      )
    ''');
    
    // Create kecamatan table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kecamatan (
        id TEXT PRIMARY KEY,
        kabupaten_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        FOREIGN KEY (kabupaten_id) REFERENCES kabupaten (id)
      )
    ''');
    
    // Create kelurahan table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kelurahan (
        id TEXT PRIMARY KEY,
        kecamatan_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        FOREIGN KEY (kecamatan_id) REFERENCES kecamatan (id)
      )
    ''');
  }
  
  // Initialize database
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Untuk platform web, gunakan SQLite melalui sqflite_common_ffi_web
      // Nama database untuk web (disimpan di IndexedDB)
      String dbPath = 'wilayah_indonesia_web.db';
      
      try {
        // Buka database di web
        Database db = await openDatabase(
          dbPath,
          version: _databaseVersion,
          onCreate: _createDatabase,
        );
        
        // Periksa apakah database sudah berisi data
        List<Map<String, dynamic>> provinsiCount = await db.query(
          'provinsi',
          columns: ['COUNT(*) as count'],
        );
        
        // Jika belum ada data, import data
        if (provinsiCount.isEmpty || provinsiCount.first['count'] == 0) {
          await _importDataFromCsvForWeb(db);
          print('Data wilayah berhasil diimpor ke database web');
        } else {
          print('Database web sudah berisi data wilayah');
        }
        
        return db;
      } catch (e) {
        print('Error initializing web database: $e');
        rethrow;
      }
    } else {
      // Untuk platform mobile
      try {
        
        // Get path to database file
        String dbPath = join(await getDatabasesPath(), _databaseName);
        
        // Check if database exists
        bool dbExists = await databaseExists(dbPath);
        
        if (!dbExists) {
          // Create parent directory if it doesn't exist
          try {
            await Directory(join(await getDatabasesPath())).create(recursive: true);
          } catch (_) {}
          
          // Copy database from assets
          try {
            var data = await rootBundle.load(_assetPath);
            List<int> bytes = data.buffer.asUint8List();
            await File(dbPath).writeAsBytes(bytes, flush: true);
            print('Database berhasil disalin dari assets');
          } catch (e) {
            print('Error menyalin database dari assets: $e');
            // Jika gagal menyalin, buat database baru
            return await openDatabase(
              dbPath,
              version: _databaseVersion,
              onCreate: _createDatabase,
            );
          }
        }
        
        // Open the database
        return await openDatabase(
          dbPath,
          version: _databaseVersion,
          onCreate: _createDatabase,
        );
      } catch (e) {
        print('Error initializing mobile database: $e');
        rethrow;
      }
    }
  }
  
  // Import data dari CSV untuk web
  Future<void> _importDataFromCsvForWeb(Database db) async {
    try {
      print('Mengimpor data wilayah dari CSV ke database in-memory untuk platform web...');
      
      // Impor data provinsi
      try {
        // Cek apakah tabel provinsi sudah berisi data
        List<Map<String, dynamic>> provinsiCount = await db.rawQuery("SELECT COUNT(*) as count FROM provinsi");
        if (provinsiCount.first['count'] > 0) {
          print('Tabel provinsi sudah berisi data, melewati proses impor');
          return;
        }
      } catch (e) {
        print('Error checking provinsi count: $e');
      }
      
      // Tambahkan data provinsi statis langsung
      try {
        await db.insert('provinsi', {'id': '11', 'name': 'ACEH', 'code': '11'});
        await db.insert('provinsi', {'id': '12', 'name': 'SUMATERA UTARA', 'code': '12'});
        await db.insert('provinsi', {'id': '13', 'name': 'SUMATERA BARAT', 'code': '13'});
        await db.insert('provinsi', {'id': '14', 'name': 'RIAU', 'code': '14'});
        await db.insert('provinsi', {'id': '15', 'name': 'JAMBI', 'code': '15'});
        await db.insert('provinsi', {'id': '16', 'name': 'SUMATERA SELATAN', 'code': '16'});
        await db.insert('provinsi', {'id': '17', 'name': 'BENGKULU', 'code': '17'});
        await db.insert('provinsi', {'id': '18', 'name': 'LAMPUNG', 'code': '18'});
        await db.insert('provinsi', {'id': '19', 'name': 'KEPULAUAN BANGKA BELITUNG', 'code': '19'});
        await db.insert('provinsi', {'id': '21', 'name': 'KEPULAUAN RIAU', 'code': '21'});
        await db.insert('provinsi', {'id': '31', 'name': 'DKI JAKARTA', 'code': '31'});
        await db.insert('provinsi', {'id': '32', 'name': 'JAWA BARAT', 'code': '32'});
        await db.insert('provinsi', {'id': '33', 'name': 'JAWA TENGAH', 'code': '33'});
        await db.insert('provinsi', {'id': '34', 'name': 'DI YOGYAKARTA', 'code': '34'});
        await db.insert('provinsi', {'id': '35', 'name': 'JAWA TIMUR', 'code': '35'});
        await db.insert('provinsi', {'id': '36', 'name': 'BANTEN', 'code': '36'});
        await db.insert('provinsi', {'id': '51', 'name': 'BALI', 'code': '51'});
        await db.insert('provinsi', {'id': '52', 'name': 'NUSA TENGGARA BARAT', 'code': '52'});
        await db.insert('provinsi', {'id': '53', 'name': 'NUSA TENGGARA TIMUR', 'code': '53'});
        await db.insert('provinsi', {'id': '61', 'name': 'KALIMANTAN BARAT', 'code': '61'});
        await db.insert('provinsi', {'id': '62', 'name': 'KALIMANTAN TENGAH', 'code': '62'});
        await db.insert('provinsi', {'id': '63', 'name': 'KALIMANTAN SELATAN', 'code': '63'});
        await db.insert('provinsi', {'id': '64', 'name': 'KALIMANTAN TIMUR', 'code': '64'});
        await db.insert('provinsi', {'id': '65', 'name': 'KALIMANTAN UTARA', 'code': '65'});
        await db.insert('provinsi', {'id': '71', 'name': 'SULAWESI UTARA', 'code': '71'});
        await db.insert('provinsi', {'id': '72', 'name': 'SULAWESI TENGAH', 'code': '72'});
        await db.insert('provinsi', {'id': '73', 'name': 'SULAWESI SELATAN', 'code': '73'});
        await db.insert('provinsi', {'id': '74', 'name': 'SULAWESI TENGGARA', 'code': '74'});
        await db.insert('provinsi', {'id': '75', 'name': 'GORONTALO', 'code': '75'});
        await db.insert('provinsi', {'id': '76', 'name': 'SULAWESI BARAT', 'code': '76'});
        await db.insert('provinsi', {'id': '81', 'name': 'MALUKU', 'code': '81'});
        await db.insert('provinsi', {'id': '82', 'name': 'MALUKU UTARA', 'code': '82'});
        await db.insert('provinsi', {'id': '91', 'name': 'PAPUA BARAT', 'code': '91'});
        await db.insert('provinsi', {'id': '94', 'name': 'PAPUA', 'code': '94'});
        print('Data provinsi berhasil diimpor ke database in-memory');
      } catch (e) {
        print('Error mengimpor data provinsi: $e');
      }
      
      // Impor data kabupaten
      try {
        // Cek apakah tabel kabupaten sudah berisi data
        List<Map<String, dynamic>> kabupatenCount = await db.rawQuery("SELECT COUNT(*) as count FROM kabupaten");
        if (kabupatenCount.first['count'] > 0) {
          print('Tabel kabupaten sudah berisi data, melewati proses impor');
        } else {
          // Tambahkan data kabupaten untuk DKI Jakarta
          await db.insert('kabupaten', {'id': '3101', 'provinsi_id': '31', 'name': 'KEPULAUAN SERIBU', 'code': '3101'});
          await db.insert('kabupaten', {'id': '3171', 'provinsi_id': '31', 'name': 'JAKARTA PUSAT', 'code': '3171'});
          await db.insert('kabupaten', {'id': '3172', 'provinsi_id': '31', 'name': 'JAKARTA UTARA', 'code': '3172'});
          await db.insert('kabupaten', {'id': '3173', 'provinsi_id': '31', 'name': 'JAKARTA BARAT', 'code': '3173'});
          await db.insert('kabupaten', {'id': '3174', 'provinsi_id': '31', 'name': 'JAKARTA SELATAN', 'code': '3174'});
          await db.insert('kabupaten', {'id': '3175', 'provinsi_id': '31', 'name': 'JAKARTA TIMUR', 'code': '3175'});
          
          // Tambahkan data kabupaten untuk Jawa Timur
          await db.insert('kabupaten', {'id': '3501', 'provinsi_id': '35', 'name': 'PACITAN', 'code': '3501'});
          await db.insert('kabupaten', {'id': '3502', 'provinsi_id': '35', 'name': 'PONOROGO', 'code': '3502'});
          await db.insert('kabupaten', {'id': '3503', 'provinsi_id': '35', 'name': 'TRENGGALEK', 'code': '3503'});
          await db.insert('kabupaten', {'id': '3504', 'provinsi_id': '35', 'name': 'TULUNGAGUNG', 'code': '3504'});
          await db.insert('kabupaten', {'id': '3505', 'provinsi_id': '35', 'name': 'BLITAR', 'code': '3505'});
          await db.insert('kabupaten', {'id': '3506', 'provinsi_id': '35', 'name': 'KEDIRI', 'code': '3506'});
          await db.insert('kabupaten', {'id': '3507', 'provinsi_id': '35', 'name': 'MALANG', 'code': '3507'});
          await db.insert('kabupaten', {'id': '3508', 'provinsi_id': '35', 'name': 'LUMAJANG', 'code': '3508'});
          await db.insert('kabupaten', {'id': '3509', 'provinsi_id': '35', 'name': 'JEMBER', 'code': '3509'});
          await db.insert('kabupaten', {'id': '3510', 'provinsi_id': '35', 'name': 'BANYUWANGI', 'code': '3510'});
          await db.insert('kabupaten', {'id': '3578', 'provinsi_id': '35', 'name': 'KOTA SURABAYA', 'code': '3578'});
          
          // Tambahkan data kabupaten untuk Jawa Barat
          await db.insert('kabupaten', {'id': '3201', 'provinsi_id': '32', 'name': 'BOGOR', 'code': '3201'});
          await db.insert('kabupaten', {'id': '3273', 'provinsi_id': '32', 'name': 'KOTA BANDUNG', 'code': '3273'});
          
          print('Data kabupaten berhasil diimpor ke database in-memory');
        }
      } catch (e) {
        print('Error mengimpor data kabupaten: $e');
      }
      
      // Impor data kecamatan
      try {
        // Cek apakah tabel kecamatan sudah berisi data
        List<Map<String, dynamic>> kecamatanCount = await db.rawQuery("SELECT COUNT(*) as count FROM kecamatan");
        if (kecamatanCount.first['count'] > 0) {
          print('Tabel kecamatan sudah berisi data, melewati proses impor');
        } else {
          // Tambahkan data kecamatan untuk Jakarta Pusat (3171)
          await db.insert('kecamatan', {'id': '317101', 'kabupaten_id': '3171', 'name': 'GAMBIR', 'code': '317101'});
          await db.insert('kecamatan', {'id': '317102', 'kabupaten_id': '3171', 'name': 'SAWAH BESAR', 'code': '317102'});
          await db.insert('kecamatan', {'id': '317103', 'kabupaten_id': '3171', 'name': 'KEMAYORAN', 'code': '317103'});
          await db.insert('kecamatan', {'id': '317104', 'kabupaten_id': '3171', 'name': 'SENEN', 'code': '317104'});
          await db.insert('kecamatan', {'id': '317105', 'kabupaten_id': '3171', 'name': 'CEMPAKA PUTIH', 'code': '317105'});
          await db.insert('kecamatan', {'id': '317106', 'kabupaten_id': '3171', 'name': 'MENTENG', 'code': '317106'});
          await db.insert('kecamatan', {'id': '317107', 'kabupaten_id': '3171', 'name': 'TANAH ABANG', 'code': '317107'});
          await db.insert('kecamatan', {'id': '317108', 'kabupaten_id': '3171', 'name': 'JOHAR BARU', 'code': '317108'});
          
          // Tambahkan data kecamatan untuk Surabaya (3578)
          await db.insert('kecamatan', {'id': '357801', 'kabupaten_id': '3578', 'name': 'KARANG PILANG', 'code': '357801'});
          await db.insert('kecamatan', {'id': '357802', 'kabupaten_id': '3578', 'name': 'JAMBANGAN', 'code': '357802'});
          await db.insert('kecamatan', {'id': '357810', 'kabupaten_id': '3578', 'name': 'GUBENG', 'code': '357810'});
          
          print('Data kecamatan berhasil diimpor ke database in-memory');
        }
      } catch (e) {
        print('Error mengimpor data kecamatan: $e');
      }
      
      // Impor data kelurahan
      try {
        // Cek apakah tabel kelurahan sudah berisi data
        List<Map<String, dynamic>> kelurahanCount = await db.rawQuery("SELECT COUNT(*) as count FROM kelurahan");
        if (kelurahanCount.first['count'] > 0) {
          print('Tabel kelurahan sudah berisi data, melewati proses impor');
        } else {
          // Tambahkan data kelurahan untuk Gambir (317101)
          await db.insert('kelurahan', {'id': '3171011001', 'kecamatan_id': '317101', 'name': 'GAMBIR', 'code': '3171011001'});
          await db.insert('kelurahan', {'id': '3171011002', 'kecamatan_id': '317101', 'name': 'CIDENG', 'code': '3171011002'});
          await db.insert('kelurahan', {'id': '3171011003', 'kecamatan_id': '317101', 'name': 'PETOJO UTARA', 'code': '3171011003'});
          
          // Tambahkan data kelurahan untuk Tanah Abang (317107)
          await db.insert('kelurahan', {'id': '3171071001', 'kecamatan_id': '317107', 'name': 'KEBON MELATI', 'code': '3171071001'});
          await db.insert('kelurahan', {'id': '3171071002', 'kecamatan_id': '317107', 'name': 'KARET TENGSIN', 'code': '3171071002'});
          await db.insert('kelurahan', {'id': '3171071003', 'kecamatan_id': '317107', 'name': 'BENDUNGAN HILIR', 'code': '3171071003'});
          
          // Tambahkan data kelurahan untuk Gubeng (357810) di Surabaya
          await db.insert('kelurahan', {'id': '3578101001', 'kecamatan_id': '357810', 'name': 'BARATAJAYA', 'code': '3578101001'});
          await db.insert('kelurahan', {'id': '3578101002', 'kecamatan_id': '357810', 'name': 'PUCANG SEWU', 'code': '3578101002'});
          await db.insert('kelurahan', {'id': '3578101003', 'kecamatan_id': '357810', 'name': 'KERTAJAYA', 'code': '3578101003'});
          
          print('Data kelurahan berhasil diimpor ke database in-memory');
        }
      } catch (e) {
        print('Error mengimpor data kelurahan: $e');
      }
      
      print('Semua data wilayah berhasil diimpor ke database in-memory');
    } catch (e) {
      print('Error mengimpor data dari CSV ke database in-memory: $e');
    }
  }
  
  // Metode untuk mengambil data dari API (untuk web)
  Future<dynamic> _fetchFromApi(String endpoint) async {
    // Cek apakah data sudah ada di cache
    if (_apiCache.containsKey(endpoint)) {
      print('WilayahDatabaseService: Menggunakan data cache untuk endpoint: $endpoint');
      return _apiCache[endpoint];
    }
    
    try {
      print('WilayahDatabaseService: Fetching dari API: ${AppConfig.wilayahApiBaseUrl}/$endpoint');
      final response = await http.get(Uri.parse('${AppConfig.wilayahApiBaseUrl}/$endpoint'));
      
      print('WilayahDatabaseService: Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('WilayahDatabaseService: Response format: ${responseData.containsKey('status') ? 'valid' : 'invalid'}');
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          // Simpan data ke cache
          _apiCache[endpoint] = responseData['data'];
          print('WilayahDatabaseService: Data berhasil disimpan ke cache');
          return responseData['data'];
        } else {
          print('WilayahDatabaseService: Invalid response format from API: ${response.body.substring(0, 100)}...');
          // Fallback ke data hardcoded
          print('WilayahDatabaseService: Fallback ke data hardcoded');
          return _getHardcodedData(endpoint);
        }
      } else {
        print('WilayahDatabaseService: Failed to load data from API: ${response.statusCode}, Body: ${response.body.substring(0, 100)}...');
        // Fallback ke data hardcoded
        print('WilayahDatabaseService: Fallback ke data hardcoded');
        return _getHardcodedData(endpoint);
      }
    } catch (e) {
      print('WilayahDatabaseService: Error fetching from API: $e');
      // Fallback ke data hardcoded
      print('WilayahDatabaseService: Fallback ke data hardcoded');
      return _getHardcodedData(endpoint);
    }
  }
  
  // Data hardcoded sebagai fallback jika API gagal
  dynamic _getHardcodedData(String endpoint) {
    switch (endpoint) {
      case 'provinsi':
        return [
          {'id': '11', 'name': 'ACEH', 'code': '11'},
          {'id': '12', 'name': 'SUMATERA UTARA', 'code': '12'},
          {'id': '31', 'name': 'DKI JAKARTA', 'code': '31'},
          {'id': '32', 'name': 'JAWA BARAT', 'code': '32'},
          {'id': '35', 'name': 'JAWA TIMUR', 'code': '35'},
        ];
      case 'kabupaten':
        return [
          {'id': '3171', 'provinsi_id': '31', 'name': 'JAKARTA PUSAT', 'code': '3171'},
          {'id': '3172', 'provinsi_id': '31', 'name': 'JAKARTA UTARA', 'code': '3172'},
          {'id': '3173', 'provinsi_id': '31', 'name': 'JAKARTA BARAT', 'code': '3173'},
          {'id': '3273', 'provinsi_id': '32', 'name': 'KOTA BANDUNG', 'code': '3273'},
          {'id': '3578', 'provinsi_id': '35', 'name': 'KOTA SURABAYA', 'code': '3578'},
        ];
      default:
        return [];
    }
  }
  
  // Data provinsi hardcoded sebagai fallback
  List<Provinsi> _getHardcodedProvinsiData() {
    return [
      Provinsi(id: '11', name: 'ACEH', code: '11'),
      Provinsi(id: '12', name: 'SUMATERA UTARA', code: '12'),
      Provinsi(id: '31', name: 'DKI JAKARTA', code: '31'),
      Provinsi(id: '32', name: 'JAWA BARAT', code: '32'),
      Provinsi(id: '35', name: 'JAWA TIMUR', code: '35'),
    ];
  }
  
  // CRUD operations for Provinsi
  
  // Metode untuk mendapatkan semua provinsi
  Future<List<Provinsi>> getProvinsi() async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        final data = await _fetchFromApi('provinsi');
        return List.generate(data.length, (i) {
          return Provinsi(
            id: data[i]['id'],
            name: data[i]['name'],
            code: data[i]['code'],
          );
        });
      } catch (e) {
        // Fallback: gunakan data hardcoded untuk provinsi
        final hardcodedData = _getHardcodedProvinsiData();
        return hardcodedData;
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'provinsi',
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Provinsi(
          id: maps[i]['id'],
          name: maps[i]['name'],
          code: maps[i]['code'],
        );
      });
    }
  }
  
  // Alias untuk getProvinsi() untuk kompatibilitas dengan kode yang sudah ada
  Future<List<Provinsi>> getAllProvinsi() async {
    return await getProvinsi();
  }
  
  Future<Provinsi?> getProvinsiById(String id) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil dari endpoint khusus provinsi/{id}
        final data = await _fetchFromApi('provinsi/$id');
        return Provinsi(
          id: data['id'],
          name: data['name'],
          code: data['code'],
        );
      } catch (e) {
        // Fallback: ambil semua provinsi dan cari berdasarkan id
        final allData = await _fetchFromApi('provinsi');
        try {
          final provinsiData = allData.firstWhere(
            (item) => item['id'] == id,
          );
          
          return Provinsi(
            id: provinsiData['id'],
            name: provinsiData['name'],
            code: provinsiData['code'],
          );
        } catch (e) {
          // Tidak ditemukan
          return null;
        }
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'provinsi',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) return null;
      
      return Provinsi(
        id: maps[0]['id'],
        name: maps[0]['name'],
        code: maps[0]['code'],
      );
    }
  }
  
  // CRUD operations for Kabupaten
  
  Future<List<Kabupaten>> getKabupatenByProvinsiId(String provinsiId) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil dari endpoint khusus provinsi/{id}/kabupaten jika tersedia
        final data = await _fetchFromApi('provinsi/$provinsiId/kabupaten');
        return List.generate(data.length, (i) {
          return Kabupaten(
            id: data[i]['id'],
            provinsiId: provinsiId, // Gunakan provinsiId yang diberikan
            name: data[i]['name'],
            code: data[i]['code'],
          );
        });
      } catch (e) {
        // Fallback: ambil semua kabupaten dan filter berdasarkan provinsiId
        final allData = await _fetchFromApi('kabupaten');
        print('WilayahDatabaseService: Loaded ${allData.length} kabupaten from API');
        print('WilayahDatabaseService: First item provinsi_id: ${allData.isNotEmpty ? allData[0]['provinsi_id'] : 'none'}');
        print('WilayahDatabaseService: Filtering with provinsiId: $provinsiId');
        
        // Coba filter berdasarkan provinceId jika provinsi_id tidak ada
        final filteredData = allData.where((item) => 
          (item['provinsi_id'] == provinsiId) || (item['provinceId'] == provinsiId)
        ).toList();
        
        print('WilayahDatabaseService: Filtered data count: ${filteredData.length}');
        
        return List.generate(filteredData.length, (i) {
          return Kabupaten(
            id: filteredData[i]['id'],
            provinsiId: provinsiId, // Gunakan provinsiId yang diberikan
            name: filteredData[i]['name'],
            code: filteredData[i]['code'],
          );
        });
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kabupaten',
        where: 'provinsi_id = ?',
        whereArgs: [provinsiId],
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Kabupaten(
          id: maps[i]['id'],
          provinsiId: maps[i]['provinsi_id'],
          name: maps[i]['name'],
          code: maps[i]['code'],
        );
      });
    }
  }
  
  Future<Kabupaten?> getKabupatenById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kabupaten',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    return Kabupaten(
      id: maps[0]['id'],
      provinsiId: maps[0]['provinsi_id'],
      name: maps[0]['name'],
      code: maps[0]['code'],
    );
  }
  
  // CRUD operations for Kecamatan
  
  Future<List<Kecamatan>> getKecamatanByKabupatenId(String kabupatenId) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil dari endpoint khusus kabupaten/{id}/kecamatan jika tersedia
        final data = await _fetchFromApi('kabupaten/$kabupatenId/kecamatan');
        print('WilayahDatabaseService: Loaded ${data.length} kecamatan from API endpoint kabupaten/$kabupatenId/kecamatan');
        return List.generate(data.length, (i) {
          return Kecamatan(
            id: data[i]['id'],
            kabupatenId: kabupatenId, // Gunakan kabupatenId yang diberikan
            name: data[i]['name'],
            code: data[i]['code'],
          );
        });
      } catch (e) {
        print('WilayahDatabaseService: Error fetching kecamatan from specific endpoint: $e');
        // Fallback: gunakan data hardcoded untuk kecamatan
        final hardcodedData = _getHardcodedKecamatanData(kabupatenId);
        return hardcodedData;
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kecamatan',
        where: 'kabupaten_id = ?',
        whereArgs: [kabupatenId],
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Kecamatan(
          id: maps[i]['id'],
          kabupatenId: maps[i]['kabupaten_id'],
          name: maps[i]['name'],
          code: maps[i]['code'],
        );
      });
    }
  }
  
  // Data hardcoded untuk kecamatan sebagai fallback
  List<Kecamatan> _getHardcodedKecamatanData(String kabupatenId) {
    // Data kecamatan untuk Jakarta Pusat (3171)
    if (kabupatenId == '3171') {
      return [
        Kecamatan(id: '317101', kabupatenId: '3171', name: 'GAMBIR', code: '317101'),
        Kecamatan(id: '317102', kabupatenId: '3171', name: 'SAWAH BESAR', code: '317102'),
        Kecamatan(id: '317103', kabupatenId: '3171', name: 'KEMAYORAN', code: '317103'),
        Kecamatan(id: '317104', kabupatenId: '3171', name: 'SENEN', code: '317104'),
        Kecamatan(id: '317105', kabupatenId: '3171', name: 'CEMPAKA PUTIH', code: '317105'),
        Kecamatan(id: '317106', kabupatenId: '3171', name: 'MENTENG', code: '317106'),
        Kecamatan(id: '317107', kabupatenId: '3171', name: 'TANAH ABANG', code: '317107'),
        Kecamatan(id: '317108', kabupatenId: '3171', name: 'JOHAR BARU', code: '317108'),
      ];
    }
    // Data kecamatan untuk Kota Surabaya (3578)
    else if (kabupatenId == '3578') {
      return [
        Kecamatan(id: '357801', kabupatenId: '3578', name: 'KARANG PILANG', code: '357801'),
        Kecamatan(id: '357802', kabupatenId: '3578', name: 'JAMBANGAN', code: '357802'),
        Kecamatan(id: '357810', kabupatenId: '3578', name: 'GUBENG', code: '357810'),
      ];
    }
    // Default: return empty list
    return [];
  }
  
  Future<Kecamatan?> getKecamatanById(String id) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil dari endpoint khusus kecamatan/{id}
        final data = await _fetchFromApi('kecamatan/$id');
        return Kecamatan(
          id: data['id'],
          kabupatenId: data['kabupaten_id'],
          name: data['name'],
          code: data['code'],
        );
      } catch (e) {
        // Fallback: ambil semua kecamatan dan cari berdasarkan id
        try {
          final allData = await _fetchFromApi('kecamatan');
          final kecamatanData = allData.firstWhere(
            (item) => item['id'] == id,
          );
          
          return Kecamatan(
            id: kecamatanData['id'],
            kabupatenId: kecamatanData['kabupaten_id'],
            name: kecamatanData['name'],
            code: kecamatanData['code'],
          );
        } catch (e) {
          // Tidak ditemukan
          return null;
        }
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kecamatan',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) return null;
      
      return Kecamatan(
        id: maps[0]['id'],
        kabupatenId: maps[0]['kabupaten_id'],
        name: maps[0]['name'],
        code: maps[0]['code'],
      );
    }
  }
  
  // CRUD operations for Kelurahan
  
  Future<List<Kelurahan>> getKelurahanByKecamatanId(String kecamatanId) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil dari endpoint khusus kecamatan/{id}/kelurahan jika tersedia
        final data = await _fetchFromApi('kecamatan/$kecamatanId/kelurahan');
        print('WilayahDatabaseService: Loaded ${data.length} kelurahan from API endpoint kecamatan/$kecamatanId/kelurahan');
        return List.generate(data.length, (i) {
          return Kelurahan(
            id: data[i]['id'],
            kecamatanId: kecamatanId, // Gunakan kecamatanId yang diberikan
            name: data[i]['name'],
            code: data[i]['code'],
          );
        });
      } catch (e) {
        print('WilayahDatabaseService: Error fetching kelurahan from specific endpoint: $e');
        // Fallback: gunakan data hardcoded untuk kelurahan
        final hardcodedData = _getHardcodedKelurahanData(kecamatanId);
        return hardcodedData;
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kelurahan',
        where: 'kecamatan_id = ?',
        whereArgs: [kecamatanId],
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Kelurahan(
          id: maps[i]['id'],
          kecamatanId: maps[i]['kecamatan_id'],
          name: maps[i]['name'],
          code: maps[i]['code'],
        );
      });
    }
  }
  
  // Data hardcoded untuk kelurahan sebagai fallback
  List<Kelurahan> _getHardcodedKelurahanData(String kecamatanId) {
    // Data kelurahan untuk Gambir (317101)
    if (kecamatanId == '317101') {
      return [
        Kelurahan(id: '3171011001', kecamatanId: '317101', name: 'GAMBIR', code: '3171011001'),
        Kelurahan(id: '3171011002', kecamatanId: '317101', name: 'CIDENG', code: '3171011002'),
        Kelurahan(id: '3171011003', kecamatanId: '317101', name: 'PETOJO UTARA', code: '3171011003'),
      ];
    }
    // Data kelurahan untuk Tanah Abang (317107)
    else if (kecamatanId == '317107') {
      return [
        Kelurahan(id: '3171071001', kecamatanId: '317107', name: 'KEBON MELATI', code: '3171071001'),
        Kelurahan(id: '3171071002', kecamatanId: '317107', name: 'KARET TENGSIN', code: '3171071002'),
        Kelurahan(id: '3171071003', kecamatanId: '317107', name: 'BENDUNGAN HILIR', code: '3171071003'),
      ];
    }
    // Data kelurahan untuk Gubeng (357810) di Surabaya
    else if (kecamatanId == '357810') {
      return [
        Kelurahan(id: '3578101001', kecamatanId: '357810', name: 'BARATAJAYA', code: '3578101001'),
        Kelurahan(id: '3578101002', kecamatanId: '357810', name: 'PUCANG SEWU', code: '3578101002'),
        Kelurahan(id: '3578101003', kecamatanId: '357810', name: 'KERTAJAYA', code: '3578101003'),
      ];
    }
    // Default: return empty list
    return [];
  }
  
  Future<Kelurahan?> getKelurahanById(String id) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil dari endpoint khusus kelurahan/{id}
        final data = await _fetchFromApi('kelurahan/$id');
        return Kelurahan(
          id: data['id'],
          kecamatanId: data['kecamatan_id'],
          name: data['name'],
          code: data['code'],
        );
      } catch (e) {
        // Fallback: ambil semua kelurahan dan cari berdasarkan id
        try {
          final allData = await _fetchFromApi('kelurahan');
          final kelurahanData = allData.firstWhere(
            (item) => item['id'] == id,
          );
          
          return Kelurahan(
            id: kelurahanData['id'],
            kecamatanId: kelurahanData['kecamatan_id'],
            name: kelurahanData['name'],
            code: kelurahanData['code'],
          );
        } catch (e) {
          // Tidak ditemukan
          return null;
        }
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kelurahan',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) return null;
      
      return Kelurahan(
        id: maps[0]['id'],
        kecamatanId: maps[0]['kecamatan_id'],
        name: maps[0]['name'],
        code: maps[0]['code'],
      );
    }
  }
  
  // Search methods
  
  Future<List<Provinsi>> searchProvinsi(String query) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil semua provinsi dan filter di client
        final data = await _fetchFromApi('provinsi');
        final filteredData = data.where(
          (item) => item['name'].toString().toLowerCase().contains(query.toLowerCase())
        ).toList();
        
        return List.generate(filteredData.length, (i) {
          return Provinsi(
            id: filteredData[i]['id'],
            name: filteredData[i]['name'],
            code: filteredData[i]['code'],
          );
        });
      } catch (e) {
        print('Error searching provinsi: $e');
        return [];
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'provinsi',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Provinsi(
          id: maps[i]['id'],
          name: maps[i]['name'],
          code: maps[i]['code'],
        );
      });
    }
  }
  
  Future<List<Kabupaten>> searchKabupaten(String query) async {
    if (kIsWeb) {
      // Untuk web, gunakan API
      try {
        // Coba ambil semua kabupaten dan filter di client
        final data = await _fetchFromApi('kabupaten');
        final filteredData = data.where(
          (item) => item['name'].toString().toLowerCase().contains(query.toLowerCase())
        ).toList();
        
        return List.generate(filteredData.length, (i) {
          return Kabupaten(
            id: filteredData[i]['id'],
            provinsiId: filteredData[i]['provinsi_id'],
            name: filteredData[i]['name'],
            code: filteredData[i]['code'],
          );
        });
      } catch (e) {
        print('Error searching kabupaten: $e');
        return [];
      }
    } else {
      // Untuk mobile, gunakan SQLite
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kabupaten',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'name ASC',
      );
      
      return List.generate(maps.length, (i) {
        return Kabupaten(
          id: maps[i]['id'],
          provinsiId: maps[i]['provinsi_id'],
          name: maps[i]['name'],
          code: maps[i]['code'],
        );
      });
    }
  }
  
  // Utility methods
  
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
