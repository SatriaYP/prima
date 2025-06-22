import 'package:flutter/material.dart';
import '../config/app_assets.dart';
import '../config/app_config.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isExpanded;

  const DashboardSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(icon: Icons.person, label: 'Profil'),
      _MenuItem(icon: Icons.people, label: 'Keanggotaan'),
      _MenuItem(icon: Icons.account_tree, label: 'Kepengurusan'),
      _MenuItem(icon: Icons.business, label: 'Kantor'),
      _MenuItem(icon: Icons.article, label: 'Kesekretariatan'),
      _MenuItem(icon: Icons.help, label: 'Bantuan'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 250 : 70,
      color: AppConfig.primaryColor,
      child: Column(
        children: [
          // Logo section
          Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isExpanded
                ? Image.asset(
                    AppAssets.logoHome,
                    height: 48,
                  )
                : Image.asset(
                    AppAssets.logoFavicon,
                    height: 32,
                  ),
          ),
          const Divider(color: Colors.white24, height: 1),
          
          // Menu items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = index == selectedIndex;
                
                return Container(
                  color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: Colors.white,
                    ),
                    title: isExpanded
                        ? Text(
                            item.label,
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                    minLeadingWidth: 0,
                    selected: isSelected,
                    onTap: () => onItemSelected(index),
                    selectedTileColor: Colors.white.withOpacity(0.1),
                  ),
                );
              },
            ),
          ),
          
          // Version info
          Container(
            padding: const EdgeInsets.all(16),
            alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
            child: isExpanded
                ? const Text(
                    'PRIMA ID v1.0.0',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  )
                : const Icon(
                    Icons.info_outline,
                    color: Colors.white54,
                    size: 16,
                  ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  _MenuItem({required this.icon, required this.label});
}
