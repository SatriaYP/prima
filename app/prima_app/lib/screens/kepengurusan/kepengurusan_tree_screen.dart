import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/unit_kepengurusan_model.dart';
import '../../providers/kepengurusan_provider.dart';
import '../../widgets/prima_button.dart';
import 'unit_form_screen.dart';

class KepengurusanTreeScreen extends StatefulWidget {
  const KepengurusanTreeScreen({Key? key}) : super(key: key);

  @override
  State<KepengurusanTreeScreen> createState() => _KepengurusanTreeScreenState();
}

class _KepengurusanTreeScreenState extends State<KepengurusanTreeScreen> {
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
        title: const Text('Struktur Kepengurusan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to form to add new unit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UnitFormScreen(),
                ),
              );
            },
            tooltip: 'Tambah Unit Kepengurusan',
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

          final rootUnits = provider.getUnitTree();
          if (rootUnits.isEmpty) {
            return const Center(
              child: Text('Tidak ada data kepengurusan'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Struktur Organisasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...rootUnits.map((unit) => _buildUnitTree(unit, 0, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnitTree(UnitKepengurusan unit, int level, KepengurusanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 24.0),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: _getIconForLevel(unit.tingkat?.sequence ?? 0),
              title: Text(unit.name),
              subtitle: Text('${unit.tingkat?.name ?? ''} - ${unit.code}'),
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
                          builder: (context) => UnitFormScreen(unit: unit),
                        ),
                      );
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      // Navigate to form to add child unit
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnitFormScreen(parentUnit: unit),
                        ),
                      );
                    },
                    tooltip: 'Tambah Anak',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: unit.children.isEmpty
                        ? () async {
                            // Confirm deletion
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi'),
                                content: Text(
                                    'Apakah Anda yakin ingin menghapus ${unit.name}?'),
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
                                await provider.deleteUnit(unit.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Unit berhasil dihapus')),
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
                          }
                        : null, // Disable if has children
                    tooltip: unit.children.isEmpty
                        ? 'Hapus'
                        : 'Tidak dapat dihapus (memiliki anak)',
                  ),
                ],
              ),
              onTap: () {
                // Show details
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(unit.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kode: ${unit.code}'),
                        Text('Tingkat: ${unit.tingkat?.name ?? ''}'),
                        Text('Parent: ${unit.parent?.name ?? 'Tidak ada'}'),
                        Text('Jumlah Anak: ${unit.children.length}'),
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
          ),
        ),
        if (unit.children.isNotEmpty)
          ...unit.children
              .map((child) => _buildUnitTree(child, level + 1, provider)),
      ],
    );
  }

  Widget _getIconForLevel(int sequence) {
    switch (sequence) {
      case 4: // DPP
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.star, color: Colors.white),
        );
      case 3: // DPW
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.location_city, color: Colors.white),
        );
      case 2: // DPD
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.business, color: Colors.white),
        );
      case 1: // DPK
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.home_work, color: Colors.white),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.help, color: Colors.white),
        );
    }
  }
}
