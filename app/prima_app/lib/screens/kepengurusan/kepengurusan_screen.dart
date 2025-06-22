import 'package:flutter/material.dart';
import 'kepengurusan_tree_screen.dart';
import 'tingkat_list_screen.dart';

class KepengurusanScreen extends StatefulWidget {
  const KepengurusanScreen({Key? key}) : super(key: key);

  @override
  State<KepengurusanScreen> createState() => _KepengurusanScreenState();
}

class _KepengurusanScreenState extends State<KepengurusanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kepengurusan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Tes Data Wilayah',
            onPressed: () {
              Navigator.pushNamed(context, '/wilayah_test');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Struktur Organisasi', icon: Icon(Icons.account_tree)),
            Tab(text: 'Tingkat Kepengurusan', icon: Icon(Icons.layers)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          KepengurusanTreeScreen(),
          TingkatListScreen(),
        ],
      ),
    );
  }
}
