import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assessment_result.dart';
import '../utils/constants.dart';

/// Service that calls the disaster_system FastAPI backend's POST /assess endpoint.
class AssessmentService {
  AssessmentService._internal({http.Client? client})
      : _client = client ?? http.Client();

  static final AssessmentService _instance = AssessmentService._internal();

  factory AssessmentService() => _instance;

  factory AssessmentService.withClient(http.Client client) =>
      AssessmentService._internal(client: client);

  final http.Client _client;

  /// Assess disaster risk for a given [location].
  /// Returns [AssessmentResult] on success, throws on failure.
  Future<AssessmentResult> assessLocation(
    String location, {
    bool simulate = false,
    String? scenario,
    String? areaId,
  }) async {
    final uri = Uri.parse('${AppConstants.disasterSystemUrl}/assess');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'location': location,
            'simulate': simulate,
            'scenario': scenario,
            'areaId': areaId,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AssessmentResult.fromJson(json);
    }

    throw Exception(
      'Backend returned status ${response.statusCode}: ${response.body}',
    );
  }
}
