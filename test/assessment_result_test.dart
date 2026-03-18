import 'package:CERCA/models/assessment_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssessmentResult', () {
    test('captures weather and news reasons for elevated risk', () {
      final result = AssessmentResult.fromJson({
        'alert_message': 'Please stay alert.',
        'risk': {
          'location': 'Test Area',
          'overall_risk': 'high',
          'weather': {
            'risk_level': 'high',
            'indicators': ['heavy_rain', 'strong_wind'],
            'raw_data': {
              'current': {
                'temp_c': 28.4,
                'wind_kph': 42.0,
                'condition': {'text': 'Heavy rain'},
              },
            },
          },
          'news': {
            'risk_level': 'medium',
            'events': ['River overflow warning', 'Road closure nearby'],
          },
        },
      });

      expect(result.weatherIndicators, ['heavy_rain', 'strong_wind']);
      expect(result.newsEvents, [
        'River overflow warning',
        'Road closure nearby',
      ]);
      expect(
        result.riskAspectSummary,
        'Weather is HIGH due to Heavy Rain, Strong Wind | '
        'News signals are MEDIUM because of River overflow warning; '
        'Road closure nearby',
      );
    });

    test('returns no aspect summary when both weather and news are low', () {
      final result = AssessmentResult.fromJson({
        'message': 'Area is safe.',
        'risk': {
          'location': 'Safe Area',
          'overall_risk': 'low',
          'weather': {
            'risk_level': 'low',
            'indicators': <String>[],
            'raw_data': {
              'current': {
                'temp_c': 24.0,
                'wind_kph': 8.0,
                'condition': {'text': 'Sunny'},
              },
            },
          },
          'news': {'risk_level': 'low', 'events': <String>[]},
        },
      });

      expect(result.riskAspectSummary, isNull);
      expect(result.weatherCondition, 'Sunny');
    });
  });
}
