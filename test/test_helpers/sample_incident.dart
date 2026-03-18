import 'package:CERCA/models/admin/aid_request_admin.dart';
import 'package:CERCA/models/admin/communication_log.dart';
import 'package:CERCA/models/admin/disaster_area.dart';
import 'package:CERCA/models/admin/disaster_event.dart';
import 'package:CERCA/models/admin/incident_history.dart';
import 'package:CERCA/models/admin/safe_camp.dart';
import 'package:CERCA/models/admin/sensor_reading.dart';
import 'package:CERCA/models/admin/sos_request.dart';

DisasterArea buildSampleArea() {
  return DisasterArea(
    id: 'AREA-20260318-TEST',
    centerLat: 12.9716,
    centerLon: 77.5946,
    redRadiusM: 300,
    warningRadiusM: 600,
    greenRadiusM: 900,
    controllableRadiusM: 1200,
    createdAt: DateTime(2026, 3, 18, 10),
  );
}

DisasterEvent buildSampleSimulation() {
  return DisasterEvent(
    id: 'SIM-20260318100000-TEST',
    areaId: 'AREA-20260318-TEST',
    type: 'Flood',
    centerLat: 12.9716,
    centerLon: 77.5946,
    radiusM: 1800,
    severity: DisasterSeverity.high,
    createdAt: DateTime(2026, 3, 18, 10),
    status: DisasterStatus.active,
    totalCitizens: 24,
    generatedCitizens: 12,
  );
}

IncidentHistory buildSampleIncident() {
  return IncidentHistory(
    id: 'INC-20260318123000-TEST',
    severity: IncidentSeverity.high,
    status: IncidentStatus.resolved,
    disasterType: 'Flood',
    startedAt: DateTime(2026, 3, 18, 10),
    closedAt: DateTime(2026, 3, 18, 12, 30),
    area: const IncidentAreaSnapshot(
      areaId: 'AREA-20260318-TEST',
      centerLat: 12.9716,
      centerLon: 77.5946,
      redRadiusM: 1800,
      warningRadiusM: 2200,
      greenRadiusM: 2600,
      controllableRadiusM: 3200,
      summaryLabel: '2200 m warning radius around AREA-20260318-TEST',
      mapSummary:
          'Expanded demo rings remained active until the area was archived.',
    ),
    affectedCount: 24,
    evacuatedCount: 14,
    totalSosLogs: 4,
    pendingSosCount: 1,
    dispatchedSosCount: 3,
    totalAidRequests: 3,
    pendingAidCount: 1,
    dispatchedAidCount: 2,
    totalDispatched: 5,
    safeCampCount: 2,
    wasSimulation: true,
    simulationId: 'SIM-20260318100000-TEST',
    simulatedCitizens: 24,
    currentRisk: 'high',
    alertMessage: 'Demo alert',
    finalOutcomeSummary:
        'Area AREA-20260318-TEST was closed after dispatching 3 of 4 SOS cases and 2 of 3 aid requests.',
    requestedResources: const {'Water': 2, 'Food': 1},
    aiResourceSnapshot: const {
      'ambulances': 12,
      'boats': 8,
      'foodPackets': 5000,
      'medicalKits': 200,
    },
    keyActions: const [
      'Simulation started for evaluator mode.',
      'Rescue team dispatched for SOS-001.',
      'Area closure completed and archived.',
    ],
    sosLogs: [
      SosRequest(
        id: 'SOS-001',
        status: SosStatus.dispatched,
        callerName: 'Citizen One',
        phoneNumber: '9999999999',
        address: 'Main Street',
        latitude: 12.9716,
        longitude: 77.5946,
        timestamp: DateTime(2026, 3, 18, 10, 5),
        areaId: 'AREA-20260318-TEST',
        insideControllableZone: true,
      ),
    ],
    aidLogs: [
      AidRequestAdmin(
        id: 'AID-001',
        priority: AidPriority.high,
        status: AidStatus.dispatched,
        requesterName: 'Citizen Group',
        resources: const ['Water', 'Food'],
        peopleCount: 12,
        location: 'Shelter A',
        latitude: 12.9717,
        longitude: 77.5947,
        timestamp: DateTime(2026, 3, 18, 10, 12),
        areaId: 'AREA-20260318-TEST',
        insideControllableZone: true,
      ),
    ],
    safeCamps: [
      SafeCamp(
        id: 'SC-001',
        name: 'Central Camp',
        status: CampStatus.active,
        latitude: 12.9718,
        longitude: 77.5948,
        capacity: 150,
        currentOccupancy: 90,
        areaId: 'AREA-20260318-TEST',
      ),
    ],
    communicationLogs: [
      CommunicationLog(
        id: 'LOG-001',
        type: CommunicationLogType.alert,
        message: 'Twilio alert attempted for the affected area.',
        timestamp: DateTime(2026, 3, 18, 10, 1),
        areaId: 'AREA-20260318-TEST',
      ),
    ],
    weatherHistory: [
      IncidentWeatherSnapshot(
        timestamp: DateTime(2026, 3, 18, 10, 2),
        riskLevel: 'high',
        condition: 'Clear',
        summary: 'Threshold override forced a demo high-risk state.',
        readings: [
          SensorReading(
            type: 'Temperature',
            value: 30,
            unit: 'C',
            trend: SensorTrend.stable,
            timestamp: DateTime(2026, 3, 18, 10, 2),
          ),
        ],
      ),
    ],
    decisionHistory: [
      IncidentDecisionEntry(
        timestamp: DateTime(2026, 3, 18, 10, 0, 30),
        actor: 'AI Decision Agent',
        type: 'ai_suggestion',
        summary: 'Increase boats and ambulances for the flood response.',
        resourceSnapshot: const {'boats': 8, 'ambulances': 12},
      ),
    ],
  );
}
