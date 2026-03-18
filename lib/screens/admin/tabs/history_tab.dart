import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/admin/incident_history.dart';
import '../../../providers/admin_provider.dart';
import '../../../services/incident_report_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/status_chip.dart';
import '../incident_detail_page.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final incidents = adminProvider.incidentHistory;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Expanded(
              child: incidents.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: incidents.length,
                      itemBuilder: (context, index) {
                        final incident = incidents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showDetailedReport(context, incident),
                            child: InfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          incident.id,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      StatusChip.info(incident.area.areaId),
                                      const SizedBox(width: 8),
                                      _getSeverityChip(incident.severity),
                                      const SizedBox(width: 8),
                                      StatusChip.success(incident.statusText),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 18,
                                        color: AppConstants.dangerColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          incident.disasterType,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    incident.areaSummary,
                                    style: AppConstants.bodyStyle.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildMetricBox(
                                        'Duration',
                                        incident.duration,
                                        Icons.access_time,
                                      ),
                                      _buildMetricBox(
                                        'Affected',
                                        '${incident.affectedCount}',
                                        Icons.people,
                                      ),
                                      _buildMetricBox(
                                        'Evacuated',
                                        '${incident.evacuatedCount}',
                                        Icons.directions_walk,
                                      ),
                                      _buildMetricBox(
                                        'SOS Logs',
                                        '${incident.totalSosLogs}',
                                        Icons.sos,
                                      ),
                                      _buildMetricBox(
                                        'Aid Requests',
                                        '${incident.totalAidRequests}',
                                        Icons.inventory_2_outlined,
                                      ),
                                      _buildMetricBox(
                                        'Dispatched',
                                        '${incident.totalDispatched}',
                                        Icons.local_shipping_outlined,
                                      ),
                                      _buildMetricBox(
                                        'Safe Camps',
                                        '${incident.safeCampCount}',
                                        Icons.house_siding_outlined,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Started: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.startedAt)}',
                                    style: AppConstants.captionStyle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Closed: ${DateFormat('MMM dd, yyyy HH:mm').format(incident.closedAt)}',
                                    style: AppConstants.captionStyle,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showDetailedReport(
                                            context,
                                            incident,
                                          ),
                                          icon: const Icon(Icons.description),
                                          label: const Text('DETAILS'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppConstants.primaryColor,
                                            side: const BorderSide(
                                              color: AppConstants.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              IncidentReportService.downloadReport(
                                                context,
                                                incident,
                                              ),
                                          icon: const Icon(
                                            Icons.download,
                                            size: 18,
                                          ),
                                          label: const Text('DOWNLOAD'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppConstants.primaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off, size: 52, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(
              'No archived disaster sessions yet.',
              style: AppConstants.subheadingStyle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Once an admin closes an active area, the completed session will appear here with full history and export support.',
              style: AppConstants.bodyStyle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
    return SizedBox(
      width: 110,
      child: Container(
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
                Expanded(
                  child: Text(
                    label,
                    style: AppConstants.captionStyle.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedReport(BuildContext context, IncidentHistory incident) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncidentDetailPage(incident: incident)),
    );
  }
}
