import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/prima_app_bar.dart';
import '../../widgets/responsive_layout.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import '../members/member_list_screen.dart';
import '../admin/admin_panel_screen.dart';
import '../kepengurusan/kepengurusan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initAuth();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? currentUser = authProvider.currentUser;
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    
    // If not authenticated, redirect to login
    if (!authProvider.isAuthenticated && !authProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
    }
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Define screens based on user role
    final List<Widget> screens = [
      const DashboardScreen(), // Dashboard for all users
      const MemberListScreen(), // Member management
      const KepengurusanScreen(), // Struktur Kepengurusan
      if (currentUser?.isAdmin == true || currentUser?.isOperator == true)
        const AdminPanelScreen(), // Admin panel for admin/operator
    ];

    // Define navigation items based on user role
    final List<NavigationDestination> navigationDestinations = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people),
        label: 'Members',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_tree),
        label: 'Kepengurusan',
      ),
      if (currentUser?.isAdmin == true || currentUser?.isOperator == true)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    // Define drawer items for mobile view
    final List<Widget> drawerItems = [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              currentUser?.username ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              '${currentUser?.role} - ${currentUser?.level}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        selected: _selectedIndex == 0,
        onTap: () {
          _onItemTapped(0);
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.people),
        title: const Text('Members'),
        selected: _selectedIndex == 1,
        onTap: () {
          _onItemTapped(1);
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.account_tree),
        title: const Text('Kepengurusan'),
        selected: _selectedIndex == 2,
        onTap: () {
          _onItemTapped(2);
          Navigator.pop(context);
        },
      ),
      if (currentUser?.isAdmin == true || currentUser?.isOperator == true)
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Admin'),
          selected: _selectedIndex == 3,
          onTap: () {
            _onItemTapped(3);
            Navigator.pop(context);
          },
        ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: _logout,
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: PrimaAppBar(
        title: 'PRIMA ID',
        currentUser: currentUser,
        onLogout: _logout,
        actions: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: ListView(children: drawerItems)),
      body: Row(
        children: [
          // Side navigation for desktop
          if (isDesktop)
            NavigationRail(
              extended: true,
              destinations: navigationDestinations
                  .map((destination) => NavigationRailDestination(
                        icon: destination.icon,
                        label: Text(destination.label),
                      ))
                  .toList(),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
          // Main content
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
      // Bottom navigation for mobile/tablet
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              destinations: navigationDestinations,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
    );
  }
}
