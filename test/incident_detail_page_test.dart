import 'package:CERCA/screens/admin/incident_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers/sample_incident.dart';

void main() {
  testWidgets('IncidentDetailPage renders archived session details', (
    tester,
  ) async {
    final incident = buildSampleIncident();

    await tester.pumpWidget(
      MaterialApp(home: IncidentDetailPage(incident: incident)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flood'), findsOneWidget);
    expect(find.text('Area Information'), findsOneWidget);
    expect(find.text('Weather and Sensor History'), findsOneWidget);
    expect(find.text('SOS Analytics'), findsOneWidget);
    expect(find.text('Aid Analytics'), findsOneWidget);
    expect(find.text('AI and Admin Decision History'), findsOneWidget);
    expect(find.text('Download Full Report'), findsOneWidget);
    expect(find.textContaining('Central Camp'), findsOneWidget);
    expect(
      find.textContaining('Increase boats and ambulances'),
      findsOneWidget,
    );
  });
}
