import 'dart:io';
import 'package:csv/csv.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;

/// Script untuk mengkonversi data CSV wilayah Indonesia ke SQLite database.
/// 
/// Cara penggunaan:
/// 1. Pastikan data CSV berada di folder Indonesia/
/// 2. Jalankan script ini dengan perintah:
///    dart run tools/csv_to_sqlite_converter.dart
/// 3. Database SQLite akan dibuat di assets/databases/wilayah_indonesia.db

void main() async {
  // Inisialisasi sqflite untuk desktop
  sqfliteFfiInit();
  
  // Path ke direktori CSV dan database output
  final csvDir = 'assets/data';
  final dbOutputDir = 'assets/databases';
  final dbOutputPath = '$dbOutputDir/wilayah_indonesia.db';
  
  print('Direktori CSV: $csvDir');
  print('Memeriksa keberadaan direktori CSV...');
  final csvDirectory = Directory(csvDir);
  if (await csvDirectory.exists()) {
    print('Direktori CSV ditemukan');
    final files = await csvDirectory.list().toList();
    print('File yang ditemukan: ${files.map((f) => path.basename(f.path)).join(', ')}');
  } else {
    print('Direktori CSV tidak ditemukan');
  }
  
  // Buat direktori output jika belum ada
  final dbDir = Directory(dbOutputDir);
  if (!await dbDir.exists()) {
    await dbDir.create(recursive: true);
  }
  
  // Hapus database lama jika ada
  final dbFile = File(dbOutputPath);
  if (await dbFile.exists()) {
    await dbFile.delete();
    print('Database lama dihapus');
  }
  
  // Buka database
  final databaseFactory = databaseFactoryFfi;
  final db = await databaseFactory.openDatabase(
    dbOutputPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: createDatabase,
    ),
  );
  
  // Impor data dari CSV
  try {
    print('Mulai mengimpor data dari CSV ke SQLite...');
    await importDataFromCSV(db, csvDir);
    print('Import data selesai');
  } catch (e) {
    print('Error saat mengimpor data: $e');
  } finally {
    // Tutup database
    await db.close();
  }
}

/// Membuat struktur database
Future<void> createDatabase(Database db, int version) async {
  print('Membuat struktur database...');
  
  // Buat tabel provinsi
  await db.execute('''
    CREATE TABLE provinsi (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      code TEXT NOT NULL
    )
  ''');
  
  // Buat tabel kabupaten
  await db.execute('''
    CREATE TABLE kabupaten (
      id TEXT PRIMARY KEY,
      provinsi_id TEXT NOT NULL,
      name TEXT NOT NULL,
      code TEXT NOT NULL,
      FOREIGN KEY (provinsi_id) REFERENCES provinsi (id)
    )
  ''');
  
  // Buat tabel kecamatan
  await db.execute('''
    CREATE TABLE kecamatan (
      id TEXT PRIMARY KEY,
      kabupaten_id TEXT NOT NULL,
      name TEXT NOT NULL,
      code TEXT NOT NULL,
      FOREIGN KEY (kabupaten_id) REFERENCES kabupaten (id)
    )
  ''');
  
  // Buat tabel kelurahan
  await db.execute('''
    CREATE TABLE kelurahan (
      id TEXT PRIMARY KEY,
      kecamatan_id TEXT NOT NULL,
      name TEXT NOT NULL,
      code TEXT NOT NULL,
      FOREIGN KEY (kecamatan_id) REFERENCES kecamatan (id)
    )
  ''');
  
  // Buat indeks untuk query yang lebih cepat
  await db.execute('CREATE INDEX idx_kabupaten_provinsi ON kabupaten (provinsi_id)');
  await db.execute('CREATE INDEX idx_kecamatan_kabupaten ON kecamatan (kabupaten_id)');
  await db.execute('CREATE INDEX idx_kelurahan_kecamatan ON kelurahan (kecamatan_id)');
  
  print('Struktur database berhasil dibuat');
}

/// Mengimpor data dari CSV ke database SQLite
Future<void> importDataFromCSV(Database db, String csvDir) async {
  // Impor data provinsi
  await importProvinsi(db, csvDir);
  
  // Impor data kabupaten
  await importKabupaten(db, csvDir);
  
  // Impor data kecamatan
  await importKecamatan(db, csvDir);
  
  // Impor data kelurahan
  await importKelurahan(db, csvDir);
}

/// Mengimpor data provinsi dari CSV
Future<void> importProvinsi(Database db, String csvDir) async {
  print('Mengimpor data provinsi...');
  
  final file = File(path.join(csvDir, 'provinsi.csv'));
  if (!await file.exists()) {
    print('File provinsi.csv tidak ditemukan');
    return;
  }
  
  final csvString = await file.readAsString();
  final csvTable = const CsvToListConverter().convert(csvString);
  
  // Mulai batch transaction untuk performa lebih baik
  final batch = db.batch();
  
  // Skip header row jika ada
  for (int i = 1; i < csvTable.length; i++) {
    final row = csvTable[i];
    if (row.length >= 3) {
      batch.insert('provinsi', {
        'id': row[0].toString(),
        'name': row[1].toString(),
        'code': row[2].toString(),
      });
    }
  }
  
  // Commit batch
  await batch.commit(noResult: true);
  print('Data provinsi berhasil diimpor');
}

/// Mengimpor data kabupaten dari CSV
Future<void> importKabupaten(Database db, String csvDir) async {
  print('Mengimpor data kabupaten...');
  
  final file = File(path.join(csvDir, 'kabupaten.csv'));
  if (!await file.exists()) {
    print('File kabupaten.csv tidak ditemukan');
    return;
  }
  
  final csvString = await file.readAsString();
  final csvTable = const CsvToListConverter().convert(csvString);
  
  // Mulai batch transaction
  final batch = db.batch();
  
  // Skip header row jika ada
  for (int i = 1; i < csvTable.length; i++) {
    final row = csvTable[i];
    if (row.length >= 4) {
      batch.insert('kabupaten', {
        'id': row[0].toString(),
        'provinsi_id': row[1].toString(),
        'name': row[2].toString(),
        'code': row[3].toString(),
      });
    }
  }
  
  // Commit batch
  await batch.commit(noResult: true);
  print('Data kabupaten berhasil diimpor');
}

/// Mengimpor data kecamatan dari CSV
Future<void> importKecamatan(Database db, String csvDir) async {
  print('Mengimpor data kecamatan...');
  
  final file = File(path.join(csvDir, 'kecamatan.csv'));
  if (!await file.exists()) {
    print('File kecamatan.csv tidak ditemukan');
    return;
  }
  
  final csvString = await file.readAsString();
  final csvTable = const CsvToListConverter().convert(csvString);
  
  // Mulai batch transaction
  final batch = db.batch();
  
  // Skip header row jika ada
  for (int i = 1; i < csvTable.length; i++) {
    final row = csvTable[i];
    if (row.length >= 4) {
      batch.insert('kecamatan', {
        'id': row[0].toString(),
        'kabupaten_id': row[1].toString(),
        'name': row[2].toString(),
        'code': row[3].toString(),
      });
    }
  }
  
  // Commit batch
  await batch.commit(noResult: true);
  print('Data kecamatan berhasil diimpor');
}

/// Mengimpor data kelurahan dari CSV
Future<void> importKelurahan(Database db, String csvDir) async {
  print('Mengimpor data kelurahan...');
  
  final file = File(path.join(csvDir, 'kelurahan.csv'));
  if (!await file.exists()) {
    print('File kelurahan.csv tidak ditemukan');
    return;
  }
  
  final csvString = await file.readAsString();
  final csvTable = const CsvToListConverter().convert(csvString);
  
  // Mulai batch transaction
  final batch = db.batch();
  
  // Skip header row jika ada
  for (int i = 1; i < csvTable.length; i++) {
    final row = csvTable[i];
    if (row.length >= 4) {
      batch.insert('kelurahan', {
        'id': row[0].toString(),
        'kecamatan_id': row[1].toString(),
        'name': row[2].toString(),
        'code': row[3].toString(),
      });
    }
  }
  
  // Commit batch
  await batch.commit(noResult: true);
  print('Data kelurahan berhasil diimpor');
}
