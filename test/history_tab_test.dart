import 'dart:convert';

import 'package:CERCA/providers/admin_provider.dart';
import 'package:CERCA/screens/admin/tabs/history_tab.dart';
import 'package:CERCA/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'test_helpers/sample_incident.dart';

void main() {
  testWidgets('HistoryTab renders archived session preview data', (
    tester,
  ) async {
    final incident = buildSampleIncident();
    final provider = AdminProvider(
      apiService: ApiService.withClient(
        MockClient(
          (request) async =>
              http.Response(jsonEncode([incident.toJson()]), 200),
        ),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AdminProvider>.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: HistoryTab())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('INC-20260318123000-TEST'), findsOneWidget);
    expect(find.text('Flood'), findsOneWidget);
    expect(find.textContaining('2200 m warning radius'), findsOneWidget);
    expect(find.text('DOWNLOAD'), findsOneWidget);
    expect(find.text('DETAILS'), findsOneWidget);

    provider.dispose();
  });
}
