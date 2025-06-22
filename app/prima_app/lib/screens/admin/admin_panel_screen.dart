import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/responsive_layout.dart';
import '../../utils/user_config_loader.dart';
import 'user_form_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _users = []; // This would come from an API in a real app
  List<User> _pendingUsers = []; // This would come from an API in a real app
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load users from the central configuration
      final users = await UserConfigLoader.loadUsers();
      
      // Check if widget is still mounted before updating state
      if (!mounted) return;
      
      setState(() {
        // Filter active and inactive users
        _users = users.where((user) => user.isActive).toList();
        _pendingUsers = users.where((user) => !user.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserFormScreen(isEditing: false),
      ),
    ).then((_) {
      // Refresh the list when returning from add/edit screen
      _loadData();
    });
  }

  void _navigateToEditUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(
          isEditing: true,
          user: user,
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from add/edit screen
      _loadData();
    });
  }

  Future<void> _confirmDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.username}?'),
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
      // In a real app, this would call an API to delete the user
      setState(() {
        _users.removeWhere((u) => u.id == user.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _approveUser(User user) async {
    // In a real app, this would call an API to approve the user
    setState(() {
      _pendingUsers.removeWhere((u) => u.id == user.id);
      _users.add(User(
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        unitKepengurusanId: user.unitKepengurusanId,
        // Mantener compatibilidad con campos legacy
        level: user.level,
        regionCode: user.regionCode,
        isActive: true,
      ));
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Rejection'),
        content: Text('Are you sure you want to reject ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // In a real app, this would call an API to reject the user
      setState(() {
        _pendingUsers.removeWhere((u) => u.id == user.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                'Admin Panel',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (currentUser?.canApproveOperators == true)
                PrimaButton(
                  text: 'Add User',
                  onPressed: _navigateToAddUser,
                  icon: Icons.person_add,
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active Users'),
              Tab(text: 'Pending Approvals'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Active Users Tab
                      isDesktop
                          ? _buildUsersTable(_users, currentUser)
                          : _buildUsersList(_users, currentUser),
                      
                      // Pending Approvals Tab
                      isDesktop
                          ? _buildPendingUsersTable(_pendingUsers, currentUser)
                          : _buildPendingUsersList(_pendingUsers, currentUser),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(List<User> users, User? currentUser) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Level')),
            DataColumn(label: Text('Region')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.username)),
                DataCell(Text(user.email)),
                DataCell(Text(user.role)),
                DataCell(Text(user.level ?? 'N/A')),
                DataCell(Text(user.regionCode ?? 'N/A')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentUser?.canApproveOperators == true) ...[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToEditUser(user),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDeleteUser(user),
                          tooltip: 'Delete',
                        ),
                      ],
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

  Widget _buildUsersList(List<User> users, User? currentUser) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(user.username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Text('${user.role} - ${user.level ?? 'N/A'}'),
              ],
            ),
            trailing: currentUser?.canApproveOperators == true
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToEditUser(user);
                      } else if (value == 'delete') {
                        _confirmDeleteUser(user);
                      }
                    },
                    itemBuilder: (context) => [
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
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPendingUsersTable(List<User> pendingUsers, User? currentUser) {
    if (pendingUsers.isEmpty) {
      return const Center(child: Text('No pending approvals'));
    }
    
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Level')),
            DataColumn(label: Text('Region')),
            DataColumn(label: Text('Actions')),
          ],
          rows: pendingUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.username)),
                DataCell(Text(user.email)),
                DataCell(Text(user.role)),
                DataCell(Text(user.level ?? 'N/A')),
                DataCell(Text(user.regionCode ?? 'N/A')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentUser?.canApproveOperators == true) ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveUser(user),
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectUser(user),
                          tooltip: 'Reject',
                        ),
                      ],
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

  Widget _buildPendingUsersList(List<User> pendingUsers, User? currentUser) {
    if (pendingUsers.isEmpty) {
      return const Center(child: Text('No pending approvals'));
    }
    
    return ListView.builder(
      itemCount: pendingUsers.length,
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(user.username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                Text('${user.role} - ${user.level ?? 'N/A'}'),
              ],
            ),
            trailing: currentUser?.canApproveOperators == true
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveUser(user),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectUser(user),
                        tooltip: 'Reject',
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
