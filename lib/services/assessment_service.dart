import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assessment_result.dart';
import '../utils/constants.dart';

/// Service that calls the disaster_system FastAPI backend's POST /assess endpoint.
class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  /// Assess disaster risk for a given [location] (city name).
  /// Returns [AssessmentResult] on success, throws on failure.
  Future<AssessmentResult> assessLocation(String location) async {
    final uri = Uri.parse('${AppConstants.disasterSystemUrl}/assess');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'location': location}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AssessmentResult.fromJson(json);
    } else {
      throw Exception(
        'Backend returned status ${response.statusCode}: ${response.body}',
      );
    }
  }
}
