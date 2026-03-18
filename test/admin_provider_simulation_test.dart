import 'dart:convert';

import 'package:CERCA/models/admin/disaster_area.dart';
import 'package:CERCA/models/admin/disaster_event.dart';
import 'package:CERCA/providers/admin_provider.dart';
import 'package:CERCA/providers/assessment_provider.dart';
import 'package:CERCA/services/api_service.dart';
import 'package:CERCA/services/assessment_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

DisasterArea _area({
  double redRadiusM = 300,
  double warningRadiusM = 600,
  double greenRadiusM = 900,
  double controllableRadiusM = 1200,
}) {
  return DisasterArea(
    id: 'AREA-20260318-TEST',
    centerLat: 12.9716,
    centerLon: 77.5946,
    redRadiusM: redRadiusM,
    warningRadiusM: warningRadiusM,
    greenRadiusM: greenRadiusM,
    controllableRadiusM: controllableRadiusM,
    createdAt: DateTime(2026, 3, 18, 12),
  );
}

Map<String, dynamic> _weatherPayload() {
  return {
    'success': true,
    'area_id': 'AREA-20260318-TEST',
    'risk_level': 'high',
    'condition': 'Clear',
    'readings': [
      {
        'type': 'Temperature',
        'value': 30,
        'unit': 'C',
        'trend': 'stable',
        'timestamp': DateTime(2026, 3, 18, 12).toIso8601String(),
      },
    ],
  };
}

void main() {
  group('Admin simulation flow', () {
    test(
      'start and stop use backend simulation endpoints and apply returned assessment',
      () async {
        final capturedPaths = <String>[];
        Map<String, dynamic>? capturedStartBody;

        final apiClient = MockClient((request) async {
          capturedPaths.add(request.url.path);

          if (request.url.path.endsWith('/simulation/start')) {
            capturedStartBody =
                jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response(
              jsonEncode({
                'message': 'Simulation started successfully.',
                'session': {
                  'id': 'SIM-20260318120000-ABCD',
                  'areaId': 'AREA-20260318-TEST',
                  'isActive': true,
                  'disasterType': 'Flood',
                  'severity': 'high',
                  'centerLat': 12.9716,
                  'centerLon': 77.5946,
                  'radiusM': 1800.0,
                  'startedAt': DateTime(2026, 3, 18, 12).toIso8601String(),
                  'totalCitizens': 5,
                },
                'area': {
                  ..._area(
                    redRadiusM: 1800,
                    warningRadiusM: 2200,
                    greenRadiusM: 2600,
                    controllableRadiusM: 3200,
                  ).toJson(),
                },
                'assessment': {
                  'alert_message': 'Demo alert',
                  'sms_status': {
                    'status': 'sent',
                    'detail': 'SMS alert sent successfully to +15550000000.',
                    'recipient': '+15550000000',
                  },
                  'risk': {
                    'location': '12.9716,77.5946',
                    'overall_risk': 'high',
                    'weather': {
                      'risk_level': 'high',
                      'raw_data': {
                        'current': {
                          'temp_c': 30,
                          'wind_kph': 10,
                          'condition': {'text': 'Clear'},
                        },
                      },
                    },
                    'news': {'risk_level': 'low', 'events': <String>[]},
                  },
                },
              }),
              200,
            );
          }

          if (request.url.path.endsWith('/simulation/stop')) {
            return http.Response(
              jsonEncode({
                'message': 'Simulation stopped successfully.',
                'session': {
                  'id': 'SIM-20260318120000-ABCD',
                  'areaId': 'AREA-20260318-TEST',
                  'isActive': false,
                  'disasterType': 'Flood',
                  'severity': 'high',
                  'centerLat': 12.9716,
                  'centerLon': 77.5946,
                  'radiusM': 1800.0,
                  'startedAt': DateTime(2026, 3, 18, 12).toIso8601String(),
                  'totalCitizens': 5,
                },
                'area': _area().toJson(),
              }),
              200,
            );
          }

          if (request.url.path.endsWith('/simulation/active')) {
            return http.Response(
              jsonEncode({
                'message': 'No active simulation for this area.',
                'session': null,
                'area': _area().toJson(),
              }),
              200,
            );
          }

          if (request.url.path.contains('/live-weather/')) {
            return http.Response(jsonEncode(_weatherPayload()), 200);
          }

          return http.Response('Not found', 404);
        });

        final assessmentProvider = AssessmentProvider(
          service: AssessmentService.withClient(
            MockClient(
              (request) async => throw StateError(
                'Admin simulation should not call /assess directly.',
              ),
            ),
          ),
        );
        final provider = AdminProvider(
          assessmentProvider: assessmentProvider,
          apiService: ApiService.withClient(apiClient),
        );

        provider.overrideAreasForTesting(active: [_area()]);
        expect(
          provider.loginToArea('admin@example.com', 'AREA-20260318-TEST'),
          isTrue,
        );
        await Future<void>.delayed(Duration.zero);

        final startResponse = await provider.startDisasterSimulation(
          type: 'Flood',
          centerLat: 12.9716,
          centerLon: 77.5946,
          radiusM: 1800,
          severity: DisasterSeverity.high,
          totalCitizens: 5,
          interval: const Duration(minutes: 1),
        );

        expect(startResponse.success, isTrue);
        expect(capturedStartBody, isNotNull);
        expect(capturedStartBody!.containsKey('simulate'), isFalse);
        expect(
          capturedPaths.where((path) => path.endsWith('/simulation/start')),
          isNotEmpty,
        );
        expect(
          capturedPaths.where((path) => path.endsWith('/assess')),
          isEmpty,
        );
        expect(provider.activeSimulation?.areaId, 'AREA-20260318-TEST');
        expect(assessmentProvider.result?.overallRisk, 'high');
        expect(provider.lastSimulationSmsStatus?.status, 'sent');
        expect(provider.lastSimulationSmsStatus?.recipient, '+15550000000');
        expect(provider.currentArea?.redRadiusM, 1800);

        final stopResponse = await provider.stopSimulation();
        expect(stopResponse.success, isTrue);
        expect(provider.activeSimulation, isNull);
        expect(provider.currentArea?.redRadiusM, 300);

        provider.dispose();
      },
    );

    test(
      'restoreSimulationForCurrentArea rehydrates backend session',
      () async {
        final apiClient = MockClient((request) async {
          if (request.url.path.endsWith('/simulation/active')) {
            return http.Response(
              jsonEncode({
                'message': 'Active simulation fetched successfully.',
                'session': {
                  'id': 'SIM-20260318121000-EFGH',
                  'areaId': 'AREA-20260318-TEST',
                  'isActive': true,
                  'disasterType': 'Cyclone',
                  'severity': 'medium',
                  'centerLat': 12.9716,
                  'centerLon': 77.5946,
                  'radiusM': 1400.0,
                  'startedAt': DateTime(2026, 3, 18, 12, 10).toIso8601String(),
                  'totalCitizens': 0,
                },
                'area': _area(
                  redRadiusM: 770,
                  warningRadiusM: 1400,
                  greenRadiusM: 1750,
                  controllableRadiusM: 2240,
                ).toJson(),
              }),
              200,
            );
          }

          if (request.url.path.contains('/live-weather/')) {
            return http.Response(jsonEncode(_weatherPayload()), 200);
          }

          return http.Response('Not found', 404);
        });

        final provider = AdminProvider(
          apiService: ApiService.withClient(apiClient),
        );
        provider.overrideAreasForTesting(active: [_area()]);
        expect(
          provider.loginToArea('admin@example.com', 'AREA-20260318-TEST'),
          isTrue,
        );

        await provider.restoreSimulationForCurrentArea();

        expect(provider.activeSimulation, isNotNull);
        expect(provider.activeSimulation?.type, 'Cyclone');
        expect(provider.activeSimulation?.severity, DisasterSeverity.medium);
        expect(provider.currentArea?.warningRadiusM, 1400);
        expect(provider.systemStatus, SystemStatus.critical);

        provider.dispose();
      },
    );
  });
}
