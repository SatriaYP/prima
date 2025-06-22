import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tingkat_kepengurusan_model.dart';
import '../../models/wilayah_model.dart';
import '../../providers/kepengurusan_provider.dart';
import '../../providers/wilayah_provider.dart';
import '../../widgets/prima_app_bar.dart';
import '../../widgets/prima_button.dart';

class WilayahUnitFormScreen extends StatefulWidget {
  const WilayahUnitFormScreen({Key? key}) : super(key: key);

  @override
  State<WilayahUnitFormScreen> createState() => _WilayahUnitFormScreenState();
}

class _WilayahUnitFormScreenState extends State<WilayahUnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedTingkatId;
  String? _selectedProvinsiId;
  String? _selectedKabupatenId;
  String? _selectedKecamatanId;
  String? _selectedKelurahanId;
  int? _selectedParentUnitId;
  
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final kepengurusanProvider = Provider.of<KepengurusanProvider>(context);
    final wilayahProvider = Provider.of<WilayahProvider>(context);
    
    final tingkatList = kepengurusanProvider.tingkatList;
    final unitList = kepengurusanProvider.unitList;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Unit dari Wilayah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Unit Kepengurusan Berdasarkan Wilayah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Tingkat Kepengurusan
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Tingkat Kepengurusan',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTingkatId,
                items: tingkatList.map((tingkat) {
                  return DropdownMenuItem<int>(
                    value: tingkat.id,
                    child: Text(tingkat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTingkatId = value;
                    // Reset wilayah selections when tingkat changes
                    _selectedProvinsiId = null;
                    _selectedKabupatenId = null;
                    _selectedKecamatanId = null;
                    _selectedKelurahanId = null;
                    _selectedParentUnitId = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih tingkat kepengurusan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Parent Unit (if applicable)
              if (_selectedTingkatId != null && _selectedTingkatId != 1) // DPP doesn't have parent
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Unit Induk',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedParentUnitId,
                  items: unitList
                      .where((unit) => unit.tingkatId == _getParentTingkatId())
                      .map((unit) {
                    return DropdownMenuItem<int>(
                      value: unit.id,
                      child: Text(unit.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedParentUnitId = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedTingkatId != 1 && value == null) {
                      return 'Pilih unit induk';
                    }
                    return null;
                  },
                ),
              if (_selectedTingkatId != null && _selectedTingkatId != 1)
                const SizedBox(height: 16),
              
              // Provinsi (for all except DPP)
              if (_selectedTingkatId != null && _shouldShowProvinsiSelector())
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Provinsi',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedProvinsiId,
                  items: wilayahProvider.provinsiList.map((provinsi) {
                    return DropdownMenuItem<String>(
                      value: provinsi.id,
                      child: Text(provinsi.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvinsiId = value;
                      // Reset lower level selections
                      _selectedKabupatenId = null;
                      _selectedKecamatanId = null;
                      _selectedKelurahanId = null;
                    });
                  },
                  validator: (value) {
                    if (_shouldShowProvinsiSelector() && value == null) {
                      return 'Pilih provinsi';
                    }
                    return null;
                  },
                ),
              if (_selectedTingkatId != null && _shouldShowProvinsiSelector())
                const SizedBox(height: 16),
              
              // Kabupaten (for DPD and DPK)
              if (_selectedProvinsiId != null && _shouldShowKabupatenSelector())
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kabupaten/Kota',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedKabupatenId,
                  items: wilayahProvider
                      .getKabupatenByProvinsiId(_selectedProvinsiId!)
                      .map((kabupaten) {
                    return DropdownMenuItem<String>(
                      value: kabupaten.id,
                      child: Text(kabupaten.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKabupatenId = value;
                      // Reset lower level selections
                      _selectedKecamatanId = null;
                      _selectedKelurahanId = null;
                    });
                  },
                  validator: (value) {
                    if (_shouldShowKabupatenSelector() && value == null) {
                      return 'Pilih kabupaten/kota';
                    }
                    return null;
                  },
                ),
              if (_selectedProvinsiId != null && _shouldShowKabupatenSelector())
                const SizedBox(height: 16),
              
              // Kecamatan (for DPK)
              if (_selectedKabupatenId != null && _shouldShowKecamatanSelector())
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kecamatan',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedKecamatanId,
                  items: wilayahProvider
                      .getKecamatanByKabupatenId(_selectedKabupatenId!)
                      .map((kecamatan) {
                    return DropdownMenuItem<String>(
                      value: kecamatan.id,
                      child: Text(kecamatan.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKecamatanId = value;
                      _selectedKelurahanId = null;
                    });
                  },
                  validator: (value) {
                    if (_shouldShowKecamatanSelector() && value == null) {
                      return 'Pilih kecamatan';
                    }
                    return null;
                  },
                ),
              if (_selectedKabupatenId != null && _shouldShowKecamatanSelector())
                const SizedBox(height: 16),
              
              const SizedBox(height: 24),
              
              // Submit Button
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : PrimaButton(
                        text: 'Buat Unit',
                        onPressed: _submitForm,
                        icon: Icons.save,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to get parent tingkat ID
  int? _getParentTingkatId() {
    if (_selectedTingkatId == null) return null;
    
    // Get the parent tingkat (tingkat with higher sequence)
    final kepengurusanProvider = Provider.of<KepengurusanProvider>(context, listen: false);
    final currentTingkat = kepengurusanProvider.tingkatList
        .firstWhere((t) => t.id == _selectedTingkatId);
    
    // Find tingkat with next higher sequence
    final parentTingkat = kepengurusanProvider.tingkatList
        .where((t) => t.sequence > currentTingkat.sequence)
        .fold<TingkatKepengurusan?>(
          null,
          (prev, t) => prev == null || t.sequence < prev.sequence ? t : prev,
        );
    
    return parentTingkat?.id;
  }
  
  // Helper methods to determine which selectors to show
  bool _shouldShowProvinsiSelector() {
    // Show provinsi selector for DPW, DPD, DPK
    return _selectedTingkatId == 2 || _selectedTingkatId == 3 || _selectedTingkatId == 4;
  }
  
  bool _shouldShowKabupatenSelector() {
    // Show kabupaten selector for DPD and DPK
    return _selectedTingkatId == 3 || _selectedTingkatId == 4;
  }
  
  bool _shouldShowKecamatanSelector() {
    // Show kecamatan selector for DPK
    return _selectedTingkatId == 4;
  }
  
  // Submit form
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final kepengurusanProvider = Provider.of<KepengurusanProvider>(context, listen: false);
        final wilayahProvider = Provider.of<WilayahProvider>(context, listen: false);
        
        // Determine which wilayah to use based on selected tingkat
        String wilayahId;
        String wilayahName;
        String wilayahCode;
        
        if (_selectedTingkatId == 1) { // DPP
          wilayahId = '0';
          wilayahName = 'Indonesia';
          wilayahCode = '00';
        } else if (_selectedTingkatId == 2) { // DPW
          final provinsi = wilayahProvider.getProvinsiById(_selectedProvinsiId!);
          wilayahId = provinsi!.id;
          wilayahName = provinsi.name;
          wilayahCode = provinsi.code;
        } else if (_selectedTingkatId == 3) { // DPD
          final kabupaten = wilayahProvider.getKabupatenById(_selectedKabupatenId!);
          wilayahId = kabupaten!.id;
          wilayahName = kabupaten.name;
          wilayahCode = kabupaten.code;
        } else { // DPK
          final kecamatan = wilayahProvider.getKecamatanById(_selectedKecamatanId!);
          wilayahId = kecamatan!.id;
          wilayahName = kecamatan.name;
          wilayahCode = kecamatan.code;
        }
        
        // Create unit
        await kepengurusanProvider.createUnitFromWilayah(
          tingkatId: _selectedTingkatId!,
          wilayahId: wilayahId,
          wilayahName: wilayahName,
          wilayahCode: wilayahCode,
          parentUnitId: _selectedParentUnitId,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unit kepengurusan berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
