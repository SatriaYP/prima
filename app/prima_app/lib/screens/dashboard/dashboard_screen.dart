import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/member_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/region_provider.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/dashboard_filters.dart';
import '../../widgets/member_data_table_widget.dart';
import '../../widgets/dashboard/dashboard_header_widget.dart';
import '../../widgets/dashboard/statistics_cards_widget.dart';
import '../../widgets/dashboard/recent_activities_widget.dart';
import '../../screens/members/member_registration_form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  
  Map<String, dynamic> _statistics = {
    'total_members': 0,
    'gender_distribution': {'male': 0, 'female': 0},
    'regional_distribution': {},
  };
  bool _isLoading = true;
  List<Member>? _members;
  bool _isLoadingMembers = false;
  List<ActivityItem> _recentActivities = [];
  bool _isLoadingActivities = false;
  
  // Filter parameters
  String? _searchQuery;
  String? _provinceFilter;
  String? _cityFilter;
  String? _districtFilter;
  String? _villageFilter;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    // Gunakan Future.microtask untuk menjalankan _loadRegionData setelah build selesai
    Future.microtask(() => _loadRegionData());
    _loadMembers();
    _loadRecentActivities();
  }

  Future<void> _loadStatistics() async {
    try {
      final statistics = await _dashboardService.getStatistics();
      
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _statistics = statistics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    }
  }
  
  Future<void> _loadRegionData() async {
    try {
      await Provider.of<RegionProvider>(context, listen: false).loadRegionData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading region data: $e')),
        );
      }
    }
  }
  
  Future<void> _loadMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });
    
    try {
      final members = await _dashboardService.getMembers(
        searchQuery: _searchQuery,
        provinceFilter: _provinceFilter,
        cityFilter: _cityFilter,
        districtFilter: _districtFilter,
        villageFilter: _villageFilter,
      );
      
      if (mounted) {
        setState(() {
          _members = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading members: $e')),
        );
      }
    }
  }
  
  void _applyFilters(String? search, String? province, String? city, String? district, String? village) {
    setState(() {
      _searchQuery = search;
      _provinceFilter = province;
      _cityFilter = city;
      _districtFilter = district;
      _villageFilter = village;
    });
    
    // In a real app, this would reload members with the new filters
    _loadMembers();
  }
  
  void _resetFilters() {
    setState(() {
      _searchQuery = null;
      _provinceFilter = null;
      _cityFilter = null;
      _districtFilter = null;
      _villageFilter = null;
    });
    
    // In a real app, this would reload members without filters
    _loadMembers();
  }
  
  void _viewMemberDetails(Member member) {
    // Navigate to member details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${member.name}')),
    );
  }
  
  void _editMember(Member member) {
    // Navigate to edit member screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${member.name}')),
    );
  }
  
  void _deleteMember(Member member) {
    // Show confirmation dialog and delete member
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleting ${member.name}')),
    );
  }

  Future<void> _loadRecentActivities() async {
    setState(() {
      _isLoadingActivities = true;
    });
    
    try {
      final activitiesData = await _dashboardService.getRecentActivities();
      
      if (mounted) {
        setState(() {
          _recentActivities = activitiesData.map((activity) {
            IconData icon;
            switch (activity['icon']) {
              case 'person_add':
                icon = Icons.person_add;
                break;
              case 'edit':
                icon = Icons.edit;
                break;
              default:
                icon = Icons.info;
            }
            
            return ActivityItem(
              icon: icon,
              title: activity['title'],
              subtitle: activity['subtitle'],
              timeAgo: activity['time_ago'],
            );
          }).toList();
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingActivities = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activities: $e')),
        );
      }
    }
  }
  
  void _handleDownloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh data...')),
    );
  }
  
  void _handleAddMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MemberRegistrationForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? currentUser = authProvider.currentUser;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and action buttons
            DashboardHeaderWidget(
              currentUser: currentUser,
              onDownloadData: _handleDownloadData,
              onAddMember: _handleAddMember,
            ),
            const SizedBox(height: 24),
            
            // Filters dan Statistics berdampingan
            LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth > 800
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filters section
                          Expanded(
                            flex: 1,
                            child: DashboardFilters(
                              onApplyFilters: _applyFilters,
                              onResetFilters: _resetFilters,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Statistics cards
                          Expanded(
                            flex: 1,
                            child: StatisticsCardsWidget(statistics: _statistics),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Filters section
                          DashboardFilters(
                            onApplyFilters: _applyFilters,
                            onResetFilters: _resetFilters,
                          ),
                          const SizedBox(height: 24),
                          // Statistics cards
                          StatisticsCardsWidget(statistics: _statistics),
                        ],
                      );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Member data table dengan container yang membatasi lebar
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Anggota',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: constraints.maxWidth > 1200 ? constraints.maxWidth - 64 : 1200,
                              child: MemberDataTableWidget(
                                members: _members,
                                currentUser: currentUser,
                                isLoading: _isLoadingMembers,
                                onViewMember: _viewMemberDetails,
                                onEditMember: currentUser?.canEditMembers == true ? _editMember : null,
                                onDeleteMember: currentUser?.canDeleteMembers == true ? _deleteMember : null,
                                showCheckboxColumn: true,
                                showMaritalStatus: false,
                                showUploadHistory: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Recent activities
            RecentActivitiesWidget(activities: _recentActivities),
          ],
        ),
      ),
    );
  }
}
