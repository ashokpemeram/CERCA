import 'package:CERCA/services/incident_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/sample_incident.dart';

void main() {
  test('buildReportText includes full archived session sections', () {
    final report = IncidentReportService.buildReportText(buildSampleIncident());

    expect(report, contains('CERCA Archived Disaster Session Report'));
    expect(report, contains('SUMMARY'));
    expect(report, contains('WEATHER AND SENSOR HISTORY'));
    expect(report, contains('SOS ANALYTICS'));
    expect(report, contains('AID ANALYTICS'));
    expect(report, contains('SAFE CAMPS'));
    expect(report, contains('AI AND ADMIN DECISIONS'));
    expect(report, contains('COMMUNICATION SUMMARY'));
    expect(report, contains('Central Camp'));
    expect(
      report,
      contains('Increase boats and ambulances for the flood response.'),
    );
  });
}
