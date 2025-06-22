import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/app_assets.dart';
import '../config/app_config.dart';
import 'prima_logo.dart';

class PrimaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final User? currentUser;
  final VoidCallback? onLogout;
  final bool showBackButton;

  const PrimaAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.currentUser,
    this.onLogout,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          SizedBox(
            height: 40,
            width: 80,
            child: Center(
              child: Image.asset(
                AppAssets.logoHome,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      backgroundColor: AppConfig.primaryColor,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (actions != null) ...actions!,
        if (currentUser != null) _buildUserMenu(context),
      ],
      elevation: 2,
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'logout' && onLogout != null) {
          onLogout!();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser?.username ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                currentUser?.email ?? '',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${currentUser?.role} - ${currentUser?.level}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.account_circle),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
