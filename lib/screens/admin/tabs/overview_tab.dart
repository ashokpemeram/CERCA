import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/metric_card.dart';
import '../../../widgets/admin/agent_status_card.dart';
import '../../../models/admin/sensor_reading.dart';

/// Overview tab for admin dashboard
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // System Status Card
              InfoCard(
                child: Column(
                  children: [
                    Text(
                      'System Status',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: adminProvider.systemStatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: adminProvider.systemStatusColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        adminProvider.systemStatusText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: adminProvider.systemStatusColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => adminProvider.simulateStatusChange(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Simulate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Agent Health Monitor
              Text(
                'Agent Health Monitor',
                style: AppConstants.subheadingStyle,
              ),
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

              // Live Sensor Readings
              Text(
                'Live Sensor Readings',
                style: AppConstants.subheadingStyle,
              ),
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
