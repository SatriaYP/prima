import 'package:flutter/material.dart';
import '../config/app_config.dart';

class MemberDataTable extends StatefulWidget {
  final List<bool> selectedMembers;
  final Function(int, bool) onSelectionChanged;

  const MemberDataTable({
    Key? key,
    required this.selectedMembers,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<MemberDataTable> createState() => _MemberDataTableState();
}

class _MemberDataTableState extends State<MemberDataTable> {
  int _entriesPerPage = 10;
  int _currentPage = 0;
  bool _selectAll = false;
  String _sortColumn = 'Nama';
  bool _sortAscending = true;
  
  final List<String> _columns = [
    'NIK', 'Nama', 'Pengurus', 'KTA', 'Jenis Kelamin', 'Usia',
    'Status Perkawinan', 'Pekerjaan', 'Alamat', 'Provinsi',
    'Kab/Kota', 'Kecamatan', 'Kelurahan', 'Tanggal Dibuat',
    'Aksi', 'Histori'
  ];
  
  final List<int> _entriesOptions = [10, 20, 50, 100, 200];
  
  // Sample data for demonstration
  final List<Map<String, dynamic>> _data = List.generate(
    50,
    (index) => {
      'NIK': '3${index.toString().padLeft(15, '0')}',
      'Nama': 'Anggota ${index + 1}',
      'Pengurus': index % 5 == 0 ? 'Ya' : 'Tidak',
      'KTA': 'KTA-${(index + 1).toString().padLeft(6, '0')}',
      'Jenis Kelamin': index % 2 == 0 ? 'Laki-laki' : 'Perempuan',
      'Usia': 25 + (index % 40),
      'Status Perkawinan': index % 3 == 0 ? 'Belum Kawin' : 'Kawin',
      'Pekerjaan': ['PNS', 'Swasta', 'Wiraswasta', 'Petani', 'Nelayan'][index % 5],
      'Alamat': 'Jl. Contoh No. ${index + 1}',
      'Provinsi': ['DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'Bali'][index % 5],
      'Kab/Kota': ['Jakarta Pusat', 'Bandung', 'Semarang', 'Surabaya', 'Denpasar'][index % 5],
      'Kecamatan': 'Kecamatan ${(index % 10) + 1}',
      'Kelurahan': 'Kelurahan ${(index % 20) + 1}',
      'Tanggal Dibuat': '${(index % 30) + 1}/0${(index % 12) + 1}/2024',
    },
  );
  
  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      
      // Update only the visible rows
      final startIndex = _currentPage * _entriesPerPage;
      final endIndex = (_currentPage + 1) * _entriesPerPage;
      
      for (int i = startIndex; i < endIndex && i < widget.selectedMembers.length; i++) {
        widget.onSelectionChanged(i, _selectAll);
      }
    });
  }
  
  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
      _selectAll = false;
    });
  }
  
  void _changeEntriesPerPage(int? value) {
    if (value != null) {
      setState(() {
        _entriesPerPage = value;
        _currentPage = 0;
        _selectAll = false;
      });
    }
  }
  
  void _sortData(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
      
      // In a real app, you would sort the actual data here
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    
    // Calculate pagination
    final int totalPages = (_data.length / _entriesPerPage).ceil();
    final int startIndex = _currentPage * _entriesPerPage;
    final int endIndex = (_currentPage + 1) * _entriesPerPage;
    final List<Map<String, dynamic>> visibleData = _data.sublist(
      startIndex,
      endIndex > _data.length ? _data.length : endIndex,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                'Data Anggota',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Entries per page dropdown
              Row(
                children: [
                  const Text('Tampilkan'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: _entriesPerPage,
                    items: _entriesOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: _changeEntriesPerPage,
                  ),
                  const SizedBox(width: 8),
                  const Text('entri'),
                ],
              ),
            ],
          ),
        ),
        
        // Table content
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              dataRowMaxHeight: 60,
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: _selectAll,
                    onChanged: _toggleSelectAll,
                  ),
                ),
                ..._columns.map((column) => DataColumn(
                  label: InkWell(
                    onTap: () => _sortData(column),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          column,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_sortColumn == column)
                          Icon(
                            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                )),
              ],
              rows: List.generate(
                visibleData.length,
                (index) {
                  final dataIndex = startIndex + index;
                  final item = visibleData[index];
                  return DataRow(
                    selected: widget.selectedMembers[dataIndex],
                    onSelectChanged: (value) {
                      widget.onSelectionChanged(dataIndex, value ?? false);
                    },
                    cells: [
                      DataCell(Checkbox(
                        value: widget.selectedMembers[dataIndex],
                        onChanged: (value) {
                          widget.onSelectionChanged(dataIndex, value ?? false);
                        },
                      )),
                      ...(_columns.map((column) {
                        if (column == 'Aksi') {
                          return DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blue),
                                  onPressed: () {},
                                  tooltip: 'Lihat Detail',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.green),
                                  onPressed: () {},
                                  tooltip: 'Download',
                                ),
                              ],
                            ),
                          );
                        } else if (column == 'Histori') {
                          return DataCell(
                            IconButton(
                              icon: const Icon(Icons.history, color: Colors.orange),
                              onPressed: () {},
                              tooltip: 'Lihat Histori',
                            ),
                          );
                        } else {
                          return DataCell(Text(item[column]?.toString() ?? ''));
                        }
                      })),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        
        // Pagination
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Menampilkan ${startIndex + 1} - ${endIndex > _data.length ? _data.length : endIndex} dari ${_data.length} entri'),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: _currentPage > 0 ? () => _changePage(0) : null,
                    tooltip: 'Halaman Pertama',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
                    tooltip: 'Halaman Sebelumnya',
                  ),
                  ...List.generate(
                    totalPages > 5 ? 5 : totalPages,
                    (index) {
                      final pageNumber = _currentPage - 2 + index;
                      if (pageNumber >= 0 && pageNumber < totalPages) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pageNumber == _currentPage
                                  ? AppConfig.primaryColor
                                  : Colors.white,
                              foregroundColor: pageNumber == _currentPage
                                  ? Colors.white
                                  : Colors.black,
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => _changePage(pageNumber),
                            child: Text('${pageNumber + 1}'),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < totalPages - 1
                        ? () => _changePage(_currentPage + 1)
                        : null,
                    tooltip: 'Halaman Berikutnya',
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: _currentPage < totalPages - 1
                        ? () => _changePage(totalPages - 1)
                        : null,
                    tooltip: 'Halaman Terakhir',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Selected items info
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Jumlah data terpilih: ${widget.selectedMembers.where((selected) => selected).length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        
        // Download selected button
        if (widget.selectedMembers.any((selected) => selected))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Data Terpilih'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Download selected items
              },
            ),
          ),
      ],
    );
  }
}