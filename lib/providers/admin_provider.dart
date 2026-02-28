import 'package:flutter/material.dart';
import '../models/admin/agent_status.dart';
import '../models/admin/sensor_reading.dart';
import '../models/admin/sos_request.dart';
import '../models/admin/aid_request_admin.dart';
import '../models/admin/incident_history.dart';
import '../models/admin/safe_camp.dart';
import '../models/admin/communication_log.dart';
import '../services/admin_data_service.dart';

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

  // Communication logs
  List<CommunicationLog> _communicationLogs = [];
  List<CommunicationLog> get communicationLogs => _communicationLogs;

  // Notification count
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

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
}
