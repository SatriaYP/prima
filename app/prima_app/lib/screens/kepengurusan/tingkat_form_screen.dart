import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/tingkat_kepengurusan_model.dart';
import '../../providers/kepengurusan_provider.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/prima_text_field.dart';

class TingkatFormScreen extends StatefulWidget {
  final TingkatKepengurusan? tingkat;

  const TingkatFormScreen({Key? key, this.tingkat}) : super(key: key);

  @override
  State<TingkatFormScreen> createState() => _TingkatFormScreenState();
}

class _TingkatFormScreenState extends State<TingkatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sequenceController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Jika mode edit, isi form dengan data tingkat yang ada
    if (widget.tingkat != null) {
      _nameController.text = widget.tingkat!.name;
      _sequenceController.text = widget.tingkat!.sequence.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sequenceController.dispose();
    super.dispose();
  }

  void _saveTingkat() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final provider = Provider.of<KepengurusanProvider>(context, listen: false);
        
        // Buat objek tingkat baru
        final newTingkat = TingkatKepengurusan(
          id: widget.tingkat?.id ?? DateTime.now().millisecondsSinceEpoch, // Generate ID baru jika mode tambah
          name: _nameController.text,
          sequence: int.parse(_sequenceController.text),
        );
        
        // Simpan tingkat
        if (widget.tingkat != null) {
          // Mode edit
          await provider.updateTingkat(newTingkat);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tingkat berhasil diperbarui')),
            );
          }
        } else {
          // Mode tambah
          await provider.addTingkat(newTingkat);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tingkat berhasil ditambahkan')),
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
        title: Text(widget.tingkat != null ? 'Edit Tingkat' : 'Tambah Tingkat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul form
              Text(
                widget.tingkat != null
                    ? 'Edit Tingkat Kepengurusan'
                    : 'Tambah Tingkat Kepengurusan Baru',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Form fields
              PrimaTextField(
                label: 'Nama Tingkat',
                hint: 'Masukkan nama tingkat kepengurusan (mis. DPP, DPW)',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tingkat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaTextField(
                label: 'Level (Sequence)',
                hint: 'Masukkan level tingkat (angka, semakin besar semakin tinggi)',
                controller: _sequenceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Level tidak boleh kosong';
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Level harus berupa angka';
                  }
                  if (number < 1) {
                    return 'Level minimal 1';
                  }
                  return null;
                },
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
                  text: widget.tingkat != null ? 'Simpan Perubahan' : 'Tambah Tingkat',
                  icon: widget.tingkat != null ? Icons.save : Icons.add,
                  isLoading: _isLoading,
                  onPressed: _saveTingkat,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
