import '../models/aid_request.dart';

/// Service for API communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Note: this service currently returns mocked responses.

  /// Send SOS alert
  Future<ApiResponse<Map<String, dynamic>>> sendSosAlert({
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful response
      return ApiResponse(
        success: true,
        data: {
          'id': 'sos_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'sent',
          'timestamp': DateTime.now().toIso8601String(),
          'latitude': latitude,
          'longitude': longitude,
          'message': message ?? 'Emergency SOS alert',
        },
        message: 'SOS alert sent successfully',
      );

      // Actual implementation would be:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl${AppConstants.sosEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: jsonDecode(response.body),
          message: 'SOS alert sent successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to send SOS alert: ${response.statusCode}',
        );
      }
      */
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error sending SOS alert: $e',
      );
    }
  }

  /// Submit aid request
  Future<ApiResponse<AidRequest>> submitAidRequest(AidRequest request) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful response
      final requestWithId = request.copyWith(
        id: 'aid_${DateTime.now().millisecondsSinceEpoch}',
        status: 'submitted',
      );

      return ApiResponse(
        success: true,
        data: requestWithId,
        message: 'Aid request submitted successfully',
      );

      // Actual implementation would be:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl${AppConstants.aidRequestEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: AidRequest.fromJson(data),
          message: 'Aid request submitted successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to submit aid request: ${response.statusCode}',
        );
      }
      */
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error submitting aid request: $e',
      );
    }
  }

  /// Fetch zones (danger and safe zones)
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchZones({
    double? latitude,
    double? longitude,
    double? radiusInKm,
  }) async {
    try {
      // Mock implementation - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Use provided coordinates or default to Delhi
      final centerLat = latitude ?? 28.6139;
      final centerLon = longitude ?? 77.2090;

      // Return mock zones data positioned around user's location
      return ApiResponse(
        success: true,
        data: _getMockZones(centerLat, centerLon),
        message: 'Zones fetched successfully',
      );

      // Actual implementation would be:
      /*
      final queryParams = {
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        if (radiusInKm != null) 'radius': radiusInKm.toString(),
      };

      final uri = Uri.parse('$_baseUrl${AppConstants.zonesEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: data.cast<Map<String, dynamic>>(),
          message: 'Zones fetched successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to fetch zones: ${response.statusCode}',
        );
      }
      */
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error fetching zones: $e',
      );
    }
  }

  /// Mock zones data - matches reference image layout
  /// Positions zones around the provided center coordinates
  List<Map<String, dynamic>> _getMockZones(double centerLat, double centerLon) {
    return [
      // High-Intensity Red Zone (user is in the center of this)
      {
        'id': 'red_zone_1',
        'name': 'Red Zone',
        'latitude': centerLat,
        'longitude': centerLon,
        'radiusInMeters': 600.0, // Large red circle
        'type': 'danger',
        'intensity': 'high',
        'description': 'High-intensity danger zone',
      },
      
      // Medium-Risk Orange Zone (overlapping on the right side)
      {
        'id': 'orange_zone_1',
        'name': 'Orange Zone',
        'latitude': centerLat + 0.003, // Offset to the right
        'longitude': centerLon + 0.005,
        'radiusInMeters': 550.0, // Large orange circle
        'type': 'danger',
        'intensity': 'medium',
        'description': 'Medium-risk zone - exercise caution',
      },
      
      // Safe Camp 1 - Top (above the zones)
      {
        'id': 'safe_camp_top',
        'name': 'Safe Camp',
        'latitude': centerLat + 0.008, // North of center
        'longitude': centerLon + 0.002,
        'radiusInMeters': 0.0, // Point marker only
        'type': 'safeCamp',
        'description': 'Emergency relief camp with supplies',
      },
      
      // Safe Camp 2 - Bottom Left
      {
        'id': 'safe_camp_bottom_left',
        'name': 'Safe Camp',
        'latitude': centerLat - 0.007, // South-west of center
        'longitude': centerLon - 0.004,
        'radiusInMeters': 0.0,
        'type': 'safeCamp',
        'description': 'Safe shelter with medical facilities',
      },
      
      // Safe Camp 3 - Bottom Right
      {
        'id': 'safe_camp_bottom_right',
        'name': 'Safe Camp',
        'latitude': centerLat - 0.006, // South-east of center
        'longitude': centerLon + 0.008,
        'radiusInMeters': 0.0,
        'type': 'safeCamp',
        'description': 'Community gathering point',
      },
    ];
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });
}
