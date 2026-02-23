import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/status_chip.dart';
import '../../../models/admin/incident_history.dart';
import '../incident_detail_page.dart';

/// History tab for admin dashboard
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              color: AppConstants.primaryColor,
              child: const Text(
                'Disaster History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Incident List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                itemCount: adminProvider.incidentHistory.length,
                itemBuilder: (context, index) {
                  final incident = adminProvider.incidentHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Text(
                                incident.id,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _getSeverityChip(incident.severity),
                              const SizedBox(width: 8),
                              StatusChip.success(incident.statusText),
                            ],
                          ),
                          const Divider(height: 20),

                          // Disaster Type
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                size: 20,
                                color: AppConstants.dangerColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                incident.disasterType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Metrics Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricBox(
                                  'Duration',
                                  incident.duration,
                                  Icons.access_time,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMetricBox(
                                  'Response Time',
                                  incident.responseTime,
                                  Icons.speed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricBox(
                                  'Affected',
                                  '${incident.affectedCount}',
                                  Icons.people,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMetricBox(
                                  'Evacuated',
                                  '${incident.evacuatedCount}',
                                  Icons.emergency,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Date
                          Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(incident.timestamp)}',
                            style: AppConstants.captionStyle,
                          ),
                          const SizedBox(height: 12),

                          // View Report Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showDetailedReport(
                                context,
                                incident,
                              ),
                              icon: const Icon(Icons.description),
                              label: const Text('VIEW DETAILED REPORT'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppConstants.primaryColor,
                                side: const BorderSide(
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                'Total Sessions: ${adminProvider.totalSessions}',
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getSeverityChip(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return StatusChip.danger('Critical');
      case IncidentSeverity.high:
        return StatusChip.warning('High');
      case IncidentSeverity.medium:
        return StatusChip.info('Medium');
    }
  }

  Widget _buildMetricBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppConstants.captionStyle.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedReport(BuildContext context, IncidentHistory incident) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncidentDetailPage(incident: incident),
      ),
    );
  }
}
