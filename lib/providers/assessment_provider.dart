import 'package:flutter/material.dart';
import '../models/assessment_result.dart';
import '../services/assessment_service.dart';

/// Manages the state for the disaster risk assessment feature.
class AssessmentProvider extends ChangeNotifier {
  final _service = AssessmentService();

  bool _isLoading = false;
  AssessmentResult? _result;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  AssessmentResult? get result => _result;
  String? get errorMessage => _errorMessage;

  /// Assess risk using GPS coordinates (lat, lon).
  /// WeatherAPI accepts "lat,lon" directly as a query value.
  Future<void> assessByCoordinates(double latitude, double longitude) async {
    final location = '$latitude,$longitude';
    await _assess(location);
  }

  /// Assess risk using a city name string (fallback / manual).
  Future<void> assess(String location) async {
    if (location.trim().isEmpty) {
      _errorMessage = 'Please enter a location.';
      notifyListeners();
      return;
    }
    await _assess(location.trim());
  }

  Future<void> _assess(String location) async {
    _isLoading = true;
    _result = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _service.assessLocation(location);
    } catch (e) {
      _errorMessage =
          'Could not reach the disaster system. Make sure the backend is running.\n\nError: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any previous result.
  void reset() {
    _result = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
