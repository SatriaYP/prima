import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Utility class for UI-related helper methods
class UIHelper {
  /// Creates a gradient background using the primary and accent colors
  static BoxDecoration gradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppConfig.primaryColor,
          AppConfig.primaryColor.withOpacity(0.8),
          AppConfig.accentColor.withOpacity(0.8),
          AppConfig.accentColor,
        ],
      ),
    );
  }

  /// Creates a card decoration with shadow and rounded corners
  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Standard spacing values for consistent UI
  static const double spacing_xs = 4.0;
  static const double spacing_sm = 8.0;
  static const double spacing_md = 16.0;
  static const double spacing_lg = 24.0;
  static const double spacing_xl = 32.0;
  static const double spacing_xxl = 48.0;

  /// Standard border radius values
  static const double borderRadius_sm = 4.0;
  static const double borderRadius_md = 8.0;
  static const double borderRadius_lg = 12.0;
  static const double borderRadius_xl = 16.0;
  static const double borderRadius_xxl = 24.0;

  /// Shows a loading indicator dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: spacing_md),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
