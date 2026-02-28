import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'CERCA';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF424242);
  static const Color dangerColor = Color(0xFFD32F2F);
  static const Color safeColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color mediumRiskColor = Color(0xFFFF9800); // Orange for medium-risk zones
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  // SOS Colors
  static const Color sosButtonColor = Color(0xFFB71C1C);
  static const Color sosButtonPressedColor = Color(0xFF7F0000);

  // Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF212121),
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF424242),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF616161),
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF9E9E9E),
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Map Settings
  static const double defaultZoom = 15.0;
  static const double dangerZoneRadius = 500.0; // meters
  static const double safeZoneRadius = 300.0; // meters

  // API Endpoints (Mock)
  static const String baseUrl = 'https://api.cerca.com';
  static const String sosEndpoint = '/api/sos';
  static const String aidRequestEndpoint = '/api/aid-request';
  static const String zonesEndpoint = '/api/zones';

  // Disaster System (FastAPI Agent Backend)
  // For Android emulator: 10.0.2.2 maps to your PC's localhost
  // For physical device: replace with your PC's local IP (e.g. 192.168.x.x)
  // For Windows desktop Flutter: use 'http://localhost:8000'
  static const String disasterSystemUrl = 'http://192.168.55.104:8000';

  // Emergency Contacts
  static const String policeNumber = '100';
  static const String ambulanceNumber = '102';
  static const String fireNumber = '101';
  static const String disasterHelpline = '1078';
  static const String womenHelpline = '1091';

  // Resource Types
  static const List<String> resourceTypes = [
    'Food',
    'Water',
    'Shelter',
    'Medical Aid',
    'Hospital',
    'Rescue',
    'Transportation',
    'Other',
  ];

  // Location Update Interval
  static const Duration locationUpdateInterval = Duration(seconds: 10);

  // Danger Zone Distance Threshold (meters)
  static const double dangerZoneThreshold = 1000.0;
}
