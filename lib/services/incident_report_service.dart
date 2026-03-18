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
    buffer.writeln('CERCA Archived Disaster Session Report');
    buffer.writeln('Session ID: ${incident.id}');
    buffer.writeln(
      'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('');
    buffer.writeln('SUMMARY');
    buffer.writeln('Disaster Type: ${incident.disasterType}');
    buffer.writeln('Severity: ${incident.severityText}');
    buffer.writeln('Status: ${incident.statusText}');
    buffer.writeln(
      'Started: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.startedAt)}',
    );
    buffer.writeln(
      'Closed: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.closedAt)}',
    );
    buffer.writeln('Duration: ${incident.duration}');
    buffer.writeln('First Response: ${incident.responseTime}');
    buffer.writeln('Affected Population: ${incident.affectedCount}');
    buffer.writeln('Evacuated Count: ${incident.evacuatedCount}');
    buffer.writeln('Total SOS Logs: ${incident.totalSosLogs}');
    buffer.writeln('Total Aid Requests: ${incident.totalAidRequests}');
    buffer.writeln('Total Dispatched: ${incident.totalDispatched}');
    buffer.writeln('Safe Camps: ${incident.safeCampCount}');
    if (incident.currentRisk != null) {
      buffer.writeln('Final Risk Level: ${incident.currentRisk}');
    }
    if ((incident.alertMessage ?? '').trim().isNotEmpty) {
      buffer.writeln('Alert Message: ${incident.alertMessage}');
    }
    if ((incident.finalOutcomeSummary ?? '').trim().isNotEmpty) {
      buffer.writeln('Outcome Summary: ${incident.finalOutcomeSummary}');
    }

    buffer.writeln('');
    buffer.writeln('AREA');
    buffer.writeln('Area ID: ${incident.area.areaId}');
    buffer.writeln('Center: ${incident.area.coordinates}');
    buffer.writeln('Summary: ${incident.area.summaryLabel}');
    buffer.writeln(
      'Radii: red ${incident.area.redRadiusM.toStringAsFixed(0)} m, '
      'warning ${incident.area.warningRadiusM.toStringAsFixed(0)} m, '
      'green ${incident.area.greenRadiusM.toStringAsFixed(0)} m, '
      'controllable ${incident.area.controllableRadiusM.toStringAsFixed(0)} m',
    );
    if ((incident.area.mapSummary ?? '').trim().isNotEmpty) {
      buffer.writeln('Map Summary: ${incident.area.mapSummary}');
    }

    buffer.writeln('');
    buffer.writeln('WEATHER AND SENSOR HISTORY');
    if (incident.weatherHistory.isEmpty) {
      buffer.writeln('No weather history recorded.');
    } else {
      for (final snapshot in incident.weatherHistory) {
        buffer.writeln(
          '- ${DateFormat('MMM dd, yyyy HH:mm').format(snapshot.timestamp)} | '
          '${snapshot.condition} | Risk ${snapshot.riskLevel}',
        );
        buffer.writeln('  ${snapshot.summary}');
        for (final reading in snapshot.readings) {
          buffer.writeln('  ${reading.type}: ${reading.formattedValue}');
        }
      }
    }

    buffer.writeln('');
    buffer.writeln('SOS ANALYTICS');
    buffer.writeln('Total Reported: ${incident.totalSosLogs}');
    buffer.writeln('Dispatched: ${incident.dispatchedSosCount}');
    buffer.writeln('Pending: ${incident.pendingSosCount}');
    if (incident.sosLogs.isEmpty) {
      buffer.writeln('No SOS logs recorded.');
    } else {
      for (final log in incident.sosLogs) {
        buffer.writeln(
          '- ${log.id} | ${log.callerName} | ${log.statusText} | '
          '${DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp)}',
        );
        buffer.writeln('  ${log.address}');
      }
    }

    buffer.writeln('');
    buffer.writeln('AID ANALYTICS');
    buffer.writeln('Total Requests: ${incident.totalAidRequests}');
    buffer.writeln('Dispatched: ${incident.dispatchedAidCount}');
    buffer.writeln('Pending: ${incident.pendingAidCount}');
    if (incident.requestedResources.isNotEmpty) {
      buffer.writeln('Requested Resources:');
      incident.requestedResources.forEach((resource, count) {
        buffer.writeln('  - $resource: $count');
      });
    }
    if (incident.aidLogs.isEmpty) {
      buffer.writeln('No aid requests recorded.');
    } else {
      for (final log in incident.aidLogs) {
        buffer.writeln(
          '- ${log.id} | ${log.requesterName} | ${log.statusText} | ${log.resourcesText}',
        );
        buffer.writeln(
          '  People: ${log.peopleCount} | Location: ${log.location}',
        );
      }
    }

    buffer.writeln('');
    buffer.writeln('SAFE CAMPS');
    if (incident.safeCamps.isEmpty) {
      buffer.writeln('No safe camps recorded.');
    } else {
      for (final camp in incident.safeCamps) {
        buffer.writeln(
          '- ${camp.name} | ${camp.coordinates} | Capacity ${camp.capacity} | Occupancy ${camp.currentOccupancy}',
        );
      }
    }

    buffer.writeln('');
    buffer.writeln('AI AND ADMIN DECISIONS');
    if (incident.aiResourceSnapshot.isNotEmpty) {
      buffer.writeln('Current AI Resource Snapshot:');
      incident.aiResourceSnapshot.forEach((resource, value) {
        buffer.writeln('  - $resource: $value');
      });
    }
    if (incident.decisionHistory.isEmpty) {
      buffer.writeln('No decision history recorded.');
    } else {
      for (final entry in incident.decisionHistory) {
        buffer.writeln(
          '- ${DateFormat('MMM dd, yyyy HH:mm').format(entry.timestamp)} | '
          '${entry.actor} | ${entry.type}',
        );
        buffer.writeln('  ${entry.summary}');
      }
    }

    buffer.writeln('');
    buffer.writeln('COMMUNICATION SUMMARY');
    if (incident.communicationLogs.isEmpty) {
      buffer.writeln('No communication logs recorded.');
    } else {
      for (final log in incident.communicationLogs) {
        buffer.writeln(
          '- ${DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp)} | '
          '${log.type.name.toUpperCase()}',
        );
        buffer.writeln('  ${log.message}');
      }
    }

    buffer.writeln('');
    buffer.writeln('KEY ACTIONS');
    if (incident.keyActions.isEmpty) {
      buffer.writeln('No key actions captured.');
    } else {
      for (final action in incident.keyActions) {
        buffer.writeln('- $action');
      }
    }

    buffer.writeln('');
    buffer.writeln('RAW JSON');
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
