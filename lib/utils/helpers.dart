import 'dart:math';
import 'package:intl/intl.dart';

/// Helper functions for the app
class Helpers {
  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Format based on length
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 3) {
      return cleaned; // Emergency numbers like 100, 101, 102
    }

    return phoneNumber; // Return as-is if format is unknown
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(dateTime);
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  /// Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 3 && cleaned.length <= 15;
  }

  /// Validate coordinates
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Get bearing between two coordinates (in degrees)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLon = _toRadians(lon2 - lon1);
    final double y = sin(dLon) * cos(_toRadians(lat2));
    final double x = cos(_toRadians(lat1)) * sin(_toRadians(lat2)) -
        sin(_toRadians(lat1)) * cos(_toRadians(lat2)) * cos(dLon);

    final double bearing = atan2(y, x);
    return (bearing * 180 / pi + 360) % 360;
  }
}
