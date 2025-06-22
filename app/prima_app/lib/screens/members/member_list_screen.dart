import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/region_provider.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/responsive_layout.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({Key? key}) : super(key: key);

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();
  String? _statusFilter;
  String? _genderFilter;
  int? _provinceIdFilter;
  int? _cityIdFilter;
  int? _districtIdFilter;
  bool _isFilterExpanded = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;
    
    try {
      // Load regions first
      await Provider.of<RegionProvider>(context, listen: false).loadRegionData();
      
      // Check again if widget is still mounted after the first async operation
      if (!mounted) return;
      
      // Then load members
      await Provider.of<MemberProvider>(context, listen: false).loadMembers(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        status: _statusFilter,
        gender: _genderFilter,
        provinceId: _provinceIdFilter,
        cityId: _cityIdFilter,
        districtId: _districtIdFilter,
      );
    } catch (e) {
      // Handle any errors that might occur during data loading
      print('Error loading data: $e');
      // Only show error if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      if (!memberProvider.isLoading && memberProvider.hasMoreData) {
        memberProvider.loadMoreMembers();
      }
    }
  }

  void _applyFilters() {
    Provider.of<MemberProvider>(context, listen: false).loadMembers(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      status: _statusFilter,
      gender: _genderFilter,
      provinceId: _provinceIdFilter,
      cityId: _cityIdFilter,
      districtId: _districtIdFilter,
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = null;
      _genderFilter = null;
      _provinceIdFilter = null;
      _cityIdFilter = null;
      _districtIdFilter = null;
    });
    
    Provider.of<MemberProvider>(context, listen: false).loadMembers();
  }

  void _navigateToMemberDetail(Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(member: member),
      ),
    );
  }

  void _navigateToAddMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MemberFormScreen(isEditing: false),
      ),
    ).then((_) {
      // Refresh the list when returning from add/edit screen
      _loadData();
    });
  }

  void _navigateToEditMember(Member member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberFormScreen(
          isEditing: true,
          member: member,
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from add/edit screen
      _loadData();
    });
  }

  Future<void> _confirmDeleteMember(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final success = await memberProvider.deleteMember(member.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final regionProvider = Provider.of<RegionProvider>(context);
    final User? currentUser = authProvider.currentUser;
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Member Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (currentUser?.canCreateMembers == true)
                PrimaButton(
                  text: 'Add Member',
                  onPressed: _navigateToAddMember,
                  icon: Icons.person_add,
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search and filter
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name, NIK, or KTA number',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSubmitted: (_) => _applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          _isFilterExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFilterExpanded = !_isFilterExpanded;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isFilterExpanded) ...[
                    const SizedBox(height: 16),
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusFilter(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGenderFilter(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProvinceFilter(regionProvider),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildStatusFilter(),
                          const SizedBox(height: 16),
                          _buildGenderFilter(),
                          const SizedBox(height: 16),
                          _buildProvinceFilter(regionProvider),
                        ],
                      ),
                    const SizedBox(height: 16),
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _buildCityFilter(regionProvider),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDistrictFilter(regionProvider),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: _resetFilters,
                                  child: const Text('Reset'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _applyFilters,
                                  child: const Text('Apply Filters'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildCityFilter(regionProvider),
                          const SizedBox(height: 16),
                          _buildDistrictFilter(regionProvider),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: _resetFilters,
                                child: const Text('Reset'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _applyFilters,
                                child: const Text('Apply Filters'),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Member list
          Expanded(
            child: memberProvider.isLoading && memberProvider.members.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : memberProvider.members.isEmpty
                    ? const Center(
                        child: Text('No members found'),
                      )
                    : isDesktop
                        ? _buildMemberTable(memberProvider, regionProvider, currentUser)
                        : _buildMemberList(memberProvider, regionProvider, currentUser),
          ),
          
          // Loading indicator for pagination
          if (memberProvider.isLoading && memberProvider.members.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _statusFilter,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'active',
          child: Text('Active'),
        ),
        DropdownMenuItem(
          value: 'inactive',
          child: Text('Inactive'),
        ),
        DropdownMenuItem(
          value: 'pending',
          child: Text('Pending'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _statusFilter = value;
        });
      },
      hint: const Text('All Statuses'),
    );
  }

  Widget _buildGenderFilter() {
    return DropdownButtonFormField<String>(
      value: _genderFilter,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'female',
          child: Text('Female'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _genderFilter = value;
        });
      },
      hint: const Text('All Genders'),
    );
  }

  Widget _buildProvinceFilter(RegionProvider regionProvider) {
    return DropdownButtonFormField<int>(
      value: _provinceIdFilter,
      decoration: InputDecoration(
        labelText: 'Province',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: regionProvider.provinces.map((province) {
        return DropdownMenuItem(
          value: province.id,
          child: Text(province.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _provinceIdFilter = value;
          _cityIdFilter = null;
          _districtIdFilter = null;
        });
      },
      hint: const Text('All Provinces'),
    );
  }

  Widget _buildCityFilter(RegionProvider regionProvider) {
    final cities = _provinceIdFilter != null
        ? regionProvider.getCitiesByProvinceId(_provinceIdFilter!)
        : [];

    return DropdownButtonFormField<int>(
      value: _cityIdFilter,
      decoration: InputDecoration(
        labelText: 'City',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: cities.map((city) {
        return DropdownMenuItem<int>(
          value: city.id,
          child: Text(city.name),
        );
      }).toList(),
      onChanged: _provinceIdFilter != null
          ? (value) {
              setState(() {
                _cityIdFilter = value;
                _districtIdFilter = null;
              });
            }
          : null,
      hint: const Text('All Cities'),
    );
  }

  Widget _buildDistrictFilter(RegionProvider regionProvider) {
    final districts = _cityIdFilter != null
        ? regionProvider.getDistrictsByCityId(_cityIdFilter!)
        : [];

    return DropdownButtonFormField<int>(
      value: _districtIdFilter,
      decoration: InputDecoration(
        labelText: 'District',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: districts.map((district) {
        return DropdownMenuItem<int>(
          value: district.id,
          child: Text(district.name),
        );
      }).toList(),
      onChanged: _cityIdFilter != null
          ? (value) {
              setState(() {
                _districtIdFilter = value;
              });
            }
          : null,
      hint: const Text('All Districts'),
    );
  }

  Widget _buildMemberTable(
    MemberProvider memberProvider,
    RegionProvider regionProvider,
    User? currentUser,
  ) {
    return Card(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('KTA Number')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('NIK')),
            DataColumn(label: Text('Gender')),
            DataColumn(label: Text('Region')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: memberProvider.members.map((member) {
            return DataRow(
              cells: [
                DataCell(Text(member.ktaNumber)),
                DataCell(Text(member.name)),
                DataCell(Text(member.nik)),
                DataCell(Text(member.gender)),
                DataCell(Text(
                  regionProvider.getProvinceNameById(member.provinceId),
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: member.status == 'active'
                          ? Colors.green.withOpacity(0.2)
                          : member.status == 'inactive'
                              ? Colors.red.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      member.status,
                      style: TextStyle(
                        color: member.status == 'active'
                            ? Colors.green
                            : member.status == 'inactive'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _navigateToMemberDetail(member),
                        tooltip: 'View',
                      ),
                      if (currentUser?.canEditMembers == true)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToEditMember(member),
                          tooltip: 'Edit',
                        ),
                      if (currentUser?.canDeleteMembers == true)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteMember(member),
                          tooltip: 'Delete',
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMemberList(
    MemberProvider memberProvider,
    RegionProvider regionProvider,
    User? currentUser,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: memberProvider.members.length,
      itemBuilder: (context, index) {
        final member = memberProvider.members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(member.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KTA: ${member.ktaNumber}'),
                Text('NIK: ${member.nik}'),
                Text(
                  'Region: ${regionProvider.getProvinceNameById(member.provinceId)}',
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: member.status == 'active'
                        ? Colors.green.withOpacity(0.2)
                        : member.status == 'inactive'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    member.status,
                    style: TextStyle(
                      color: member.status == 'active'
                          ? Colors.green
                          : member.status == 'inactive'
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') {
                      _navigateToMemberDetail(member);
                    } else if (value == 'edit' && currentUser?.canEditMembers == true) {
                      _navigateToEditMember(member);
                    } else if (value == 'delete' && currentUser?.canDeleteMembers == true) {
                      _confirmDeleteMember(member);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View'),
                        ],
                      ),
                    ),
                    if (currentUser?.canEditMembers == true)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (currentUser?.canDeleteMembers == true)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () => _navigateToMemberDetail(member),
          ),
        );
      },
    );
  }
}
