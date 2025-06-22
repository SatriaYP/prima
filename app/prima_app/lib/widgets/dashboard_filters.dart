import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/region_models.dart';
import '../models/wilayah_model.dart';
import '../providers/region_provider.dart';
import 'responsive_layout.dart';

class DashboardFilters extends StatefulWidget {
  final Function(String? search, String? province, String? city, String? district, String? village) onApplyFilters;
  final Function() onResetFilters;

  const DashboardFilters({
    Key? key,
    required this.onApplyFilters,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  State<DashboardFilters> createState() => _DashboardFiltersState();
}

class _DashboardFiltersState extends State<DashboardFilters> {
  final TextEditingController _searchController = TextEditingController();
  
  // Legacy region data (for backward compatibility)
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedVillage;
  
  // New API wilayah data
  String? _selectedProvinsiId;
  String? _selectedKabupatenId;
  String? _selectedKecamatanId;
  String? _selectedKelurahanId;
  
  // Flag to use new API
  final bool _useNewApi = true; // Set to true to use the new API

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    if (_useNewApi) {
      widget.onApplyFilters(
        _searchController.text.isNotEmpty ? _searchController.text : null,
        _selectedProvinsiId,
        _selectedKabupatenId,
        _selectedKecamatanId,
        _selectedKelurahanId,
      );
    } else {
      // Legacy API
      widget.onApplyFilters(
        _searchController.text.isNotEmpty ? _searchController.text : null,
        _selectedProvince,
        _selectedCity,
        _selectedDistrict,
        _selectedVillage,
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      
      // Reset legacy data
      _selectedProvince = null;
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedVillage = null;
      
      // Reset new API data
      _selectedProvinsiId = null;
      _selectedKabupatenId = null;
      _selectedKecamatanId = null;
      _selectedKelurahanId = null;
    });
    widget.onResetFilters();
  }

  @override
  void initState() {
    super.initState();
    // Memuat data region saat widget diinisialisasi
    Future.microtask(() {
      final regionProvider = Provider.of<RegionProvider>(context, listen: false);
      regionProvider.loadRegionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan listen: true agar widget di-rebuild saat data berubah
    final regionProvider = Provider.of<RegionProvider>(context);
    
    // Debug print
    print('Build DashboardFilters');
    print('Selected provinsiId: $_selectedProvinsiId');
    print('Provinsi list size: ${regionProvider.provinsiList.length}');
    print('Kabupaten list size: ${regionProvider.kabupatenList.length}');
    print('Kabupaten items for selected provinsi: ${regionProvider.kabupatenList.where((k) => k.provinsiId == _selectedProvinsiId).length}');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter & Pencarian',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Dua kolom: Search field dan Region filters
            ResponsiveLayout(
              mobile: Column(
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Cari berdasarkan Nama, NIK, atau KTA',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRegionDropdowns(regionProvider),
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom 1: Search field dan region dropdowns
                  Expanded(
                    child: Column(
                      children: [
                        // Search field
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Cari berdasarkan Nama, NIK, atau KTA',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRegionDropdowns(regionProvider),
                      ],
                    ),
                  ),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom 1: Search field dan region dropdowns
                  Expanded(
                    child: Column(
                      children: [
                        // Search field
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Cari berdasarkan Nama, NIK, atau KTA',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRegionDropdowns(regionProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Terapkan Filter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionDropdowns(RegionProvider regionProvider) {
    if (_useNewApi) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provinsi dropdown (new API)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Provinsi',
              border: OutlineInputBorder(),
            ),
            value: _selectedProvinsiId,
            items: regionProvider.provinsiList.map((provinsi) {
              return DropdownMenuItem<String>(
                value: provinsi.id,
                child: Text(provinsi.name),
              );
            }).toList(),
            onChanged: (value) {
              print('Provinsi selected: $value');
              setState(() {
                _selectedProvinsiId = value;
                _selectedKabupatenId = null;
                _selectedKecamatanId = null;
                _selectedKelurahanId = null;
              });
              // Load kabupaten when provinsi is selected
              if (value != null) {
                print('Calling getKabupatenByProvinsiId with provinsiId: $value');
                regionProvider.getKabupatenByProvinsiId(value).then((kabupatenList) {
                  print('Kabupaten list loaded: ${kabupatenList.length} items');
                  print('First few kabupaten: ${kabupatenList.take(3).map((k) => "${k.id}:${k.name}").join(", ")}');
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Kabupaten dropdown (new API)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kabupaten/Kota',
              border: OutlineInputBorder(),
            ),
            value: _selectedKabupatenId,
            items: _selectedProvinsiId != null
              ? regionProvider.kabupatenList
                  .where((kabupaten) => kabupaten.provinsiId == _selectedProvinsiId)
                  .map((kabupaten) {
                    print('Mapping kabupaten: ${kabupaten.id}, ${kabupaten.name}, provinsiId: ${kabupaten.provinsiId}');
                    return DropdownMenuItem<String>(
                      value: kabupaten.id,
                      child: Text(kabupaten.name),
                    );
                  }).toList()
              : [],
            onChanged: (_selectedProvinsiId == null) 
              ? null
              : (value) {
                  print('Kabupaten selected: $value');
                    setState(() {
                      _selectedKabupatenId = value;
                      _selectedKecamatanId = null;
                      _selectedKelurahanId = null;
                    });
                    // Load kecamatan when kabupaten is selected
                    if (value != null) {
                      regionProvider.getKecamatanByKabupatenId(value);
                    }
                  },
          ),
          const SizedBox(height: 16),
          
          // Kecamatan dropdown (new API)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kecamatan',
              border: OutlineInputBorder(),
            ),
            value: _selectedKecamatanId,
            items: _selectedKabupatenId != null
                ? regionProvider.kecamatanList
                    .where((kecamatan) => kecamatan.kabupatenId == _selectedKabupatenId)
                    .map((kecamatan) {
                      return DropdownMenuItem<String>(
                        value: kecamatan.id,
                        child: Text(kecamatan.name),
                      );
                    }).toList()
                : [],
            onChanged: (_selectedKabupatenId == null)
                ? null
                : (value) {
                    print('Kecamatan selected: $value');
                    setState(() {
                      _selectedKecamatanId = value;
                      _selectedKelurahanId = null;
                    });
                    // Load kelurahan when kecamatan is selected
                    if (value != null) {
                      print('Calling getKelurahanByKecamatanId with kecamatanId: $value');
                      regionProvider.getKelurahanByKecamatanId(value).then((kelurahanList) {
                        print('Kelurahan list loaded: ${kelurahanList.length} items');
                        if (kelurahanList.isNotEmpty) {
                          print('First few kelurahan: ${kelurahanList.take(3).map((k) => "${k.id}:${k.name}").join(", ")}');
                        }
                      });
                    }
                  },
          ),
          const SizedBox(height: 16),
          
          // Kelurahan dropdown (new API)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kelurahan/Desa',
              border: OutlineInputBorder(),
            ),
            value: _selectedKelurahanId,
            items: _selectedKecamatanId != null
                ? regionProvider.kelurahanList
                    .where((kelurahan) => kelurahan.kecamatanId == _selectedKecamatanId)
                    .map((kelurahan) {
                      return DropdownMenuItem<String>(
                        value: kelurahan.id,
                        child: Text(kelurahan.name),
                      );
                    }).toList()
                : [],
            onChanged: (_selectedKecamatanId == null)
                ? null
                : (value) {
                    print('Kelurahan selected: $value');
                    setState(() {
                      _selectedKelurahanId = value;
                    });
                  },
          ),
        ],
      );
    } else {
      // Legacy region dropdowns (for backward compatibility)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Province dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Provinsi',
              border: OutlineInputBorder(),
            ),
            value: _selectedProvince,
            items: regionProvider.provinces.map((province) {
              return DropdownMenuItem<String>(
                value: province.code,
                child: Text(province.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _selectedCity = null;
                _selectedDistrict = null;
                _selectedVillage = null;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // City dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kabupaten/Kota',
              border: OutlineInputBorder(),
            ),
            value: _selectedCity,
            items: _selectedProvince != null
                ? regionProvider.getCitiesByProvinceId(int.parse(_selectedProvince!)).map((city) {
                    return DropdownMenuItem<String>(
                      value: city.code,
                      child: Text(city.name),
                    );
                  }).toList()
                : [],
            onChanged: _selectedProvince == null
                ? null
                : (value) {
                    setState(() {
                      _selectedCity = value;
                      _selectedDistrict = null;
                      _selectedVillage = null;
                    });
                  },
          ),
          const SizedBox(height: 16),
          
          // District dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kecamatan',
              border: OutlineInputBorder(),
            ),
            value: _selectedDistrict,
            items: _selectedCity != null
                ? regionProvider.getDistrictsByCityId(int.parse(_selectedCity!)).map((district) {
                    return DropdownMenuItem<String>(
                      value: district.code,
                      child: Text(district.name),
                    );
                  }).toList()
                : [],
            onChanged: _selectedCity == null
                ? null
                : (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedVillage = null;
                    });
                  },
          ),
          const SizedBox(height: 16),
          
          // Village dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kelurahan/Desa',
              border: OutlineInputBorder(),
            ),
            value: _selectedVillage,
            items: _selectedDistrict != null
                ? regionProvider.getVillagesByDistrictId(int.parse(_selectedDistrict!)).map((village) {
                    return DropdownMenuItem<String>(
                      value: village.code,
                      child: Text(village.name),
                    );
                  }).toList()
                : [],
            onChanged: _selectedDistrict == null
                ? null
                : (value) {
                    setState(() {
                      _selectedVillage = value;
                    });
                  },
          ),
        ],
      );
    }
  }
  
  Widget _buildStatusGenderFilters() {
    // Mengembalikan container kosong karena filter status telah dihapus
    return Container();
  }
}
