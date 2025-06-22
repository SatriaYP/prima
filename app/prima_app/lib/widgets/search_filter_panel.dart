import 'package:flutter/material.dart';
import '../config/app_config.dart';

class SearchFilterPanel extends StatefulWidget {
  const SearchFilterPanel({Key? key}) : super(key: key);

  @override
  State<SearchFilterPanel> createState() => _SearchFilterPanelState();
}

class _SearchFilterPanelState extends State<SearchFilterPanel> {
  String _selectedSearchField = 'NIK';
  String? _selectedProvinsi;
  String? _selectedKabupaten;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _searchFields = ['NIK', 'Nama', 'No KTA', 'Alamat'];
  final List<String> _provinsiList = ['DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'Bali'];
  final Map<String, List<String>> _kabupatenMap = {
    'DKI Jakarta': ['Jakarta Pusat', 'Jakarta Utara', 'Jakarta Barat', 'Jakarta Selatan', 'Jakarta Timur'],
    'Jawa Barat': ['Bandung', 'Bogor', 'Bekasi', 'Depok', 'Cirebon'],
    'Jawa Tengah': ['Semarang', 'Solo', 'Magelang', 'Pekalongan', 'Tegal'],
    'Jawa Timur': ['Surabaya', 'Malang', 'Sidoarjo', 'Kediri', 'Jember'],
    'Bali': ['Denpasar', 'Badung', 'Gianyar', 'Tabanan', 'Karangasem'],
  };
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedProvinsi = null;
      _selectedKabupaten = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    final isTablet = screenWidth > 600 && screenWidth <= 1100;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Pencarian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Search fields
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field dropdown and input
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        padding: const EdgeInsets.only(right: 8),
                        child: DropdownButtonFormField<String>(
                          value: _selectedSearchField,
                          decoration: const InputDecoration(
                            labelText: 'Cari berdasarkan',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _searchFields.map((field) {
                            return DropdownMenuItem<String>(
                              value: field,
                              child: Text(field),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSearchField = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Masukkan $_selectedSearchField',
                            hintText: 'Cari $_selectedSearchField...',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Region filters
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedProvinsi,
                          decoration: const InputDecoration(
                            labelText: 'Provinsi',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Pilih Provinsi'),
                          items: _provinsiList.map((provinsi) {
                            return DropdownMenuItem<String>(
                              value: provinsi,
                              child: Text(provinsi),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProvinsi = value;
                              _selectedKabupaten = null;
                              _selectedKecamatan = null;
                              _selectedKelurahan = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedKabupaten,
                          decoration: const InputDecoration(
                            labelText: 'Kabupaten/Kota',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Pilih Kabupaten'),
                          items: _selectedProvinsi != null
                              ? _kabupatenMap[_selectedProvinsi]!.map((kabupaten) {
                                  return DropdownMenuItem<String>(
                                    value: kabupaten,
                                    child: Text(kabupaten),
                                  );
                                }).toList()
                              : [],
                          onChanged: _selectedProvinsi != null
                              ? (value) {
                                  setState(() {
                                    _selectedKabupaten = value;
                                    _selectedKecamatan = null;
                                    _selectedKelurahan = null;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                // Search field dropdown and input
                Row(
                  children: [
                    Container(
                      width: 120,
                      padding: const EdgeInsets.only(right: 8),
                      child: DropdownButtonFormField<String>(
                        value: _selectedSearchField,
                        decoration: const InputDecoration(
                          labelText: 'Cari',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _searchFields.map((field) {
                          return DropdownMenuItem<String>(
                            value: field,
                            child: Text(field),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSearchField = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Masukkan $_selectedSearchField',
                          hintText: 'Cari $_selectedSearchField...',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Region filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedProvinsi,
                        decoration: const InputDecoration(
                          labelText: 'Provinsi',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        hint: const Text('Pilih Provinsi'),
                        items: _provinsiList.map((provinsi) {
                          return DropdownMenuItem<String>(
                            value: provinsi,
                            child: Text(provinsi),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProvinsi = value;
                            _selectedKabupaten = null;
                            _selectedKecamatan = null;
                            _selectedKelurahan = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedKabupaten,
                        decoration: const InputDecoration(
                          labelText: 'Kabupaten/Kota',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        hint: const Text('Pilih Kabupaten'),
                        items: _selectedProvinsi != null
                            ? _kabupatenMap[_selectedProvinsi]!.map((kabupaten) {
                                return DropdownMenuItem<String>(
                                  value: kabupaten,
                                  child: Text(kabupaten),
                                );
                              }).toList()
                            : [],
                        onChanged: _selectedProvinsi != null
                            ? (value) {
                                setState(() {
                                  _selectedKabupaten = value;
                                  _selectedKecamatan = null;
                                  _selectedKelurahan = null;
                                });
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppConfig.primaryColor),
                ),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Cari'),
                onPressed: () {
                  // Implement search functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
