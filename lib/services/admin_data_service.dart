import '../models/admin/agent_status.dart';
import '../models/admin/sensor_reading.dart';
import '../models/admin/sos_request.dart';
import '../models/admin/aid_request_admin.dart';
import '../models/admin/incident_history.dart';
import '../models/admin/safe_camp.dart';
import '../models/admin/communication_log.dart';

/// Service for generating mock data for admin dashboard
class AdminDataService {
  /// Get mock agent status data
  static List<AgentStatus> getAgentStatuses() {
    final now = DateTime.now();
    return [
      AgentStatus(
        name: 'Data Agent',
        status: AgentStatusType.online,
        lastUpdate: now.subtract(const Duration(seconds: 5)),
      ),
      AgentStatus(
        name: 'Decision Agent',
        status: AgentStatusType.online,
        lastUpdate: now.subtract(const Duration(seconds: 3)),
      ),
      AgentStatus(
        name: 'Communication Agent',
        status: AgentStatusType.standby,
        lastUpdate: now.subtract(const Duration(minutes: 2)),
      ),
      AgentStatus(
        name: 'Trigger Agent',
        status: AgentStatusType.online,
        lastUpdate: now.subtract(const Duration(seconds: 10)),
      ),
      AgentStatus(
        name: 'Orchestrator',
        status: AgentStatusType.online,
        lastUpdate: now.subtract(const Duration(seconds: 1)),
      ),
    ];
  }

  /// Get mock sensor reading data
  static List<SensorReading> getSensorReadings() {
    final now = DateTime.now();
    return [
      SensorReading(
        type: 'Water Level',
        value: 3.2,
        unit: 'ft',
        trend: SensorTrend.up,
        timestamp: now,
      ),
      SensorReading(
        type: 'Wind Speed',
        value: 45,
        unit: 'km/h',
        trend: SensorTrend.stable,
        timestamp: now,
      ),
      SensorReading(
        type: 'Temperature',
        value: 28,
        unit: '°C',
        trend: SensorTrend.down,
        timestamp: now,
      ),
      SensorReading(
        type: 'Rainfall',
        value: 5,
        unit: 'mm',
        trend: SensorTrend.up,
        timestamp: now,
      ),
    ];
  }

  /// Get mock SOS requests
  static List<SosRequest> getSosRequests() {
    final now = DateTime.now();
    return [
      SosRequest(
        id: 'SOS-001',
        status: SosStatus.pending,
        callerName: 'Rajesh Kumar',
        phoneNumber: '+91 98765 43210',
        address: '123 Main Street, Sector 15, Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      SosRequest(
        id: 'SOS-002',
        status: SosStatus.dispatched,
        callerName: 'Priya Sharma',
        phoneNumber: '+91 87654 32109',
        address: '456 Park Avenue, Andheri West, Mumbai',
        latitude: 19.1136,
        longitude: 72.8697,
        timestamp: now.subtract(const Duration(minutes: 15)),
        eta: '10 minutes',
      ),
      SosRequest(
        id: 'SOS-003',
        status: SosStatus.pending,
        callerName: 'Amit Patel',
        phoneNumber: '+91 76543 21098',
        address: '789 Lake Road, Powai, Mumbai',
        latitude: 19.1197,
        longitude: 72.9059,
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  /// Get mock aid requests
  static List<AidRequestAdmin> getAidRequests() {
    final now = DateTime.now();
    return [
      AidRequestAdmin(
        id: 'AID-001',
        priority: AidPriority.high,
        status: AidStatus.pending,
        requesterName: 'Sunita Desai',
        resources: ['Food', 'Water', 'Medical'],
        peopleCount: 25,
        location: 'Community Hall, Dharavi',
        latitude: 19.0433,
        longitude: 72.8636,
        timestamp: now.subtract(const Duration(minutes: 10)),
      ),
      AidRequestAdmin(
        id: 'AID-002',
        priority: AidPriority.medium,
        status: AidStatus.dispatched,
        requesterName: 'Vikram Singh',
        resources: ['Blankets', 'Food'],
        peopleCount: 15,
        location: 'School Building, Bandra',
        latitude: 19.0596,
        longitude: 72.8295,
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      AidRequestAdmin(
        id: 'AID-003',
        priority: AidPriority.low,
        status: AidStatus.pending,
        requesterName: 'Meera Nair',
        resources: ['Water'],
        peopleCount: 8,
        location: 'Apartment Complex, Juhu',
        latitude: 19.1075,
        longitude: 72.8263,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  /// Get mock incident history
  static List<IncidentHistory> getIncidentHistory() {
    return [
      IncidentHistory(
        id: 'INC-001',
        severity: IncidentSeverity.critical,
        status: IncidentStatus.resolved,
        disasterType: 'Flood',
        duration: '3 days',
        responseTime: '45 minutes',
        affectedCount: 5000,
        evacuatedCount: 3500,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
      ),
      IncidentHistory(
        id: 'INC-002',
        severity: IncidentSeverity.high,
        status: IncidentStatus.resolved,
        disasterType: 'Cyclone',
        duration: '2 days',
        responseTime: '30 minutes',
        affectedCount: 3000,
        evacuatedCount: 2500,
        timestamp: DateTime.now().subtract(const Duration(days: 60)),
      ),
      IncidentHistory(
        id: 'INC-003',
        severity: IncidentSeverity.high,
        status: IncidentStatus.resolved,
        disasterType: 'Landslide',
        duration: '1 day',
        responseTime: '20 minutes',
        affectedCount: 1500,
        evacuatedCount: 1200,
        timestamp: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  /// Get mock safe camps
  static List<SafeCamp> getSafeCamps() {
    return [
      SafeCamp(
        id: 'SC-001',
        name: 'Central Community Shelter',
        status: CampStatus.active,
        latitude: 19.0760,
        longitude: 72.8777,
        capacity: 500,
        currentOccupancy: 320,
      ),
      SafeCamp(
        id: 'SC-002',
        name: 'North District Relief Center',
        status: CampStatus.active,
        latitude: 19.1136,
        longitude: 72.8697,
        capacity: 300,
        currentOccupancy: 150,
      ),
      SafeCamp(
        id: 'SC-003',
        name: 'East Zone Emergency Camp',
        status: CampStatus.active,
        latitude: 19.1197,
        longitude: 72.9059,
        capacity: 400,
        currentOccupancy: 280,
      ),
    ];
  }

  /// Get mock communication logs
  static List<CommunicationLog> getCommunicationLogs() {
    final now = DateTime.now();
    return [
      CommunicationLog(
        id: 'LOG-001',
        type: CommunicationLogType.sms,
        message: 'SMS sent to 500 citizens in Sector 4',
        timestamp: now.subtract(const Duration(minutes: 55)),
      ),
      CommunicationLog(
        id: 'LOG-002',
        type: CommunicationLogType.alert,
        message: 'SOS Alert received from Ramesh Kumar',
        timestamp: now.subtract(const Duration(minutes: 57)),
      ),
      CommunicationLog(
        id: 'LOG-003',
        type: CommunicationLogType.evacuation,
        message: 'Evacuation notice dispatched to River Basin',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      CommunicationLog(
        id: 'LOG-004',
        type: CommunicationLogType.resource,
        message: 'Resource request acknowledged - AID-101',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 2)),
      ),
    ];
  }
}
