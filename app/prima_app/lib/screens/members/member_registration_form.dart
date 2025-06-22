import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/member_model.dart';
import '../../providers/region_provider.dart';
import '../../providers/member_provider.dart';
import '../../models/wilayah_model.dart';

class MemberRegistrationForm extends StatefulWidget {
  const MemberRegistrationForm({Key? key}) : super(key: key);

  @override
  State<MemberRegistrationForm> createState() => _MemberRegistrationFormState();
}

class _MemberRegistrationFormState extends State<MemberRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form data
  final Map<String, dynamic> _formData = {
    'nik': '',
    'nama': '',
    'alamat': '',
    'provinsiId': '',
    'kabupatenId': '',
    'kecamatanId': '',
    'kelurahanId': '',
    'penerbitKta': 'DPP PRIMA',
    'jenisKelamin': '',
    'tempatLahir': '',
    'tanggalLahir': '',
    'statusPerkawinan': '',
    'statusPekerjaan': '',
    'noKta': '',
    'minatBakat': '',
    'fotoKtp': null,
    'isConfirmed': false,
  };
  
  // Selected region IDs
  String? _selectedProvinsiId;
  String? _selectedKabupatenId;
  String? _selectedKecamatanId;
  String? _selectedKelurahanId;
  
  // Controllers
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _minatBakatController = TextEditingController();
  final _ktaController = TextEditingController();
  
  // File for KTP
  File? _ktpImage;
  
  // Date picker
  DateTime? _selectedDate;

  // Map to track the count of members per village
  // static Map<String, int> _villageSequentialNumbers = {};

  // Generate KTA number based on region codes
  String _generateKtaNumber(RegionProvider regionProvider) {
    if (_selectedProvinsiId == null || _selectedKabupatenId == null || 
        _selectedKecamatanId == null || _selectedKelurahanId == null) {
      return '';
    }
    
    // Find the selected regions to get their codes
    String provinceCode = '';
    String regencyCode = '';
    String districtCode = '';
    
    try {
      // Get province code - should be 2 digits (e.g., 32 for Jawa Barat)
      final selectedProvinsi = regionProvider.provinsiList.firstWhere(
        (provinsi) => provinsi.id == _selectedProvinsiId,
        orElse: () => Provinsi(id: '', name: '', code: ''),
      );
      // Extract just the province code (first 2 digits)
      provinceCode = selectedProvinsi.id.substring(0, 2);
      
      // Get regency/city code - should be 2 digits (e.g., 16 for Kabupaten Bekasi)
      final selectedKabupaten = regionProvider.kabupatenList.firstWhere(
        (kabupaten) => kabupaten.id == _selectedKabupatenId,
        orElse: () => Kabupaten(id: '', provinsiId: '', name: '', code: ''),
      );
      // Extract just the regency code (3rd and 4th digits of the ID)
      regencyCode = selectedKabupaten.id.substring(2, 4);
      
      // Get district code - should be 2 digits (e.g., 08 for Tambun Selatan)
      final selectedKecamatan = regionProvider.kecamatanList.firstWhere(
        (kecamatan) => kecamatan.id == _selectedKecamatanId,
        orElse: () => Kecamatan(id: '', kabupatenId: '', name: '', code: ''),
      );
      // Extract just the district code (5th and 6th digits of the ID)
      districtCode = selectedKecamatan.id.substring(4, 6);
      
      // Get village ID for the sequential number
      final selectedKelurahan = regionProvider.kelurahanList.firstWhere(
        (kelurahan) => kelurahan.id == _selectedKelurahanId,
        orElse: () => Kelurahan(id: '', kecamatanId: '', name: '', code: ''),
      );
      
      // Last 4 digits: fixed sequential number (0001) for now
      // In production, this would be fetched from the database and incremented
      String sequentialNumber = '0001';
      
      return '$provinceCode$regencyCode$districtCode$sequentialNumber';
    } catch (e) {
      print('Error generating KTA number: $e');
      return '';
    }
  }

  // Update KTA number when region selection changes
  void _updateKtaNumber(RegionProvider regionProvider) {
    setState(() {
      _formData['noKta'] = _generateKtaNumber(regionProvider);
      _ktaController.text = _formData['noKta'];
    });
  }

  @override
  void initState() {
    super.initState();
    // Load regions data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regionProvider = Provider.of<RegionProvider>(context, listen: false);
      regionProvider.loadRegionData();
    });
  }
  
  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _minatBakatController.dispose();
    _ktaController.dispose();
    super.dispose();
  }

  void _handleInputChange(String field, String value) {
    setState(() {
      _formData[field] = value;
    });
  }

  void _handleCheckboxChange(bool? checked) {
    setState(() {
      _formData['isConfirmed'] = checked ?? false;
    });
  }

  Future<void> _pickKtpImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _ktpImage = File(image.path);
        _formData['fotoKtp'] = image.path;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto KTP berhasil diunggah')),
      );
    }
  }

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    
    if (result != null) {
      // In a real app, you would process the Excel file here
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File Excel berhasil diunggah')),
      );
    }
  }
  
  // Show dialog with preview of Excel data
  void _showExcelPreviewDialog() {
    // Placeholder for future implementation
  }
  
  // Submit all Excel data
  void _submitExcelData() async {
    // Placeholder for future implementation
  }

  void _downloadExcelTemplate() async {
    // Placeholder for future implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template Excel akan tersedia di versi mendatang'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _formData.forEach((key, value) {
        if (key != 'penerbitKta' && key != 'noKta') {
          _formData[key] = key == 'isConfirmed' ? false : '';
        }
      });
      
      _nikController.clear();
      _namaController.clear();
      _alamatController.clear();
      _tempatLahirController.clear();
      _tanggalLahirController.clear();
      _minatBakatController.clear();
      _ktaController.clear();
      
      _ktpImage = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_formData['isConfirmed']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap konfirmasi bahwa data yang dimasukkan sudah benar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // In a real app, you would submit the form data to your backend here
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data anggota berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regionProvider = Provider.of<RegionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Data Anggota'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Excel upload button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tambah Data Anggota',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickExcelFile,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _downloadExcelTemplate,
                          icon: const Icon(Icons.download),
                          label: const Text('Download Template'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // KTP data notice
                    Container(
                      color: Colors.blue,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Text('i', style: TextStyle(color: Colors.blue)),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Data Isian disesuaikan dengan KTP',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form fields
                    Text(
                      'Upload Mandiri',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Two column layout for larger screens
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column
                              Expanded(
                                child: _buildLeftColumn(regionProvider),
                              ),
                              const SizedBox(width: 16),
                              // Right column
                              Expanded(
                                child: _buildRightColumn(regionProvider),
                              ),
                            ],
                          );
                        } else {
                          // Single column for smaller screens
                          return Column(
                            children: [
                              _buildLeftColumn(regionProvider),
                              const SizedBox(height: 16),
                              _buildRightColumn(regionProvider),
                            ],
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Documents section
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Dokumen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Minat dan Bakat
                    _buildFormField(
                      label: 'Minat dan Bakat',
                      child: TextFormField(
                        controller: _minatBakatController,
                        decoration: const InputDecoration(
                          hintText: 'Tuliskan minat dan bakat anda...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => _handleInputChange('minatBakat', value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // KTP Upload
                    _buildFormField(
                      label: 'Foto KTP',
                      isRequired: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickKtpImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('UPLOAD'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          if (_ktpImage != null) ...[  
                            const SizedBox(height: 8),
                            Text('File: ${_ktpImage!.path.split('/').last}'),
                            const SizedBox(height: 8),
                            Image.file(
                              _ktpImage!,
                              height: 100,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Confirmation checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _formData['isConfirmed'],
                          onChanged: _handleCheckboxChange,
                        ),
                        const Expanded(
                          child: Text(
                            'Dengan ini saya menyatakan bahwa data yang saya isi adalah benar',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit and Reset buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: _resetForm,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 48),
                          ),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(120, 48),
                          ),
                          child: const Text('Simpan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(RegionProvider regionProvider) {
    return Column(
      children: [
        // NIK
        _buildFormField(
          label: 'NIK',
          isRequired: true,
          child: TextFormField(
            controller: _nikController,
            decoration: const InputDecoration(
              hintText: 'NIK',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'NIK tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('nik', value),
          ),
        ),
        const SizedBox(height: 16),
        
        // Nama
        _buildFormField(
          label: 'Nama Sesuai KTP',
          isRequired: true,
          child: TextFormField(
            controller: _namaController,
            decoration: const InputDecoration(
              hintText: 'Nama Sesuai KTP',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('nama', value),
          ),
        ),
        const SizedBox(height: 16),
        
        // Alamat
        _buildFormField(
          label: 'Alamat',
          isRequired: true,
          child: TextFormField(
            controller: _alamatController,
            decoration: const InputDecoration(
              hintText: 'Alamat',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Alamat tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('alamat', value),
          ),
        ),
        const SizedBox(height: 16),
        
        // Provinsi
        _buildFormField(
          label: 'Provinsi',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Provinsi',
              border: OutlineInputBorder(),
            ),
            value: _formData['provinsiId'].isEmpty ? null : _formData['provinsiId'],
            items: regionProvider.provinsiList.map((provinsi) {
              return DropdownMenuItem(
                value: provinsi.id,
                child: Text(provinsi.name),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Provinsi tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _formData['provinsiId'] = value;
                  _formData['kabupatenId'] = '';
                  _formData['kecamatanId'] = '';
                  _formData['kelurahanId'] = '';
                  _selectedKabupatenId = null;
                  _selectedKecamatanId = null;
                  _selectedKelurahanId = null;
                  _selectedProvinsiId = value;
                });
                // Load kabupaten when provinsi is selected
                regionProvider.getKabupatenByProvinsiId(value);
                _updateKtaNumber(regionProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Kabupaten
        _buildFormField(
          label: 'Kabupaten / Kota',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Kabupaten / Kota',
              border: OutlineInputBorder(),
            ),
            value: _formData['kabupatenId'].isEmpty ? null : _formData['kabupatenId'],
            items: _selectedProvinsiId != null
                ? regionProvider.kabupatenList
                    .where((kabupaten) => kabupaten.provinsiId == _selectedProvinsiId)
                    .map((kabupaten) {
                      return DropdownMenuItem<String>(
                        value: kabupaten.id,
                        child: Text(kabupaten.name),
                      );
                    }).toList()
                : [],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kabupaten / Kota tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _formData['kabupatenId'] = value;
                  _formData['kecamatanId'] = '';
                  _formData['kelurahanId'] = '';
                  _selectedKecamatanId = null;
                  _selectedKelurahanId = null;
                  _selectedKabupatenId = value;
                });
                // Load kecamatan when kabupaten is selected
                regionProvider.getKecamatanByKabupatenId(value);
                _updateKtaNumber(regionProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Kecamatan
        _buildFormField(
          label: 'Kecamatan',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Kecamatan',
              border: OutlineInputBorder(),
            ),
            value: _formData['kecamatanId'].isEmpty ? null : _formData['kecamatanId'],
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kecamatan tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _formData['kecamatanId'] = value;
                  _formData['kelurahanId'] = '';
                  _selectedKelurahanId = null;
                  _selectedKecamatanId = value;
                });
                // Load kelurahan when kecamatan is selected
                regionProvider.getKelurahanByKecamatanId(value);
                _updateKtaNumber(regionProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Kelurahan
        _buildFormField(
          label: 'Kelurahan',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Kelurahan',
              border: OutlineInputBorder(),
            ),
            value: _formData['kelurahanId'].isEmpty ? null : _formData['kelurahanId'],
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kelurahan tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _formData['kelurahanId'] = value;
                  _selectedKelurahanId = value;
                });
                _updateKtaNumber(regionProvider);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Tanggal Lahir
        _buildFormField(
          label: 'Tanggal Lahir',
          isRequired: true,
          child: ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _formData['tanggalLahir'] = _selectedDate.toString().split(' ')[0];
                });
              }
            },
            child: Text(_selectedDate != null ? _selectedDate.toString().split(' ')[0] : 'Pilih Tanggal Lahir'),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(RegionProvider regionProvider) {
    return Column(
      children: [
        // Penerbit KTA
        _buildFormField(
          label: 'Penerbit KTA',
          child: TextFormField(
            initialValue: _formData['penerbitKta'],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(height: 16),
        
        // Jenis Kelamin
        _buildFormField(
          label: 'Jenis Kelamin',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Jenis Kelamin',
              border: OutlineInputBorder(),
            ),
            value: _formData['jenisKelamin'].isEmpty ? null : _formData['jenisKelamin'],
            items: const [
              DropdownMenuItem(value: 'laki-laki', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'perempuan', child: Text('Perempuan')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis Kelamin tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('jenisKelamin', value!),
          ),
        ),
        const SizedBox(height: 16),
        
        // Tempat Lahir
        _buildFormField(
          label: 'Tempat Lahir',
          isRequired: true,
          child: TextFormField(
            controller: _tempatLahirController,
            decoration: const InputDecoration(
              hintText: 'Tempat Lahir',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tempat Lahir tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('tempatLahir', value),
          ),
        ),
        const SizedBox(height: 16),
        
        // Status Perkawinan
        _buildFormField(
          label: 'Status Perkawinan',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Status Perkawinan',
              border: OutlineInputBorder(),
            ),
            value: _formData['statusPerkawinan'].isEmpty ? null : _formData['statusPerkawinan'],
            items: const [
              DropdownMenuItem(value: 'belum-kawin', child: Text('Belum Kawin')),
              DropdownMenuItem(value: 'kawin', child: Text('Kawin')),
              DropdownMenuItem(value: 'cerai-hidup', child: Text('Cerai Hidup')),
              DropdownMenuItem(value: 'cerai-mati', child: Text('Cerai Mati')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Status Perkawinan tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('statusPerkawinan', value!),
          ),
        ),
        const SizedBox(height: 16),
        
        // Status Pekerjaan
        _buildFormField(
          label: 'Status Pekerjaan',
          isRequired: true,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Pilih Status Pekerjaan',
              border: OutlineInputBorder(),
            ),
            value: _formData['statusPekerjaan'].isEmpty ? null : _formData['statusPekerjaan'],
            items: const [
              DropdownMenuItem(value: 'pns', child: Text('PNS')),
              DropdownMenuItem(value: 'swasta', child: Text('Karyawan Swasta')),
              DropdownMenuItem(value: 'wirausaha', child: Text('Wirausaha')),
              DropdownMenuItem(value: 'pelajar', child: Text('Pelajar/Mahasiswa')),
              DropdownMenuItem(value: 'tidak-bekerja', child: Text('Tidak Bekerja')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Status Pekerjaan tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) => _handleInputChange('statusPekerjaan', value!),
          ),
        ),
        const SizedBox(height: 16),
        
        // No. KTA
        _buildFormField(
          label: 'No. KTA',
          isRequired: true,
          child: TextFormField(
            controller: _ktaController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Nomor KTA akan terisi otomatis',
            ),
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              '$label${isRequired ? '*' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
  
  // List to store multiple member data from Excel
  // List<Map<String, dynamic>> _excelMembersList = [];
  // bool _showExcelPreview = false;
}
