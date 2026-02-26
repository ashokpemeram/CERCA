import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result returned by [SimulationService.triggerSimulation].
class SimulationResult {
  final bool success;
  final String disasterType;
  final String? severity;
  final int? affectedCount;
  final int? evacuatedCount;
  final String? responseTime;
  final String message;

  const SimulationResult({
    required this.success,
    required this.disasterType,
    this.severity,
    this.affectedCount,
    this.evacuatedCount,
    this.responseTime,
    required this.message,
  });

  /// Parse from a JSON map returned by the FastAPI `/simulate` endpoint.
  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      success: json['success'] as bool? ?? true,
      disasterType: json['disaster_type'] as String? ?? '',
      severity: json['severity'] as String?,
      affectedCount: json['affected_count'] as int?,
      evacuatedCount: json['evacuated_count'] as int?,
      responseTime: json['response_time'] as String?,
      message: json['message'] as String? ?? 'Simulation started',
    );
  }

  /// Fallback result used when the API is unreachable or returns an error.
  factory SimulationResult.fallback(String disasterType) {
    return SimulationResult(
      success: false,
      disasterType: disasterType,
      message: 'API unavailable – using offline data',
    );
  }
}

/// Service responsible for triggering a disaster simulation on the FastAPI backend.
///
/// The base URL must point to the FastAPI server. When using an Android emulator,
/// `10.0.2.2` routes to the host machine's localhost. Change [baseUrl] to match
/// your actual server address (e.g. `http://192.168.1.10:8000` for a device on
/// the same network, or a deployed URL for production).
///
/// Expected FastAPI endpoint:
/// ```
/// POST /simulate
/// Content-Type: application/json
/// Body: { "disaster_type": "Coastal Flood" }
///
/// Response 200:
/// {
///   "success": true,
///   "disaster_type": "Coastal Flood",
///   "severity": "critical",
///   "affected_count": 12000,
///   "evacuated_count": 8000,
///   "response_time": "30 minutes",
///   "message": "Simulation initiated"
/// }
/// ```
class SimulationService {
  SimulationService._internal();
  static final SimulationService _instance = SimulationService._internal();
  factory SimulationService() => _instance;

  /// Base URL of the FastAPI server.
  /// Change this to match your deployment environment.
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// POST /simulate with the given [disasterType].
  ///
  /// Returns a [SimulationResult] with `success == true` when the API responds
  /// correctly, or a fallback result when the server is unreachable or returns
  /// an error – ensuring the app never crashes regardless of server state.
  Future<SimulationResult> triggerSimulation(String disasterType) async {
    try {
      final uri = Uri.parse('$baseUrl/simulate');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'disaster_type': disasterType}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SimulationResult.fromJson(data);
      } else {
        // Server returned an error status
        return SimulationResult(
          success: false,
          disasterType: disasterType,
          message: 'Server error ${response.statusCode} – using offline data',
        );
      }
    } catch (e) {
      // Network unavailable, timeout, JSON parse error, etc.
      return SimulationResult.fallback(disasterType);
    }
  }
}
