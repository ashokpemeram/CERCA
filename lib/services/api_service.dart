import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aid_request.dart';
import '../models/admin/aid_request_admin.dart';
import '../models/admin/sos_request.dart';
import '../models/admin/disaster_area.dart';
import '../utils/constants.dart';

/// Service for API communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;
  final String _disasterBaseUrl = AppConstants.disasterSystemUrl;

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

  /// Submit SOS request to backend
  Future<ApiResponse<SosRequest>> submitSosRequest(SosRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_disasterBaseUrl${AppConstants.sosRequestsEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: SosRequest.fromJson(data),
          message: 'SOS alert sent successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: 'Failed to send SOS alert: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error sending SOS alert: $e',
      );
    }
  }

  /// Fetch SOS requests filtered by area id
  Future<ApiResponse<List<SosRequest>>> fetchSosRequestsForArea(
    String areaId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_disasterBaseUrl${AppConstants.sosRequestsEndpoint}',
      ).replace(
        queryParameters: {'area_id': areaId},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final items = data
            .map(
              (item) => SosRequest.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

        return ApiResponse(
          success: true,
          data: items,
          message: 'SOS requests fetched successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: 'Failed to fetch SOS requests: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error fetching SOS requests: $e',
      );
    }
  }

  /// Fetch active disaster areas from backend
  Future<ApiResponse<List<DisasterArea>>> fetchActiveAreas() async {
    try {
      final uri = Uri.parse(
        '$_disasterBaseUrl${AppConstants.areasEndpoint}',
      ).replace(
        queryParameters: {'active': 'true'},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final items = data
            .map(
              (item) => DisasterArea.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

        return ApiResponse(
          success: true,
          data: items,
          message: 'Areas fetched successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: 'Failed to fetch areas: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error fetching areas: $e',
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

  /// Submit aid request with area assignment for admin view
  Future<ApiResponse<AidRequestAdmin>> submitAidRequestAdmin(
    AidRequestAdmin request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_disasterBaseUrl${AppConstants.aidRequestsEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: AidRequestAdmin.fromJson(data),
          message: 'Aid request submitted successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: 'Failed to submit aid request: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error submitting aid request: $e',
      );
    }
  }

  /// Fetch aid requests filtered by area id
  Future<ApiResponse<List<AidRequestAdmin>>> fetchAidRequestsForArea(
    String areaId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_disasterBaseUrl${AppConstants.aidRequestsEndpoint}',
      ).replace(
        queryParameters: {'area_id': areaId},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final items = data
            .map(
              (item) => AidRequestAdmin.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

        return ApiResponse(
          success: true,
          data: items,
          message: 'Aid requests fetched successfully',
        );
      }

      return ApiResponse(
        success: false,
        message: 'Failed to fetch aid requests: ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error fetching aid requests: $e',
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

/// Define sensor reading response structure
class WeatherSensorResponse {
  final bool success;
  final String areaId;
  final String riskLevel;
  final String condition;
  final List<Map<String, dynamic>> readings;
  final String? timestamp;

  WeatherSensorResponse({
    required this.success,
    required this.areaId,
    required this.riskLevel,
    required this.condition,
    required this.readings,
    this.timestamp,
  });

  factory WeatherSensorResponse.fromJson(Map<String, dynamic> json) {
    return WeatherSensorResponse(
      success: json['success'] ?? false,
      areaId: json['area_id'] ?? '',
      riskLevel: json['risk_level'] ?? 'unknown',
      condition: json['condition'] ?? 'Unknown',
      readings: List<Map<String, dynamic>>.from(
        (json['readings'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      ),
      timestamp: json['timestamp'],
    );
  }
}

/// Extend ApiService to add live weather endpoint
extension WeatherEndpoint on ApiService {
  /// Fetch live weather sensor readings for a specific area with coordinates
  Future<ApiResponse<List<Map<String, dynamic>>>> fetchLiveWeatherReadings(
    String areaId, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Build URL with coordinates for more accurate weather
      String url = '${AppConstants.disasterSystemUrl}/live-weather/$areaId';
      
      if (latitude != null && longitude != null) {
        url += '?lat=$latitude&lon=$longitude';
      }

      print('ApiService: Fetching weather from $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = WeatherSensorResponse.fromJson(jsonDecode(response.body));
        
        if (data.success && data.readings.isNotEmpty) {
          return ApiResponse(
            success: true,
            data: data.readings,
            message: 'Live weather readings fetched successfully',
          );
        } else {
          // Fallback to mock data if no readings found
          return ApiResponse(
            success: true,
            data: _getMockWeatherReadings(),
            message: 'Using mock weather data (no live data available)',
          );
        }
      } else {
        // Fallback to mock data on error
        return ApiResponse(
          success: true,
          data: _getMockWeatherReadings(),
          message: 'Using mock weather data (backend unavailable)',
        );
      }
    } catch (e) {
      // Fallback to mock data on error
      return ApiResponse(
        success: true,
        data: _getMockWeatherReadings(),
        message: 'Using mock weather data (error: $e)',
      );
    }
  }

  /// Get mock weather readings as fallback
  List<Map<String, dynamic>> _getMockWeatherReadings() {
    final now = DateTime.now();
    return [
      {
        'type': 'Temperature',
        'value': 28,
        'unit': '°C',
        'trend': 'down',
        'timestamp': now.toIso8601String(),
      },
      {
        'type': 'Wind Speed',
        'value': 45,
        'unit': 'km/h',
        'trend': 'stable',
        'timestamp': now.toIso8601String(),
      },
      {
        'type': 'Humidity',
        'value': 72,
        'unit': '%',
        'trend': 'up',
        'timestamp': now.toIso8601String(),
      },
      {
        'type': 'Rainfall',
        'value': 5,
        'unit': 'mm',
        'trend': 'up',
        'timestamp': now.toIso8601String(),
      },
    ];
  }
}
