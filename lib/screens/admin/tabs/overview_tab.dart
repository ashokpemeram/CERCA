import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/metric_card.dart';
import '../../../widgets/admin/agent_status_card.dart';
import '../../../models/admin/sensor_reading.dart';
import '../../../models/admin/disaster_event.dart';

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
  void initState() {
    super.initState();
    // Fetch live weather readings for the current area
    Future.microtask(() {
      final adminProvider = context.read<AdminProvider>();
      adminProvider.fetchLiveWeatherForArea();
    });
  }

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
        final simulation = adminProvider.activeSimulation;
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
                            color:
                                adminProvider.systemStatus ==
                                    SystemStatus.normal
                              ? Colors.green[300]
                                : Colors.red[300],
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (adminProvider.systemStatus ==
                                                SystemStatus.normal
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
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showSimulationDialog(context, adminProvider),
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
                        '${adminProvider.currentDisasterType?.toUpperCase() ?? 'DISASTER'} PROTOCOL ACTIVE - Response Teams Deployed',
                        style: TextStyle(
                          color:
                              adminProvider.systemStatus == SystemStatus.normal
                              ? Colors.green[200]
                              : Colors.red[200],
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (simulation != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'SIMULATION ${simulation.isActive ? 'RUNNING' : 'COMPLETE'} - '
                        '${simulation.generatedCitizens}/${simulation.totalCitizens} SOS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
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

              // Area Control
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AREA CONTROL',
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
                    if (adminProvider.currentArea == null)
                      Text(
                        'No active area selected.',
                        style: AppConstants.bodyStyle.copyWith(fontSize: 12),
                      )
                    else ...[
                      Text(
                        'Active Area ID: ${adminProvider.currentArea!.id}',
                        style: AppConstants.bodyStyle.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _confirmCloseArea(
                          context,
                          adminProvider,
                          adminProvider.currentArea!.id,
                        ),
                        icon: const Icon(Icons.lock),
                        label: const Text('Close Active Area'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.dangerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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

              // Decision Agent - Logistics Control
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[50]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[300]!, width: 2),
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
                    if (adminProvider.systemStatus == SystemStatus.normal)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'No active incident. Use SIMULATE to run a scenario and see live decision updates.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    if (adminProvider.systemStatus == SystemStatus.normal)
                      const SizedBox(height: 12),

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
                                adminProvider.aiSuggestions['ambulances']
                                        ?.toString() ??
                                    '12',
                              ),
                              _buildAiSuggestionChip(
                                'Rescue Boats',
                                adminProvider.aiSuggestions['boats']
                                        ?.toString() ??
                                    '8',
                              ),
                              _buildAiSuggestionChip(
                                'Food Packets',
                                adminProvider.aiSuggestions['foodPackets']
                                        ?.toString() ??
                                    '5000',
                              ),
                              _buildAiSuggestionChip(
                                'Medical Kits',
                                adminProvider.aiSuggestions['medicalKits']
                                        ?.toString() ??
                                    '200',
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
                        Icon(Icons.settings, size: 12, color: Colors.grey[700]),
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
                          adminProvider.aiSuggestions['ambulances']
                                  ?.toString() ??
                              '12',
                        ),
                        _buildOverrideField(
                          'Rescue Boats',
                          _boatsController,
                          adminProvider.aiSuggestions['boats']?.toString() ??
                              '8',
                        ),
                        _buildOverrideField(
                          'Food Packets',
                          _foodPacketsController,
                          adminProvider.aiSuggestions['foodPackets']
                                  ?.toString() ??
                              '5000',
                        ),
                        _buildOverrideField(
                          'Medical Kits',
                          _medicalKitsController,
                          adminProvider.aiSuggestions['medicalKits']
                                  ?.toString() ??
                              '200',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Apply Button
                    ElevatedButton(
                      onPressed: () =>
                          _applyDecisionOverrides(context, adminProvider),
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
                      ...adminProvider.decisionAudit
                          .take(3)
                          .map(
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

  void _confirmCloseArea(
    BuildContext context,
    AdminProvider adminProvider,
    String areaId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close Active Area'),
        content: const Text(
          'Closing this area will archive it and prevent new admin logins. '
          'Existing logs remain visible for history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              adminProvider.closeArea(areaId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Area closed and archived.'),
                  backgroundColor: AppConstants.dangerColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.dangerColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close Area'),
          ),
        ],
      ),
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
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
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
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
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
              borderSide: BorderSide(color: Colors.purple[400]!, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _showSimulationDialog(
    BuildContext context,
    AdminProvider adminProvider,
  ) {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final position = locationProvider.currentPosition;

    final latController = TextEditingController(
      text: position != null ? position.latitude.toStringAsFixed(6) : '',
    );
    final lngController = TextEditingController(
      text: position != null ? position.longitude.toStringAsFixed(6) : '',
    );
    final radiusController = TextEditingController(text: '2000');
    final citizensController = TextEditingController(text: '25');
    final intervalController = TextEditingController(text: '2');

    String disasterType = adminProvider.currentDisasterType ?? 'Flood';
    DisasterSeverity severity = DisasterSeverity.medium;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SIMULATE DISASTER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure a realistic incident and stream SOS alerts over time.',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (adminProvider.activeSimulation != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A simulation is already running. Starting a new one will reset the current simulated data.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    value: disasterType,
                    decoration: const InputDecoration(
                      labelText: 'Disaster Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Flood',
                        child: Text('Flood'),
                      ),
                      DropdownMenuItem(
                        value: 'Earthquake',
                        child: Text('Earthquake'),
                      ),
                      DropdownMenuItem(
                        value: 'Cyclone',
                        child: Text('Cyclone'),
                      ),
                      DropdownMenuItem(
                        value: 'Fire',
                        child: Text('Fire'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => disasterType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DisasterSeverity>(
                    value: severity,
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: DisasterSeverity.low,
                        child: Text('Low'),
                      ),
                      DropdownMenuItem(
                        value: DisasterSeverity.medium,
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem(
                        value: DisasterSeverity.high,
                        child: Text('High'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => severity = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: lngController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: position == null
                          ? null
                          : () {
                              latController.text =
                                  position.latitude.toStringAsFixed(6);
                              lngController.text =
                                  position.longitude.toStringAsFixed(6);
                              setState(() {});
                            },
                      icon: const Icon(Icons.my_location, size: 16),
                      label: const Text('Use current location'),
                    ),
                  ),
                  TextField(
                    controller: radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Affected Radius (meters)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: citizensController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Simulated Citizens',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: intervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SOS Interval (seconds)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final lat = double.tryParse(
                              latController.text.trim(),
                            );
                            final lon = double.tryParse(
                              lngController.text.trim(),
                            );
                            final radius =
                                double.tryParse(radiusController.text.trim()) ??
                                0;
                            final citizens =
                                int.tryParse(citizensController.text.trim()) ??
                                0;
                            final intervalSeconds =
                                int.tryParse(intervalController.text.trim()) ??
                                0;

                            if (lat == null || lon == null) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter valid coordinates.'),
                                  backgroundColor: AppConstants.dangerColor,
                                ),
                              );
                              return;
                            }
                            if (radius <= 0 || citizens <= 0) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter valid radius and count.'),
                                  backgroundColor: AppConstants.dangerColor,
                                ),
                              );
                              return;
                            }

                            final interval = intervalSeconds <= 0
                                ? const Duration(seconds: 2)
                                : Duration(seconds: intervalSeconds);

                            adminProvider.startDisasterSimulation(
                              type: disasterType,
                              centerLat: lat,
                              centerLon: lon,
                              radiusM: radius,
                              severity: severity,
                              totalCitizens: citizens,
                              interval: interval,
                            );
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$disasterType simulation started.',
                                ),
                                backgroundColor: AppConstants.primaryColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Start Simulation'),
                        ),
                      ),
                    ],
                  ),
                  if (adminProvider.activeSimulation != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        adminProvider.stopSimulation();
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Simulation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.dangerColor,
                        side: const BorderSide(color: AppConstants.dangerColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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
          content: Text(
            'No changes detected. Please modify at least one resource allocation.',
          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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



