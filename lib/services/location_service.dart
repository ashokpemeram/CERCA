import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling location-related operations
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Stream<Position>? _positionStream;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Get location stream for continuous updates
  Stream<Position> getLocationStream() {
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );

    return _positionStream!;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Handle permission request with user-friendly messages
  Future<PermissionResult> handleLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return PermissionResult(
          isGranted: false,
          message: 'Location services are disabled. Please enable them in settings.',
          shouldOpenSettings: true,
        );
      }

      // Check permission
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return PermissionResult(
            isGranted: false,
            message: 'Location permission is required for this app to function.',
            shouldOpenSettings: false,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return PermissionResult(
          isGranted: false,
          message:
              'Location permission is permanently denied. Please enable it in app settings.',
          shouldOpenSettings: true,
        );
      }

      return PermissionResult(
        isGranted: true,
        message: 'Location permission granted',
        shouldOpenSettings: false,
      );
    } catch (e) {
      return PermissionResult(
        isGranted: false,
        message: 'Error requesting location permission: $e',
        shouldOpenSettings: false,
      );
    }
  }
}

/// Result of permission request
class PermissionResult {
  final bool isGranted;
  final String message;
  final bool shouldOpenSettings;

  PermissionResult({
    required this.isGranted,
    required this.message,
    required this.shouldOpenSettings,
  });
}
