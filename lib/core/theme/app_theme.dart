import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF115293);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Severity Colors
  static const Color severityLow = Color(0xFF4CAF50);
  static const Color severityMedium = Color(0xFFFFA726);
  static const Color severityHigh = Color(0xFFFF5722);
  static const Color severityCritical = Color(0xFFD32F2F);

  // Overtime Status Colors
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusApproved = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFF44336);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Get theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        error: errorColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 16,
      ),
    );
  }

  // Get severity color
  static Color getSeverityColor(String severity) {
    switch (severity) {
      case 'Low':
        return severityLow;
      case 'Medium':
        return severityMedium;
      case 'High':
        return severityHigh;
      case 'Critical':
        return severityCritical;
      default:
        return textSecondary;
    }
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return statusPending;
      case 'APPROVED':
        return statusApproved;
      case 'REJECTED':
        return statusRejected;
      default:
        return textSecondary;
    }
  }
}
