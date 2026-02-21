import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

/// Provider for location state management
class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermission = false;
  bool _isServiceEnabled = false;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermission => _hasPermission;
  bool get isServiceEnabled => _isServiceEnabled;

  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;

  /// Initialize location services
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Handle permission
      final permissionResult = await _locationService.handleLocationPermission();

      if (!permissionResult.isGranted) {
        _hasPermission = false;
        _errorMessage = permissionResult.message;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _hasPermission = true;
      _isServiceEnabled = await _locationService.isLocationServiceEnabled();

      // Get current location
      await updateLocation();

      // Start listening to location updates
      startLocationUpdates();
    } catch (e) {
      _errorMessage = 'Error initializing location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update current location
  Future<void> updateLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Error updating location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start listening to location updates
  void startLocationUpdates() {
    _locationService.getLocationStream().listen(
      (Position position) {
        _currentPosition = position;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error receiving location updates: $error';
        notifyListeners();
      },
    );
  }

  /// Request permission again
  Future<void> requestPermission() async {
    final permissionResult = await _locationService.handleLocationPermission();

    if (permissionResult.isGranted) {
      _hasPermission = true;
      _errorMessage = null;
      await initialize();
    } else {
      _hasPermission = false;
      _errorMessage = permissionResult.message;
      notifyListeners();
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
