import 'package:flutter/material.dart';
import '../models/assessment_result.dart';
import '../services/assessment_service.dart';

/// Manages the state for the disaster risk assessment feature.
class AssessmentProvider extends ChangeNotifier {
  AssessmentProvider({AssessmentService? service})
      : _service = service ?? AssessmentService();

  final AssessmentService _service;

  bool _isLoading = false;
  AssessmentResult? _result;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  AssessmentResult? get result => _result;
  String? get errorMessage => _errorMessage;

  /// Assess risk using GPS coordinates (lat, lon).
  Future<void> assessByCoordinates(
    double latitude,
    double longitude, {
    bool simulate = false,
    String? scenario,
    String? areaId,
  }) async {
    final location = '$latitude,$longitude';
    await _assess(
      location,
      simulate: simulate,
      scenario: scenario,
      areaId: areaId,
    );
  }

  /// Assess risk using a city name string (fallback / manual).
  Future<void> assess(
    String location, {
    bool simulate = false,
    String? scenario,
    String? areaId,
  }) async {
    if (location.trim().isEmpty) {
      _errorMessage = 'Please enter a location.';
      notifyListeners();
      return;
    }
    await _assess(
      location.trim(),
      simulate: simulate,
      scenario: scenario,
      areaId: areaId,
    );
  }

  Future<void> _assess(
    String location, {
    bool simulate = false,
    String? scenario,
    String? areaId,
  }) async {
    _isLoading = true;
    _result = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _service.assessLocation(
        location,
        simulate: simulate,
        scenario: scenario,
        areaId: areaId,
      );
    } catch (e) {
      debugPrint('AssessmentProvider: Error during assessment: $e');
      _errorMessage =
          'Could not reach the disaster system. Make sure the backend is running.\n\nError: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyAssessmentResult(AssessmentResult result) {
    _result = result;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear any previous result.
  void reset() {
    _result = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
