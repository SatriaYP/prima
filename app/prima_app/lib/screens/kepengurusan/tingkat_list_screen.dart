import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tingkat_kepengurusan_model.dart';
import '../../providers/kepengurusan_provider.dart';
import '../../widgets/prima_button.dart';
import 'tingkat_form_screen.dart';

class TingkatListScreen extends StatefulWidget {
  const TingkatListScreen({Key? key}) : super(key: key);

  @override
  State<TingkatListScreen> createState() => _TingkatListScreenState();
}

class _TingkatListScreenState extends State<TingkatListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    Future.microtask(() {
      Provider.of<KepengurusanProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tingkat Kepengurusan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to form to add new tingkat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TingkatFormScreen(),
                ),
              );
            },
            tooltip: 'Tambah Tingkat Kepengurusan',
          ),
        ],
      ),
      body: Consumer<KepengurusanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  PrimaButton(
                    text: 'Coba Lagi',
                    onPressed: () {
                      // Reload data
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          }

          final tingkatList = provider.tingkatList;
          if (tingkatList.isEmpty) {
            return const Center(
              child: Text('Tidak ada data tingkat kepengurusan'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tingkatList.length,
            itemBuilder: (context, index) {
              final tingkat = tingkatList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForLevel(tingkat.sequence),
                    child: Text(
                      tingkat.sequence.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(tingkat.name),
                  subtitle: Text('Level: ${tingkat.sequence}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to edit form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TingkatFormScreen(tingkat: tingkat),
                            ),
                          );
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Cek apakah tingkat ini digunakan oleh unit
                          final unitsUsingTingkat = provider.unitList
                              .where((unit) => unit.tingkatId == tingkat.id)
                              .toList();
                          
                          if (unitsUsingTingkat.isNotEmpty) {
                            // Tampilkan pesan error
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tidak dapat menghapus tingkat ini karena digunakan oleh ${unitsUsingTingkat.length} unit',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }
                          
                          // Confirm deletion
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: Text(
                                  'Apakah Anda yakin ingin menghapus tingkat ${tingkat.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await provider.deleteTingkat(tingkat.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Tingkat berhasil dihapus')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          }
                        },
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show details
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(tingkat.name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Level: ${tingkat.sequence}'),
                            const SizedBox(height: 8),
                            const Text('Unit yang menggunakan tingkat ini:'),
                            const SizedBox(height: 4),
                            ...provider.unitList
                                .where((unit) => unit.tingkatId == tingkat.id)
                                .map((unit) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('• ${unit.name} (${unit.code})'),
                                    )),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorForLevel(int sequence) {
    switch (sequence) {
      case 4:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 1:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
