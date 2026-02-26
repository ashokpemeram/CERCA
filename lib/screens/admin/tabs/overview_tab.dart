import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
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
  // Controllers for each resource type
  final TextEditingController _ambulancesController = TextEditingController();
  final TextEditingController _boatsController = TextEditingController();
  final TextEditingController _foodPacketsController = TextEditingController();
  final TextEditingController _medicalKitsController = TextEditingController();

  @override
  void dispose() {
    _ambulancesController.dispose();
    _boatsController.dispose();
    _foodPacketsController.dispose();
    _medicalKitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // System Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: adminProvider.systemStatus == SystemStatus.normal
                        ? [Colors.green[700]!, Colors.green[900]!]
                        : [Colors.red[700]!, Colors.red[900]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: adminProvider.systemStatus == SystemStatus.normal
                                ? Colors.green[300]
                                : Colors.red[300],
                            boxShadow: [
                              BoxShadow(
                                color: (adminProvider.systemStatus == SystemStatus.normal
                                        ? Colors.green[300]
                                        : Colors.red[300])!
                                    .withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SYSTEM STATUS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        // Show a spinner while the simulation API call is in flight
                        if (adminProvider.isSimulating)
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                          onPressed: () => _showSimulationDialog(context, adminProvider),
                          icon: const Icon(Icons.play_arrow, size: 14),
                          label: const Text(
                            'SIMULATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      adminProvider.systemStatusText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (adminProvider.systemStatus != SystemStatus.normal) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${adminProvider.currentDisasterType?.toUpperCase() ?? 'DISASTER'} PROTOCOL ACTIVE • Response Teams Deployed',
                        style: TextStyle(
                          color: adminProvider.systemStatus == SystemStatus.normal
                              ? Colors.green[200]
                              : Colors.red[200],
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Agent Health Monitor
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AGENT HEALTH MONITOR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Live Sensor Readings
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE SENSOR READINGS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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
              ),
              const SizedBox(height: 20),

              // Decision Agent - Logistics Control (shown during active emergency)
              if (adminProvider.systemStatus != SystemStatus.normal)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[50]!, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purple[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.psychology,
                              size: 16,
                              color: Colors.purple[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DECISION AGENT - LOGISTICS CONTROL',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'AI-powered resource allocation based on real-time data',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // AI Recommendations Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: Colors.purple[600]!,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: Colors.purple[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI RESOURCE RECOMMENDATIONS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Display AI suggestions in grid
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.5,
                              children: [
                                _buildAiSuggestionChip(
                                  'Ambulances',
                                  adminProvider.aiSuggestions['ambulances']?.toString() ?? '12',
                                ),
                                _buildAiSuggestionChip(
                                  'Rescue Boats',
                                  adminProvider.aiSuggestions['boats']?.toString() ?? '8',
                                ),
                                _buildAiSuggestionChip(
                                  'Food Packets',
                                  adminProvider.aiSuggestions['foodPackets']?.toString() ?? '5000',
                                ),
                                _buildAiSuggestionChip(
                                  'Medical Kits',
                                  adminProvider.aiSuggestions['medicalKits']?.toString() ?? '200',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 12,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Based on: ${adminProvider.sosAlertsCount} SOS alerts, ${adminProvider.aidRequestsCount} aid requests, weather data, and map analysis',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Admin Override Section
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            size: 12,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ADMIN OVERRIDE (Edit to modify AI suggestions)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Override Input Fields
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.0,
                        children: [
                          _buildOverrideField(
                            'Ambulances',
                            _ambulancesController,
                            adminProvider.aiSuggestions['ambulances']?.toString() ?? '12',
                          ),
                          _buildOverrideField(
                            'Rescue Boats',
                            _boatsController,
                            adminProvider.aiSuggestions['boats']?.toString() ?? '8',
                          ),
                          _buildOverrideField(
                            'Food Packets',
                            _foodPacketsController,
                            adminProvider.aiSuggestions['foodPackets']?.toString() ?? '5000',
                          ),
                          _buildOverrideField(
                            'Medical Kits',
                            _medicalKitsController,
                            adminProvider.aiSuggestions['medicalKits']?.toString() ?? '200',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Apply Button
                      ElevatedButton(
                        onPressed: () => _applyDecisionOverrides(context, adminProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'APPLY OVERRIDES & RECALCULATE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Warning Note
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                              color: Colors.yellow[700]!,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: Colors.yellow[800],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Note: System will recalculate resource gaps and suggest backup plans. Your override decisions are logged for learning.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.yellow[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Audit Trail (if exists)
                      if (adminProvider.decisionAudit.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'RECENT DECISIONS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...adminProvider.decisionAudit.take(3).map(
                              (audit) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.purple[400],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        audit,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiSuggestionChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value units',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverrideField(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: Colors.purple[400]!,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSimulationDialog(BuildContext context, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[900]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'INITIATE SIMULATION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Select disaster scenario for demo',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSimulationOption(
                    context,
                    adminProvider,
                    'Coastal Flood',
                    Icons.waves,
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildSimulationOption(
                    context,
                    adminProvider,
                    'Cyclone',
                    Icons.air,
                    Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _buildSimulationOption(
                    context,
                    adminProvider,
                    'Earthquake',
                    Icons.landscape,
                    Colors.brown,
                  ),
                  const SizedBox(height: 8),
                  _buildSimulationOption(
                    context,
                    adminProvider,
                    'Forest Fire',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationOption(
    BuildContext context,
    AdminProvider adminProvider,
    String disasterType,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        // Dismiss the dialog immediately so the user can see the loading state
        Navigator.pop(context);

        // Kick off the async FastAPI call (provider's isSimulating becomes true)
        await adminProvider.runSimulation(disasterType);

        // Show outcome snackbar once the call completes.
        // Use a mounted-safe guard — the widget might have been disposed.
        if (context.mounted) {
          final message = adminProvider.lastSimulationMessage ??
              '$disasterType simulation initiated';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              disasterType.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyDecisionOverrides(
    BuildContext context,
    AdminProvider adminProvider,
  ) {
    // Collect override values
    final overrides = <String, int>{};
    
    if (_ambulancesController.text.isNotEmpty) {
      overrides['ambulances'] = int.tryParse(_ambulancesController.text) ?? 0;
    }
    if (_boatsController.text.isNotEmpty) {
      overrides['boats'] = int.tryParse(_boatsController.text) ?? 0;
    }
    if (_foodPacketsController.text.isNotEmpty) {
      overrides['foodPackets'] = int.tryParse(_foodPacketsController.text) ?? 0;
    }
    if (_medicalKitsController.text.isNotEmpty) {
      overrides['medicalKits'] = int.tryParse(_medicalKitsController.text) ?? 0;
    }

    if (overrides.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected. Please modify at least one resource allocation.'),
        ),
      );
      return;
    }

    // Apply overrides through provider
    // This will:
    // 1. Store override in Redis for learning
    // 2. Recalculate resource gaps
    // 3. Update AI suggestions based on new data + past overrides
    // 4. Create audit trail
    adminProvider.applyResourceOverrides(overrides);

    // Clear controllers
    _ambulancesController.clear();
    _boatsController.clear();
    _foodPacketsController.clear();
    _medicalKitsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Decision overrides applied. System recalculating resource allocation and gap analysis.',
        ),
        backgroundColor: Colors.purple[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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