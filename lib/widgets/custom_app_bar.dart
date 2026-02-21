import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Custom AppBar widget used across all screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAdminPressed;

  const CustomAppBar({
    super.key,
    this.onAdminPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 2,
      title: Row(
        children: [
          // App Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield,
              color: AppConstants.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          // App Name
          const Text(
            AppConstants.appName,
            style: AppConstants.appBarTitleStyle,
          ),
        ],
      ),
      actions: [
        // Admin Button
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton.icon(
            onPressed: onAdminPressed,
            icon: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
            ),
            label: const Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
