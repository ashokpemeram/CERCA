import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/admin/incident_history.dart';
import '../utils/constants.dart';

class IncidentReportService {
  static String buildReportText(IncidentHistory incident) {
    final buffer = StringBuffer();
    buffer.writeln('Incident Report - ${incident.id}');
    buffer.writeln(
      'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('');
    buffer.writeln('Disaster Type: ${incident.disasterType}');
    buffer.writeln('Severity: ${incident.severityText}');
    buffer.writeln('Status: ${incident.statusText}');
    buffer.writeln(
      'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.timestamp)}',
    );
    buffer.writeln('Duration: ${incident.duration}');
    buffer.writeln('Response Time: ${incident.responseTime}');
    buffer.writeln('Affected Population: ${incident.affectedCount}');
    buffer.writeln('Evacuated: ${incident.evacuatedCount}');
    buffer.writeln('');
    buffer.writeln('Raw JSON:');
    buffer.writeln(incident.toJson().toString());
    return buffer.toString();
  }

  static Future<void> downloadReport(
    BuildContext context,
    IncidentHistory incident,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${incident.id}_report.txt');
      await file.writeAsString(buildReportText(incident));

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Incident Report - ${incident.id}',
        subject: 'Incident Report - ${incident.id}',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save report: $e'),
          backgroundColor: AppConstants.dangerColor,
        ),
      );
    }
  }
}
