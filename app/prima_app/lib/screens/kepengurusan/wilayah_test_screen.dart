import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wilayah_model.dart';
import '../../providers/wilayah_database_provider.dart';

class WilayahTestScreen extends StatefulWidget {
  const WilayahTestScreen({Key? key}) : super(key: key);

  @override
  State<WilayahTestScreen> createState() => _WilayahTestScreenState();
}

class _WilayahTestScreenState extends State<WilayahTestScreen> {
  String? _selectedProvinsiId;
  String? _selectedKabupatenId;
  String? _selectedKecamatanId;
  
  List<Kabupaten> _kabupatenList = [];
  List<Kecamatan> _kecamatanList = [];
  List<Kelurahan> _kelurahanList = [];
  
  bool _isLoadingKabupaten = false;
  bool _isLoadingKecamatan = false;
  bool _isLoadingKelurahan = false;
  
  @override
  Widget build(BuildContext context) {
    final wilayahProvider = Provider.of<WilayahDatabaseProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tes Data Wilayah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengujian Database SQLite Wilayah Indonesia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Provinsi Dropdown
            const Text('Provinsi:'),
            const SizedBox(height: 8),
            wilayahProvider.isLoading
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    value: _selectedProvinsiId,
                    hint: const Text('Pilih Provinsi'),
                    isExpanded: true,
                    items: wilayahProvider.provinsiList.map((provinsi) {
                      return DropdownMenuItem<String>(
                        value: provinsi.id,
                        child: Text(provinsi.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProvinsiId = value;
                        _selectedKabupatenId = null;
                        _selectedKecamatanId = null;
                        _kabupatenList = [];
                        _kecamatanList = [];
                        _kelurahanList = [];
                      });
                      
                      if (value != null) {
                        _loadKabupaten(value);
                      }
                    },
                  ),
            const SizedBox(height: 16),
            
            // Kabupaten Dropdown
            if (_selectedProvinsiId != null) ...[
              const Text('Kabupaten/Kota:'),
              const SizedBox(height: 8),
              _isLoadingKabupaten
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: _selectedKabupatenId,
                      hint: const Text('Pilih Kabupaten/Kota'),
                      isExpanded: true,
                      items: _kabupatenList.map((kabupaten) {
                        return DropdownMenuItem<String>(
                          value: kabupaten.id,
                          child: Text(kabupaten.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKabupatenId = value;
                          _selectedKecamatanId = null;
                          _kecamatanList = [];
                          _kelurahanList = [];
                        });
                        
                        if (value != null) {
                          _loadKecamatan(value);
                        }
                      },
                    ),
              const SizedBox(height: 16),
            ],
            
            // Kecamatan Dropdown
            if (_selectedKabupatenId != null) ...[
              const Text('Kecamatan:'),
              const SizedBox(height: 8),
              _isLoadingKecamatan
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      value: _selectedKecamatanId,
                      hint: const Text('Pilih Kecamatan'),
                      isExpanded: true,
                      items: _kecamatanList.map((kecamatan) {
                        return DropdownMenuItem<String>(
                          value: kecamatan.id,
                          child: Text(kecamatan.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKecamatanId = value;
                          _kelurahanList = [];
                        });
                        
                        if (value != null) {
                          _loadKelurahan(value);
                        }
                      },
                    ),
              const SizedBox(height: 16),
            ],
            
            // Kelurahan List
            if (_selectedKecamatanId != null) ...[
              const Text('Kelurahan/Desa:'),
              const SizedBox(height: 8),
              _isLoadingKelurahan
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _kelurahanList.length,
                        itemBuilder: (context, index) {
                          final kelurahan = _kelurahanList[index];
                          return Card(
                            child: ListTile(
                              title: Text(kelurahan.name),
                              subtitle: Text('Kode: ${kelurahan.code}'),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _loadKabupaten(String provinsiId) async {
    setState(() {
      _isLoadingKabupaten = true;
    });
    
    try {
      final wilayahProvider = Provider.of<WilayahDatabaseProvider>(context, listen: false);
      final kabupatenList = await wilayahProvider.loadKabupatenData(provinsiId);
      
      setState(() {
        _kabupatenList = kabupatenList;
        _isLoadingKabupaten = false;
      });
    } catch (e) {
      print('Error loading kabupaten: $e');
      setState(() {
        _isLoadingKabupaten = false;
      });
    }
  }
  
  Future<void> _loadKecamatan(String kabupatenId) async {
    setState(() {
      _isLoadingKecamatan = true;
    });
    
    try {
      final wilayahProvider = Provider.of<WilayahDatabaseProvider>(context, listen: false);
      final kecamatanList = await wilayahProvider.getKecamatanByKabupatenId(kabupatenId);
      
      setState(() {
        _kecamatanList = kecamatanList;
        _isLoadingKecamatan = false;
      });
    } catch (e) {
      print('Error loading kecamatan: $e');
      setState(() {
        _isLoadingKecamatan = false;
      });
    }
  }
  
  Future<void> _loadKelurahan(String kecamatanId) async {
    setState(() {
      _isLoadingKelurahan = true;
    });
    
    try {
      final wilayahProvider = Provider.of<WilayahDatabaseProvider>(context, listen: false);
      final kelurahanList = await wilayahProvider.getKelurahanByKecamatanId(kecamatanId);
      
      setState(() {
        _kelurahanList = kelurahanList;
        _isLoadingKelurahan = false;
      });
    } catch (e) {
      print('Error loading kelurahan: $e');
      setState(() {
        _isLoadingKelurahan = false;
      });
    }
  }
}
