import 'package:flutter/material.dart';
import '../models/admin/agent_status.dart';
import '../models/admin/sensor_reading.dart';
import '../models/admin/sos_request.dart';
import '../models/admin/aid_request_admin.dart';
import '../models/admin/incident_history.dart';
import '../models/admin/safe_camp.dart';
import '../models/admin/communication_log.dart';
import '../services/admin_data_service.dart';
import '../services/simulation_service.dart';

/// System status enumeration
enum SystemStatus {
  normal,
  critical,
  degraded,
}

/// Provider for admin dashboard state management
class AdminProvider with ChangeNotifier {
  // System status
  SystemStatus _systemStatus = SystemStatus.normal;
  SystemStatus get systemStatus => _systemStatus;

  // Agent statuses
  List<AgentStatus> _agentStatuses = [];
  List<AgentStatus> get agentStatuses => _agentStatuses;

  // Sensor readings
  List<SensorReading> _sensorReadings = [];
  List<SensorReading> get sensorReadings => _sensorReadings;

  // SOS requests
  List<SosRequest> _sosRequests = [];
  List<SosRequest> get sosRequests => _sosRequests;

  // Aid requests
  List<AidRequestAdmin> _aidRequests = [];
  List<AidRequestAdmin> get aidRequests => _aidRequests;

  // Incident history
  List<IncidentHistory> _incidentHistory = [];
  List<IncidentHistory> get incidentHistory => _incidentHistory;

  // Safe camps
  List<SafeCamp> _safeCamps = [];
  List<SafeCamp> get safeCamps => _safeCamps;

  // Current disaster type for active simulations
  String? _currentDisasterType;
  String? get currentDisasterType => _currentDisasterType;

  // Communication logs
  List<CommunicationLog> _communicationLogs = [];
  List<CommunicationLog> get communicationLogs => _communicationLogs;

  // Notification count
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  // Whether a simulation API call is currently in flight
  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  // Last simulation result message (success or fallback)
  String? _lastSimulationMessage;
  String? get lastSimulationMessage => _lastSimulationMessage;

  /// Initialize provider with mock data
  AdminProvider() {
    loadMockData();
  }

  /// Load mock data
  void loadMockData() {
    _agentStatuses = AdminDataService.getAgentStatuses();
    _sensorReadings = AdminDataService.getSensorReadings();
    _sosRequests = AdminDataService.getSosRequests();
    _aidRequests = AdminDataService.getAidRequests();
    _incidentHistory = AdminDataService.getIncidentHistory();
    _safeCamps = AdminDataService.getSafeCamps();
    _communicationLogs = AdminDataService.getCommunicationLogs();
    _updateNotificationCount();
    notifyListeners();
  }

  /// Update notification count based on pending requests
  void _updateNotificationCount() {
    final pendingSos = _sosRequests.where((r) => r.status == SosStatus.pending).length;
    final pendingAid = _aidRequests.where((r) => r.status == AidStatus.pending).length;
    _notificationCount = pendingSos + pendingAid;
  }

  /// Simulate system status change
  void simulateStatusChange() {
    final statuses = SystemStatus.values;
    final currentIndex = statuses.indexOf(_systemStatus);
    _systemStatus = statuses[(currentIndex + 1) % statuses.length];
    notifyListeners();
  }

  /// Load a dummy scenario for a given disaster type (human-triggered simulation).
  /// This uses the local AdminDataService mock data and tailors one incident to the
  /// requested disaster type. Endpoints to fetch real backend data can be added later.
  void loadDummyScenario(String disasterType) {
    // Base mock data
    _agentStatuses = AdminDataService.getAgentStatuses();
    _sensorReadings = AdminDataService.getSensorReadings();
    _sosRequests = AdminDataService.getSosRequests();
    _aidRequests = AdminDataService.getAidRequests();
    _communicationLogs = AdminDataService.getCommunicationLogs();
    _safeCamps = AdminDataService.getSafeCamps();

    // Create a scenario-specific incident
    final lower = disasterType.toLowerCase();
    IncidentSeverity severity;
    // Use substring matching so UI labels like "Coastal Flood" or "Forest Fire"
    // map correctly to the intended severity.
    if (lower.contains('flood') || lower.contains('earthquake') || lower.contains('cyclone')) {
      severity = IncidentSeverity.critical;
    } else if (lower.contains('drought') || lower.contains('fire') || lower.contains('heat')) {
      severity = IncidentSeverity.high;
    } else {
      severity = IncidentSeverity.medium;
    }

    final status = IncidentStatus.ongoing;
    final now = DateTime.now();
    _currentDisasterType = disasterType;

    _incidentHistory = [
      IncidentHistory(
        id: 'SIM-${now.millisecondsSinceEpoch}',
        severity: severity,
        status: status,
        disasterType: disasterType,
        duration: 'Ongoing',
        responseTime: 'TBD',
        affectedCount: 0,
        evacuatedCount: 0,
        timestamp: now,
      ),
      ...AdminDataService.getIncidentHistory(),
    ];

    // Set system status based on severity
    if (severity == IncidentSeverity.critical) {
      _systemStatus = SystemStatus.critical;
    } else if (severity == IncidentSeverity.high) {
      _systemStatus = SystemStatus.degraded;
    } else {
      _systemStatus = SystemStatus.normal;
    }

    _updateNotificationCount();
    notifyListeners();
  }

  /// Trigger a simulation by calling the FastAPI backend.
  ///
  /// Sends a POST to `/simulate` with the [disasterType]. On a successful
  /// response the scenario is built from the API data; if the server is
  /// unreachable the app gracefully falls back to [loadDummyScenario].
  Future<void> runSimulation(String disasterType) async {
    _isSimulating = true;
    _lastSimulationMessage = null;
    notifyListeners();

    final result = await SimulationService().triggerSimulation(disasterType);

    if (result.success) {
      // ── Build scenario from API response ──────────────────────────────
      _agentStatuses = AdminDataService.getAgentStatuses();
      _sensorReadings = AdminDataService.getSensorReadings();
      _sosRequests = AdminDataService.getSosRequests();
      _aidRequests = AdminDataService.getAidRequests();
      _communicationLogs = AdminDataService.getCommunicationLogs();
      _safeCamps = AdminDataService.getSafeCamps();
      _currentDisasterType = result.disasterType;

      // Map severity string from API to enum
      IncidentSeverity severity;
      switch (result.severity?.toLowerCase()) {
        case 'critical':
          severity = IncidentSeverity.critical;
          break;
        case 'high':
          severity = IncidentSeverity.high;
          break;
        default:
          severity = IncidentSeverity.medium;
      }

      final now = DateTime.now();
      _incidentHistory = [
        IncidentHistory(
          id: 'API-${now.millisecondsSinceEpoch}',
          severity: severity,
          status: IncidentStatus.ongoing,
          disasterType: result.disasterType,
          duration: 'Ongoing',
          responseTime: result.responseTime ?? 'TBD',
          affectedCount: result.affectedCount ?? 0,
          evacuatedCount: result.evacuatedCount ?? 0,
          timestamp: now,
        ),
        ...AdminDataService.getIncidentHistory(),
      ];

      _systemStatus = severity == IncidentSeverity.critical
          ? SystemStatus.critical
          : severity == IncidentSeverity.high
              ? SystemStatus.degraded
              : SystemStatus.normal;

      _lastSimulationMessage =
          '${result.disasterType} simulation initiated via FastAPI';
    } else {
      // ── Fallback: use mock data ────────────────────────────────────────
      loadDummyScenario(disasterType);
      _lastSimulationMessage =
          '$disasterType simulation initiated (offline mode)';
    }

    _isSimulating = false;
    _updateNotificationCount();
    notifyListeners();
  }

  /// Number of recent SOS alerts
  int get sosAlertsCount => _sosRequests.length;

  /// Number of pending aid requests
  int get aidRequestsCount => _aidRequests.length;

  /// Provide AI suggestions as a simple map for the UI.
  /// This is a lightweight heuristic based on system status.
  Map<String, int> get aiSuggestions {
    final base = aiSuggestion; // a small base number
    switch (_systemStatus) {
      case SystemStatus.normal:
        return {
          'ambulances': 2 + base,
          'boats': 1 + (base ~/ 3),
          'foodPackets': 500 + (base * 50),
          'medicalKits': 50 + (base * 5),
        };
      case SystemStatus.degraded:
        return {
          'ambulances': 5 + base,
          'boats': 3 + (base ~/ 2),
          'foodPackets': 2000 + (base * 100),
          'medicalKits': 150 + (base * 10),
        };
      case SystemStatus.critical:
        return {
          'ambulances': 10 + base,
          'boats': 6 + base,
          'foodPackets': 5000 + (base * 200),
          'medicalKits': 400 + (base * 20),
        };
    }
  }

  /// Apply resource overrides provided by admin (human-in-the-loop).
  /// Records the override in the audit trail and triggers a simple recalculation.
  void applyResourceOverrides(Map<String, int> overrides) {
    final timestamp = DateTime.now().toIso8601String();
    final entry = '[$timestamp] Admin overrides: ${overrides.toString()}';
    _decisionAudit.insert(0, entry);
    _lastDecisionNote = entry;

    // Simple simulation: if admin reduces ambulances drastically, degrade status
    final ambulances = overrides['ambulances'];
    if (ambulances != null && ambulances < (aiSuggestion / 2) && _systemStatus == SystemStatus.normal) {
      _systemStatus = SystemStatus.degraded;
    }

    _updateNotificationCount();
    notifyListeners();
  }

  /// Get system status display text
  String get systemStatusText {
    switch (_systemStatus) {
      case SystemStatus.normal:
        return 'SYSTEM NORMAL';
      case SystemStatus.critical:
        return 'CRITICAL';
      case SystemStatus.degraded:
        return 'DEGRADED';
    }
  }

  /// Get system status color
  Color get systemStatusColor {
    switch (_systemStatus) {
      case SystemStatus.normal:
        return Colors.green;
      case SystemStatus.critical:
        return Colors.red;
      case SystemStatus.degraded:
        return Colors.orange;
    }
  }

  /// Dispatch rescue team for SOS request
  void dispatchRescueTeam(String sosId) {
    final index = _sosRequests.indexWhere((r) => r.id == sosId);
    if (index != -1) {
      _sosRequests[index] = _sosRequests[index].copyWith(
        status: SosStatus.dispatched,
        eta: '15 minutes',
      );
      _updateNotificationCount();
      notifyListeners();
    }
  }

  /// Dispatch aid for aid request
  void dispatchAid(String aidId) {
    final index = _aidRequests.indexWhere((r) => r.id == aidId);
    if (index != -1) {
      _aidRequests[index] = _aidRequests[index].copyWith(
        status: AidStatus.dispatched,
      );
      _updateNotificationCount();
      notifyListeners();
    }
  }

  /// Add new safe camp
  void addSafeCamp(SafeCamp camp) {
    _safeCamps.add(camp);
    notifyListeners();
  }

  /// Delete safe camp
  void deleteSafeCamp(String campId) {
    _safeCamps.removeWhere((c) => c.id == campId);
    notifyListeners();
  }

  /// Get total sessions count
  int get totalSessions => _incidentHistory.length;

  // --- AI Decisioning (Human-in-the-loop) ---
  final List<String> _decisionAudit = [];
  List<String> get decisionAudit => List.unmodifiable(_decisionAudit);

  String? _lastDecisionNote;
  String? get lastDecisionNote => _lastDecisionNote;

  /// Simple AI suggestion based on system status
  int get aiSuggestion {
    switch (_systemStatus) {
      case SystemStatus.normal:
        return 0;
      case SystemStatus.degraded:
        return 5;
      case SystemStatus.critical:
        return 10;
    }
  }

  /// Apply an admin override to the AI suggestion and create an audit trail.
  void applyAiSuggestionOverride(int overriddenValue) {
    final suggestion = aiSuggestion;
    final timestamp = DateTime.now().toIso8601String();
    final entry = '[$timestamp] AI suggested $suggestion ambulances — Admin overrode to $overriddenValue';
    _decisionAudit.insert(0, entry);
    _lastDecisionNote = entry;

    // Placeholder for recalculation: if admin reduces resources below suggestion,
    // escalate status to degraded; if admin increases above suggestion and system
    // was degraded, mark as normal — this simulates a decision agent recalculation.
    if (overriddenValue < suggestion && _systemStatus == SystemStatus.normal) {
      _systemStatus = SystemStatus.degraded;
    } else if (overriddenValue >= suggestion && _systemStatus == SystemStatus.degraded) {
      _systemStatus = SystemStatus.normal;
    }

    _updateNotificationCount();
    notifyListeners();
  }
}
