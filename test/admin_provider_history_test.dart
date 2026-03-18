import 'dart:convert';

import 'package:CERCA/models/assessment_result.dart';
import 'package:CERCA/providers/admin_provider.dart';
import 'package:CERCA/providers/assessment_provider.dart';
import 'package:CERCA/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'test_helpers/sample_incident.dart';

void main() {
  test(
    'closeArea archives the active session and stores returned history',
    () async {
      final area = buildSampleArea();
      final session = buildSampleIncident();
      Map<String, dynamic>? capturedArchiveBody;

      final apiClient = MockClient((request) async {
        if (request.url.path.endsWith('/admin/history')) {
          return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
        }

        if (request.url.path.endsWith('/simulation/active')) {
          return http.Response(
            jsonEncode({
              'message': 'No active simulation for this area.',
              'session': null,
              'area': area.toJson(),
            }),
            200,
          );
        }

        if (request.url.path.contains('/live-weather/')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'area_id': area.id,
              'risk_level': 'high',
              'condition': 'Clear',
              'readings': [
                {
                  'type': 'Temperature',
                  'value': 30,
                  'unit': 'C',
                  'trend': 'stable',
                  'timestamp': DateTime(2026, 3, 18, 10, 2).toIso8601String(),
                },
              ],
              'timestamp': DateTime(2026, 3, 18, 10, 2).toIso8601String(),
            }),
            200,
          );
        }

        if (request.url.path.endsWith('/archive-close')) {
          capturedArchiveBody =
              jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'message': 'Area closed and archived successfully.',
              'area': area
                  .copyWith(
                    isActive: false,
                    closedAt: DateTime(2026, 3, 18, 12, 30),
                  )
                  .toJson(),
              'incident': {
                ...capturedArchiveBody!,
                'id': 'INC-ARCHIVE-1',
                'status': 'resolved',
                'closedAt': DateTime(2026, 3, 18, 12, 30).toIso8601String(),
                'area': {
                  ...(capturedArchiveBody!['area'] as Map<String, dynamic>),
                  'closedAt': DateTime(2026, 3, 18, 12, 30).toIso8601String(),
                },
              },
            }),
            200,
          );
        }

        return http.Response('Not found', 404);
      });

      final assessmentProvider = AssessmentProvider();
      assessmentProvider.applyAssessmentResult(
        AssessmentResult(
          location: '${area.centerLat},${area.centerLon}',
          overallRisk: 'high',
          alertMessage: 'Demo alert',
          weatherCondition: 'Clear',
          weatherRiskLevel: 'high',
        ),
      );

      final provider = AdminProvider(
        assessmentProvider: assessmentProvider,
        apiService: ApiService.withClient(apiClient),
      );

      provider.overrideAreasForTesting(active: [area]);
      expect(provider.loginToArea('admin@example.com', area.id), isTrue);
      await Future<void>.delayed(Duration.zero);

      provider.seedAreaSessionStateForTesting(
        sosRequests: session.sosLogs,
        aidRequests: session.aidLogs,
        safeCamps: session.safeCamps,
        communicationLogs: session.communicationLogs,
        weatherHistory: session.weatherHistory,
        decisionHistory: session.decisionHistory,
        aiSuggestions: {
          'ambulances': 12,
          'boats': 8,
          'foodPackets': 5000,
          'medicalKits': 200,
        },
        activeSimulation: buildSampleSimulation(),
      );

      final response = await provider.closeArea(area.id);

      expect(response.success, isTrue);
      expect(capturedArchiveBody, isNotNull);
      expect(capturedArchiveBody!['areaId'], isNull);
      expect(capturedArchiveBody!['totalSosLogs'], 1);
      expect(capturedArchiveBody!['totalAidRequests'], 1);
      expect(capturedArchiveBody!['safeCampCount'], 1);
      expect(capturedArchiveBody!['wasSimulation'], isTrue);
      expect(provider.incidentHistory, hasLength(1));
      expect(provider.incidentHistory.first.id, 'INC-ARCHIVE-1');
      expect(provider.archivedAreas, hasLength(1));
      expect(provider.activeAreas, isEmpty);

      provider.dispose();
    },
  );
}
