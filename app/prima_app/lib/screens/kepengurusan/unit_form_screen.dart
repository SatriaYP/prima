import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tingkat_kepengurusan_model.dart';
import '../../models/unit_kepengurusan_model.dart';
import '../../providers/kepengurusan_provider.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/prima_text_field.dart';

class UnitFormScreen extends StatefulWidget {
  final UnitKepengurusan? unit;
  final UnitKepengurusan? parentUnit;

  const UnitFormScreen({Key? key, this.unit, this.parentUnit}) : super(key: key);

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  
  TingkatKepengurusan? _selectedTingkat;
  UnitKepengurusan? _selectedParent;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Jika mode edit, isi form dengan data unit yang ada
    if (widget.unit != null) {
      _nameController.text = widget.unit!.name;
      _codeController.text = widget.unit!.code;
    }
    
    // Load data when screen initializes
    Future.microtask(() {
      final provider = Provider.of<KepengurusanProvider>(context, listen: false);
      
      // Jika mode edit, set tingkat dan parent
      if (widget.unit != null) {
        _selectedTingkat = provider.getTingkatById(widget.unit!.tingkatId);
        if (widget.unit!.parentId != null) {
          _selectedParent = provider.getUnitById(widget.unit!.parentId!);
        }
      } 
      // Jika mode tambah anak, set parent
      else if (widget.parentUnit != null) {
        _selectedParent = widget.parentUnit;
        
        // Cari tingkat yang satu level di bawah parent
        final parentTingkat = provider.getTingkatById(widget.parentUnit!.tingkatId);
        if (parentTingkat != null) {
          final lowerTingkat = provider.tingkatList
              .where((t) => t.sequence < parentTingkat.sequence)
              .toList();
          if (lowerTingkat.isNotEmpty) {
            // Ambil tingkat tertinggi di bawah parent
            lowerTingkat.sort((a, b) => b.sequence.compareTo(a.sequence));
            _selectedTingkat = lowerTingkat.first;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _saveUnit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedTingkat == null) {
        setState(() {
          _error = 'Silakan pilih tingkat kepengurusan';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final provider = Provider.of<KepengurusanProvider>(context, listen: false);
        
        // Buat objek unit baru
        final newUnit = UnitKepengurusan(
          id: widget.unit?.id ?? DateTime.now().millisecondsSinceEpoch, // Generate ID baru jika mode tambah
          name: _nameController.text,
          code: _codeController.text,
          parentId: _selectedParent?.id,
          tingkatId: _selectedTingkat!.id,
          tingkat: _selectedTingkat,
          parent: _selectedParent,
        );
        
        // Simpan unit
        if (widget.unit != null) {
          // Mode edit
          await provider.updateUnit(newUnit);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unit berhasil diperbarui')),
            );
          }
        } else {
          // Mode tambah
          await provider.addUnit(newUnit);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unit berhasil ditambahkan')),
            );
          }
        }
        
        // Kembali ke layar sebelumnya
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _error = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit != null ? 'Edit Unit' : 'Tambah Unit'),
      ),
      body: Consumer<KepengurusanProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul form
                  Text(
                    widget.unit != null
                        ? 'Edit Unit Kepengurusan'
                        : widget.parentUnit != null
                            ? 'Tambah Unit Kepengurusan Baru di Bawah ${widget.parentUnit!.name}'
                            : 'Tambah Unit Kepengurusan Baru',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form fields
                  PrimaTextField(
                    label: 'Nama Unit',
                    hint: 'Masukkan nama unit kepengurusan',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama unit tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  PrimaTextField(
                    label: 'Kode Unit',
                    hint: 'Masukkan kode unit kepengurusan',
                    controller: _codeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kode unit tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown tingkat kepengurusan
                  DropdownButtonFormField<TingkatKepengurusan>(
                    decoration: const InputDecoration(
                      labelText: 'Tingkat Kepengurusan',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTingkat,
                    items: provider.tingkatList.map((tingkat) {
                      return DropdownMenuItem<TingkatKepengurusan>(
                        value: tingkat,
                        child: Text('${tingkat.name} (Level ${tingkat.sequence})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTingkat = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Silakan pilih tingkat kepengurusan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown parent unit
                  DropdownButtonFormField<UnitKepengurusan>(
                    decoration: const InputDecoration(
                      labelText: 'Unit Induk',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedParent,
                    items: [
                      // Opsi "Tidak Ada" untuk unit root
                      const DropdownMenuItem<UnitKepengurusan>(
                        value: null,
                        child: Text('Tidak Ada (Unit Root)'),
                      ),
                      // Daftar unit yang ada
                      ...provider.unitList.map((unit) {
                        // Jika mode edit, jangan tampilkan unit yang sedang diedit atau anak-anaknya
                        if (widget.unit != null) {
                          if (unit.id == widget.unit!.id || 
                              unit.isChildOf(widget.unit!)) {
                            return null;
                          }
                        }
                        return DropdownMenuItem<UnitKepengurusan>(
                          value: unit,
                          child: Text('${unit.name} (${unit.tingkat?.name ?? ''})'),
                        );
                      }).whereType<DropdownMenuItem<UnitKepengurusan>>(),
                    ],
                    onChanged: widget.parentUnit == null
                        ? (value) {
                            setState(() {
                              _selectedParent = value;
                            });
                          }
                        : null, // Disable jika parent sudah ditentukan
                    hint: const Text('Pilih unit induk'),
                  ),
                  
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaButton(
                      text: widget.unit != null ? 'Simpan Perubahan' : 'Tambah Unit',
                      icon: widget.unit != null ? Icons.save : Icons.add,
                      isLoading: _isLoading,
                      onPressed: _saveUnit,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
