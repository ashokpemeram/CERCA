import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin/incident_history.dart';
import '../../utils/constants.dart';

/// Page that shows detailed incident information and allows downloading a report.
class IncidentDetailPage extends StatelessWidget {
  final IncidentHistory incident;

  const IncidentDetailPage({super.key, required this.incident});

  String _buildReportText() {
    final buffer = StringBuffer();
    buffer.writeln('Incident Report - ${incident.id}');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('Disaster Type: ${incident.disasterType}');
    buffer.writeln('Severity: ${incident.severityText}');
    buffer.writeln('Status: ${incident.statusText}');
    buffer.writeln('Date: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.timestamp)}');
    buffer.writeln('Duration: ${incident.duration}');
    buffer.writeln('Response Time: ${incident.responseTime}');
    buffer.writeln('Affected Population: ${incident.affectedCount}');
    buffer.writeln('Evacuated: ${incident.evacuatedCount}');
    buffer.writeln('');
    buffer.writeln('Raw JSON:');
    buffer.writeln(incident.toJson().toString());
    return buffer.toString();
  }

  Future<void> _downloadReport(BuildContext context) async {
    try {
      final text = _buildReportText();

      // Write to a temporary file and open the native share sheet so user can save/download
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${incident.id}_report.txt');
      await file.writeAsString(text);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Incident Report - ${incident.id}',
        subject: 'Incident Report - ${incident.id}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save report: $e'),
            backgroundColor: AppConstants.dangerColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Disaster History'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('Back to History', style: TextStyle(color: Colors.blue[700])),
                    ],
                  ),
                ),
              ),

              // Main incident card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(incident.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: incident.severity == IncidentSeverity.critical
                                  ? AppConstants.dangerColor
                                  : incident.severity == IncidentSeverity.high
                                      ? AppConstants.mediumRiskColor
                                      : Colors.blueGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              incident.severityText.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(incident.disasterType, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd • hh:mm a').format(incident.timestamp),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('AFFECTED AREA', style: AppConstants.captionStyle.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Coastal District A, Sectors 3-7', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      // Impact statistics grid
                      Text('IMPACT STATISTICS', style: AppConstants.captionStyle.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _metricCard('Affected Population', '${incident.affectedCount}', Colors.blue[50]!, Colors.blue),
                          _metricCard('Evacuated', '${incident.evacuatedCount}', Colors.green[50]!, Colors.green[700]!),
                          _metricCard('Casualties', '—', Colors.red[50]!, AppConstants.dangerColor),
                          _metricCard('Injured', '—', Colors.orange[50]!, Colors.deepOrange),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('RESOURCES DEPLOYED', style: AppConstants.captionStyle.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _resourceTile('Ambulances', '12'),
                          _resourceTile('Boats', '8'),
                          _resourceTile('Food Packets', '5000'),
                          _resourceTile('Medical Kits', '200'),
                          _resourceTile('Shelters', '4'),
                          _resourceTile('Volunteers', '—'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI & ADMIN DECISIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('1. Auto-evacuation advised for coastal sectors 3-7.'),
                      const SizedBox(height: 6),
                      const Text('2. Medical teams deployed to sector 5.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _downloadReport(context),
                icon: const Icon(Icons.download),
                label: const Text('Download Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, Color bgColor, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppConstants.captionStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent)),
        ],
      ),
    );
  }

  Widget _resourceTile(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
