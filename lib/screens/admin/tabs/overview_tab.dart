import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/assessment_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../models/assessment_result.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/metric_card.dart';
import '../../../widgets/admin/agent_status_card.dart';
import '../../../models/admin/sensor_reading.dart';

/// Overview tab for admin dashboard
class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool _hasAutoAssessed = false;
  Timer? _assessmentTimer;

  @override
  void initState() {
    super.initState();
    // Re-assess every 60 seconds
    _assessmentTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final locationProvider = context.read<LocationProvider>();
      final lat = locationProvider.latitude;
      final lon = locationProvider.longitude;
      if (lat != null && lon != null) {
        context.read<AssessmentProvider>().assessByCoordinates(lat, lon);
      }
    });
  }

  @override
  void dispose() {
    _assessmentTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-trigger assessment once when location is available
    if (!_hasAutoAssessed) {
      final locationProvider = context.read<LocationProvider>();
      final lat = locationProvider.latitude;
      final lon = locationProvider.longitude;
      if (lat != null && lon != null) {
        _hasAutoAssessed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<AssessmentProvider>().assessByCoordinates(lat, lon);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminProvider, AssessmentProvider>(
      builder: (context, adminProvider, assessmentProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── AI Risk Assessment Card ─────────────────────────────────
              _buildAssessRiskCard(context, assessmentProvider),
              const SizedBox(height: 20),

              // ── Agent Health Monitor ────────────────────────────────────
              Text('Agent Health Monitor', style: AppConstants.subheadingStyle),
              const SizedBox(height: 12),
              ...adminProvider.agentStatuses.map(
                (agent) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AgentStatusCard(
                    agentName: agent.name,
                    status: agent.status,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Live Sensor Readings ────────────────────────────────────
              Text('Live Sensor Readings', style: AppConstants.subheadingStyle),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: adminProvider.sensorReadings.length,
                itemBuilder: (context, index) {
                  final sensor = adminProvider.sensorReadings[index];
                  return MetricCard(
                    title: sensor.type,
                    value: sensor.formattedValue,
                    icon: _getSensorIcon(sensor.type),
                    iconColor: _getSensorColor(sensor.type),
                    statusText: sensor.trendText,
                    trendIcon: _getTrendIcon(sensor.trend),
                    trendColor: _getTrendColor(sensor.trend),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssessRiskCard(
      BuildContext context, AssessmentProvider provider) {
    final locationProvider = context.watch<LocationProvider>();
    final lat = locationProvider.latitude;
    final lon = locationProvider.longitude;
    final hasLocation = lat != null && lon != null;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppConstants.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Disaster Risk Assessment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      'Powered by WeatherAPI · NewsAPI · GPT-4o-mini',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Location Chip ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasLocation
                  ? AppConstants.safeColor.withOpacity(0.08)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: Border.all(
                color: hasLocation
                    ? AppConstants.safeColor.withOpacity(0.4)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  size: 16,
                  color: hasLocation
                      ? AppConstants.safeColor
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasLocation
                        ? 'Using your GPS location  (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})'
                        : 'Waiting for GPS location...',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasLocation
                          ? AppConstants.safeColor
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Refresh button
                if (hasLocation)
                  InkWell(
                    onTap: provider.isLoading
                        ? null
                        : () => provider.assessByCoordinates(lat, lon),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppConstants.primaryColor,
                              ),
                            )
                          : const Icon(Icons.refresh,
                              size: 18, color: AppConstants.primaryColor),
                    ),
                  ),
              ],
            ),
          ),

          // ── Loading State ──
          if (provider.isLoading) ...[
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppConstants.primaryColor),
                  SizedBox(height: 12),
                  Text(
                    'Analysing weather, news & risk...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── No Location ──
          if (!hasLocation && !provider.isLoading && provider.result == null) ...[
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(Icons.location_off, color: Colors.grey.shade400, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Location not available.\nPlease grant location permission.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],

          // ── Error ──
          if (provider.errorMessage != null && !provider.isLoading) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Result Card ──
          if (provider.result != null && !provider.isLoading) ...[
            const SizedBox(height: 16),
            _buildResultCard(provider.result!),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(AssessmentResult result) {
    final riskColor = _riskColor(result.overallRisk);
    final riskIcon = _riskIcon(result.overallRisk);

    return Container(
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: riskColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Risk banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(riskIcon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.location.isNotEmpty
                            ? result.location.toUpperCase()
                            : 'YOUR LOCATION',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${result.overallRisk.toUpperCase()} RISK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather
                if (result.temperatureC != null ||
                    result.weatherCondition != null) ...[
                  _sectionLabel('Weather', Icons.wb_sunny_outlined),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (result.temperatureC != null)
                        _chip('${result.temperatureC!.toStringAsFixed(1)}°C',
                            Icons.thermostat, Colors.orange),
                      if (result.windKph != null)
                        _chip('${result.windKph!.toStringAsFixed(0)} km/h',
                            Icons.air, Colors.blue),
                      if (result.weatherCondition != null)
                        _chip(result.weatherCondition!, Icons.cloud,
                            Colors.blueGrey),
                      if (result.weatherRiskLevel != null)
                        _chip('Weather: ${result.weatherRiskLevel!}',
                            Icons.warning_amber_outlined,
                            _riskColor(result.weatherRiskLevel!)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // News
                _sectionLabel('News Analysis', Icons.newspaper),
                const SizedBox(height: 6),
                _chip('News risk: ${result.newsRiskLevel ?? 'low'}',
                    Icons.assessment_outlined,
                    _riskColor(result.newsRiskLevel ?? 'low')),
                if (result.newsEvents.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...result.newsEvents.take(3).map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle,
                                  size: 6, color: Colors.grey.shade500),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(e,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF616161))),
                              ),
                            ],
                          ),
                        ),
                      ),
                ] else ...[
                  const SizedBox(height: 4),
                  const Text('No disaster-related news detected.',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],

                // GPT-4o-mini alert
                if (result.alertMessage != null) ...[
                  const SizedBox(height: 14),
                  _sectionLabel('AI Alert Message', Icons.smart_toy_outlined),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: riskColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      result.alertMessage!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF212121),
                          height: 1.5),
                    ),
                  ),
                ],

                // Safe message
                if (result.safeMessage != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppConstants.safeColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(result.safeMessage!,
                            style: const TextStyle(
                                color: AppConstants.safeColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return AppConstants.dangerColor;
      case 'medium':
        return AppConstants.warningColor;
      default:
        return AppConstants.safeColor;
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.warning_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  IconData _getSensorIcon(String type) {
    switch (type) {
      case 'Water Level':
        return Icons.water;
      case 'Wind Speed':
        return Icons.air;
      case 'Temperature':
        return Icons.thermostat;
      case 'Rainfall':
        return Icons.water_drop;
      default:
        return Icons.sensors;
    }
  }

  Color _getSensorColor(String type) {
    switch (type) {
      case 'Water Level':
        return Colors.blue;
      case 'Wind Speed':
        return Colors.cyan;
      case 'Temperature':
        return Colors.orange;
      case 'Rainfall':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(SensorTrend trend) {
    switch (trend) {
      case SensorTrend.up:
        return Icons.arrow_upward;
      case SensorTrend.down:
        return Icons.arrow_downward;
      case SensorTrend.stable:
        return Icons.remove;
    }
  }

  Color _getTrendColor(SensorTrend trend) {
    switch (trend) {
      case SensorTrend.up:
        return Colors.red;
      case SensorTrend.down:
        return Colors.green;
      case SensorTrend.stable:
        return Colors.grey;
    }
  }
}
