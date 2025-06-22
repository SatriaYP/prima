import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../providers/region_provider.dart';

class MemberDataTableWidget extends StatefulWidget {
  final List<Member>? members;
  final User? currentUser;
  final Function(Member) onViewMember;
  final Function(Member)? onEditMember;
  final Function(Member)? onDeleteMember;
  final bool isLoading;
  final bool showCheckboxColumn;
  final bool showMaritalStatus;
  final bool showUploadHistory;

  const MemberDataTableWidget({
    Key? key,
    this.members,
    required this.currentUser,
    required this.onViewMember,
    this.onEditMember,
    this.onDeleteMember,
    this.isLoading = false,
    this.showCheckboxColumn = false,
    this.showMaritalStatus = true,
    this.showUploadHistory = false,
  }) : super(key: key);
  
  @override
  State<MemberDataTableWidget> createState() => _MemberDataTableWidgetState();
}

class _MemberDataTableWidgetState extends State<MemberDataTableWidget> {
  Set<int> _selectedMembers = {};

  // Metode untuk menentukan level pengguna berdasarkan data user
  int _getUserLevel(User user) {
    // Contoh logika sederhana untuk menentukan level pengguna
    // Dalam implementasi nyata, ini harus menggunakan data yang sebenarnya dari model User
    
    // Asumsi: user memiliki properti role atau level
    // Contoh: 'admin_pusat', 'admin_provinsi', 'admin_kabupaten', 'admin_kecamatan', 'admin_desa'
    String? userRole = user.role;
    
    if (userRole == null) {
      return 0; // Default: pengurus pusat
    }
    
    if (userRole.contains('pusat')) {
      return 0; // Pengurus pusat
    } else if (userRole.contains('provinsi')) {
      return 1; // Pengurus provinsi
    } else if (userRole.contains('kabupaten') || userRole.contains('kota')) {
      return 2; // Pengurus kabupaten/kota
    } else if (userRole.contains('kecamatan')) {
      return 3; // Pengurus kecamatan
    } else if (userRole.contains('desa') || userRole.contains('kelurahan')) {
      return 4; // Pengurus desa/kelurahan
    }
    
    // Jika tidak ada yang cocok, gunakan ID pengguna untuk simulasi level
    // Ini hanya untuk contoh, dalam implementasi nyata gunakan data yang sebenarnya
    return user.id % 5;
  }
  
  @override
  Widget build(BuildContext context) {
    // Gunakan listen: false untuk mencegah rebuild yang tidak perlu
    final regionProvider = Provider.of<RegionProvider>(context, listen: false);

    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.members == null || widget.members!.isEmpty) {
      return const Center(
        child: Text('Tidak ada anggota ditemukan'),
      );
    }

    return PaginatedDataTable(
      header: null,
      rowsPerPage: 5,
      availableRowsPerPage: const [5, 10, 15, 20],
      horizontalMargin: 10,
      columnSpacing: 10,
      showCheckboxColumn: widget.showCheckboxColumn,
      columns: _buildColumns(),
      source: _MemberDataSource(
        members: widget.members!,
        regionProvider: regionProvider,
        currentUser: widget.currentUser,
        onViewMember: widget.onViewMember,
        onEditMember: widget.onEditMember,
        onDeleteMember: widget.onDeleteMember,
        showMaritalStatus: widget.showMaritalStatus,
        showUploadHistory: widget.showUploadHistory,
        context: context,
        selectedMembers: _selectedMembers,
        onSelectChanged: (int id, bool? selected) {
          setState(() {
            if (selected == true) {
              _selectedMembers.add(id);
            } else {
              _selectedMembers.remove(id);
            }
          });
        },
      ),
    );
  }
  
  List<DataColumn> _buildColumns() {
    final List<DataColumn> columns = [];
    
    // Menentukan judul kolom wilayah berdasarkan jenjang kepengurusan user yang login
    String wilayahTitle = 'Wilayah';
    if (widget.currentUser != null) {
      // Contoh logika untuk menentukan jenjang kepengurusan
      // Asumsi: currentUser memiliki properti level atau role yang menunjukkan jenjang kepengurusan
      final int userLevel = _getUserLevel(widget.currentUser!);
      
      switch (userLevel) {
        case 0: // Pengurus pusat
          wilayahTitle = 'Provinsi';
          break;
        case 1: // Pengurus provinsi
          wilayahTitle = 'Kabupaten/Kota';
          break;
        case 2: // Pengurus kabupaten/kota
          wilayahTitle = 'Kecamatan';
          break;
        case 3: // Pengurus kecamatan
          wilayahTitle = 'Desa/Kelurahan';
          break;
        case 4: // Pengurus desa
          wilayahTitle = 'Alamat';
          break;
        default:
          wilayahTitle = 'Wilayah';
      }
    }
    
    // Kolom dasar yang selalu ada
    columns.addAll([
      const DataColumn(label: Text('NIK')),
      const DataColumn(label: Text('Nama')),
      const DataColumn(label: Text('Pengurus')),
      const DataColumn(label: Text('KTA')),
      DataColumn(label: Text(wilayahTitle)), // Kolom wilayah yang dinamis berdasarkan level pengurus
      const DataColumn(label: Text('Aksi')),
      const DataColumn(label: Text('Riwayat')),
    ]);
    
    return columns;
  }
}

class _MemberDataSource extends DataTableSource {
  final List<Member> members;
  final RegionProvider regionProvider;
  final User? currentUser;
  final Function(Member) onViewMember;
  final Function(Member)? onEditMember;
  final Function(Member)? onDeleteMember;
  final bool showMaritalStatus;
  final bool showUploadHistory;
  final BuildContext context;
  final Set<int> selectedMembers;
  final Function(int, bool?) onSelectChanged;
  
  _MemberDataSource({
    required this.members,
    required this.regionProvider,
    required this.currentUser,
    required this.onViewMember,
    this.onEditMember,
    this.onDeleteMember,
    required this.showMaritalStatus,
    required this.showUploadHistory,
    required this.context,
    required this.selectedMembers,
    required this.onSelectChanged,
  });
  
  @override
  DataRow getRow(int index) {
    final member = members[index];
    
    // Menghitung usia berdasarkan tanggal lahir
    final DateTime birthDate = DateTime.tryParse(member.birthDate) ?? DateTime.now();
    final DateTime now = DateTime.now();
    final int age = now.year - birthDate.year - 
        (now.month > birthDate.month || 
        (now.month == birthDate.month && now.day >= birthDate.day) ? 0 : 1);
    
    // Status pengurus (contoh sederhana, sesuaikan dengan kebutuhan)
    final bool isPengurus = member.id % 5 == 0; // Contoh logika sederhana
    
    // Riwayat upload (contoh, sesuaikan dengan kebutuhan)
    final List<String> uploadSources = ['Mandiri', 'Pengurus DPP', 'Pengurus DPW', 'Pengurus DPK', 'Admin Sistem'];
    final String uploadSource = uploadSources[member.id % uploadSources.length];
    
    // Menentukan wilayah berdasarkan level pengurus yang login
    String wilayahText = '';
    // Mendapatkan level pengurus dari currentUser
    int userLevel = 0; // Default: pengurus pusat
    
    if (currentUser != null) {
      // Menggunakan logika yang sama seperti di _MemberDataTableWidgetState._getUserLevel
      String? userRole = currentUser?.role;
      
      if (userRole != null) {
        if (userRole.contains('pusat')) {
          userLevel = 0; // Pengurus pusat
        } else if (userRole.contains('provinsi')) {
          userLevel = 1; // Pengurus provinsi
        } else if (userRole.contains('kabupaten') || userRole.contains('kota')) {
          userLevel = 2; // Pengurus kabupaten/kota
        } else if (userRole.contains('kecamatan')) {
          userLevel = 3; // Pengurus kecamatan
        } else if (userRole.contains('desa') || userRole.contains('kelurahan')) {
          userLevel = 4; // Pengurus desa/kelurahan
        } else if (currentUser?.id != null) {
          userLevel = currentUser!.id % 5; // Simulasi jika tidak ada yang cocok
        }
      }
    }
    
    // Menampilkan data wilayah sesuai dengan level pengguna yang login
    switch (userLevel) {
      case 0: // Pengurus pusat melihat provinsi
        wilayahText = regionProvider.getProvinceNameById(member.provinceId);
        break;
      case 1: // Pengurus provinsi melihat kabupaten/kota
        wilayahText = regionProvider.getCityNameById(member.cityId);
        break;
      case 2: // Pengurus kabupaten/kota melihat kecamatan
        wilayahText = regionProvider.getDistrictNameById(member.districtId);
        break;
      case 3: // Pengurus kecamatan melihat desa/kelurahan
        wilayahText = regionProvider.getVillageNameById(member.districtId);
        break;
      case 4: // Pengurus desa melihat alamat
        wilayahText = member.address;
        break;
      default:
        wilayahText = regionProvider.getProvinceNameById(member.provinceId);
    }
    
    // Buat daftar sel
    final List<DataCell> cells = [];
    
    // Tambahkan sel sesuai dengan kolom yang telah diubah
    cells.add(DataCell(Text(member.nik)));
    cells.add(DataCell(Text(member.name)));
    cells.add(DataCell(Text(isPengurus ? 'Ya' : 'Tidak')));
    cells.add(DataCell(Text(member.ktaNumber)));
    cells.add(DataCell(Text(wilayahText)));
    
    // Aksi
    cells.add(DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // View button (all roles)
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () => onViewMember(member),
            tooltip: 'Lihat',
          ),
          
          // Edit button (admin and operator)
          if (currentUser?.canEditMembers == true && onEditMember != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => onEditMember!(member),
              tooltip: 'Ubah',
            ),
          
          // Delete button (admin only)
          if (currentUser?.canDeleteMembers == true && onDeleteMember != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDeleteMember!(member),
              tooltip: 'Hapus',
            ),
        ],
      ),
    ));
    
    // Riwayat
    cells.add(DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Histori button
          IconButton(
            icon: const Icon(Icons.history, color: Colors.purple),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Melihat histori untuk ${member.name}')),
              );
            },
            tooltip: 'Histori',
          ),
          // Tampilkan sumber upload
          Text(uploadSource, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ));
    
    return DataRow(
      selected: selectedMembers.contains(member.id),
      onSelectChanged: (selected) => onSelectChanged(member.id, selected),
      cells: cells,
    );
  }
  
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => members.length;

  @override
  int get selectedRowCount => selectedMembers.length;
}
