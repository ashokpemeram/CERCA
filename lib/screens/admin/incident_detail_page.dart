import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/admin/incident_history.dart';
import '../../services/incident_report_service.dart';
import '../../utils/constants.dart';

class IncidentDetailPage extends StatelessWidget {
  final IncidentHistory incident;

  const IncidentDetailPage({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Disaster History'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
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
                    Text(
                      'Back to History',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
            _buildHeaderCard(),
            const SizedBox(height: 12),
            _buildAreaCard(),
            const SizedBox(height: 12),
            _buildWeatherCard(),
            const SizedBox(height: 12),
            _buildSosCard(),
            const SizedBox(height: 12),
            _buildAidCard(),
            const SizedBox(height: 12),
            _buildSafeCampCard(),
            const SizedBox(height: 12),
            _buildDecisionCard(),
            const SizedBox(height: 12),
            _buildCommunicationCard(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  IncidentReportService.downloadReport(context, incident),
              icon: const Icon(Icons.download),
              label: const Text('Download Full Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildChip(
                  incident.id,
                  AppConstants.primaryColor.withValues(alpha: 0.12),
                  AppConstants.primaryColor,
                ),
                _buildChip(
                  incident.statusText.toUpperCase(),
                  AppConstants.safeColor.withValues(alpha: 0.12),
                  AppConstants.safeColor,
                ),
                _buildChip(
                  incident.severityText.toUpperCase(),
                  _severityColor(incident.severity).withValues(alpha: 0.12),
                  _severityColor(incident.severity),
                ),
                if (incident.wasSimulation)
                  _buildChip(
                    'SIMULATION',
                    AppConstants.warningColor.withValues(alpha: 0.12),
                    AppConstants.warningColor,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              incident.disasterType,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              incident.finalOutcomeSummary ??
                  'No final outcome summary recorded.',
              style: AppConstants.bodyStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricTile(
                  'Started',
                  DateFormat('MMM dd, yyyy HH:mm').format(incident.startedAt),
                ),
                _metricTile(
                  'Closed',
                  DateFormat('MMM dd, yyyy HH:mm').format(incident.closedAt),
                ),
                _metricTile('Duration', incident.duration),
                _metricTile('First Response', incident.responseTime),
                _metricTile('Affected', '${incident.affectedCount}'),
                _metricTile('Evacuated', '${incident.evacuatedCount}'),
                _metricTile('Total SOS', '${incident.totalSosLogs}'),
                _metricTile('Total Aid', '${incident.totalAidRequests}'),
                _metricTile('Total Dispatched', '${incident.totalDispatched}'),
                _metricTile('Safe Camps', '${incident.safeCampCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard() {
    return _sectionCard(
      title: 'Area Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Area ID', incident.area.areaId),
          _detailRow('Center', incident.area.coordinates),
          _detailRow('Area Summary', incident.area.summaryLabel),
          _detailRow(
            'Affected Radius',
            'Red ${incident.area.redRadiusM.toStringAsFixed(0)} m, warning ${incident.area.warningRadiusM.toStringAsFixed(0)} m, green ${incident.area.greenRadiusM.toStringAsFixed(0)} m, controllable ${incident.area.controllableRadiusM.toStringAsFixed(0)} m',
          ),
          if ((incident.area.mapSummary ?? '').trim().isNotEmpty)
            _detailRow('Map Summary', incident.area.mapSummary!.trim()),
          if (incident.currentRisk != null)
            _detailRow('Final Assessed Risk', incident.currentRisk!),
          if ((incident.alertMessage ?? '').trim().isNotEmpty)
            _detailRow('Alert Message', incident.alertMessage!.trim()),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return _sectionCard(
      title: 'Weather and Sensor History',
      child: incident.weatherHistory.isEmpty
          ? _emptyText('No weather history was archived for this session.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${incident.weatherHistory.length} weather snapshots recorded across ${incident.duration}.',
                  style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...incident.weatherHistory.map(
                  (snapshot) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            'MMM dd, yyyy HH:mm',
                          ).format(snapshot.timestamp),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.condition} | Risk ${snapshot.riskLevel}',
                          style: AppConstants.bodyStyle.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          snapshot.summary,
                          style: AppConstants.captionStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: snapshot.readings
                              .map(
                                (reading) => _metricTile(
                                  reading.type,
                                  reading.formattedValue,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSosCard() {
    return _sectionCard(
      title: 'SOS Analytics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricTile('Total Reported', '${incident.totalSosLogs}'),
              _metricTile('Dispatched', '${incident.dispatchedSosCount}'),
              _metricTile('Pending', '${incident.pendingSosCount}'),
            ],
          ),
          const SizedBox(height: 12),
          if (incident.sosLogs.isEmpty)
            _emptyText('No SOS logs were archived for this session.')
          else
            ...incident.sosLogs.map(
              (log) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  log.statusText == 'Dispatched'
                      ? Icons.check_circle_outline
                      : Icons.sos,
                  color: AppConstants.dangerColor,
                ),
                title: Text('${log.id} • ${log.callerName}'),
                subtitle: Text(
                  '${log.address}\n${DateFormat('MMM dd, HH:mm').format(log.timestamp)} • ${log.statusText}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAidCard() {
    final requestedResources = incident.requestedResources.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _sectionCard(
      title: 'Aid Analytics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricTile('Total Requests', '${incident.totalAidRequests}'),
              _metricTile('Dispatched', '${incident.dispatchedAidCount}'),
              _metricTile('Pending', '${incident.pendingAidCount}'),
            ],
          ),
          const SizedBox(height: 12),
          if (requestedResources.isEmpty)
            _emptyText('No resource requests were archived for this session.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: requestedResources
                  .map((entry) => _metricTile(entry.key, '${entry.value}'))
                  .toList(),
            ),
          const SizedBox(height: 12),
          if (incident.aidLogs.isEmpty)
            _emptyText('No aid request logs were archived for this session.')
          else
            ...incident.aidLogs.map(
              (log) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text('${log.id} • ${log.requesterName}'),
                subtitle: Text(
                  '${log.resourcesText}\n${log.peopleCount} people • ${log.statusText}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafeCampCard() {
    return _sectionCard(
      title: 'Safe Camps',
      child: incident.safeCamps.isEmpty
          ? _emptyText('No safe camps were archived for this session.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${incident.safeCampCount} camps were active in this session.',
                  style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),
                ...incident.safeCamps.map(
                  (camp) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.house_siding_outlined),
                    title: Text(camp.name),
                    subtitle: Text(
                      '${camp.coordinates}\nCapacity ${camp.capacity} • Occupancy ${camp.currentOccupancy}',
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDecisionCard() {
    return _sectionCard(
      title: 'AI and Admin Decision History',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (incident.aiResourceSnapshot.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: incident.aiResourceSnapshot.entries
                  .map((entry) => _metricTile(entry.key, '${entry.value}'))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (incident.decisionHistory.isEmpty)
            _emptyText('No decision history was archived for this session.')
          else
            ...incident.decisionHistory.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.psychology_outlined),
                title: Text(entry.summary),
                subtitle: Text(
                  '${entry.actor} • ${entry.type} • ${DateFormat('MMM dd, HH:mm').format(entry.timestamp)}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCard() {
    return _sectionCard(
      title: 'Communication Summary',
      child: incident.communicationLogs.isEmpty
          ? _emptyText('No communication logs were archived for this session.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: incident.communicationLogs
                  .map(
                    (log) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.message_outlined),
                      title: Text(log.message),
                      subtitle: Text(
                        '${log.type.name.toUpperCase()} • ${DateFormat('MMM dd, HH:mm').format(log.timestamp)}',
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppConstants.captionStyle.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyStyle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppConstants.captionStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _emptyText(String message) {
    return Text(message, style: AppConstants.bodyStyle.copyWith(fontSize: 14));
  }

  Color _severityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return AppConstants.dangerColor;
      case IncidentSeverity.high:
        return AppConstants.warningColor;
      case IncidentSeverity.medium:
        return AppConstants.primaryColor;
    }
  }
}
