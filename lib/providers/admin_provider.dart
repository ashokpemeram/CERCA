import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/assessment_result.dart';
import '../models/admin/agent_status.dart';
import '../models/admin/sensor_reading.dart';
import '../models/admin/sos_request.dart';
import '../models/admin/aid_request_admin.dart';
import '../models/admin/incident_history.dart';
import '../models/admin/safe_camp.dart';
import '../models/admin/communication_log.dart';
import '../models/admin/disaster_area.dart';
import '../models/admin/disaster_event.dart';
import '../services/admin_data_service.dart';
import '../services/api_service.dart';
import '../services/disaster_area_service.dart';
import '../models/admin/simulation_sms_status.dart';
import 'assessment_provider.dart';

/// System status enumeration
enum SystemStatus { normal, critical, degraded }

/// Provider for admin dashboard state management
class AdminProvider with ChangeNotifier {
  final ApiService _apiService;
  AssessmentProvider? _assessmentProvider;
  // System status
  SystemStatus _systemStatus = SystemStatus.normal;
  SystemStatus get systemStatus => _systemStatus;

  // Agent statuses
  List<AgentStatus> _agentStatuses = [];
  List<AgentStatus> get agentStatuses => _agentStatuses;

  // Sensor readings
  List<SensorReading> _sensorReadings = [];
  List<SensorReading> get sensorReadings => _sensorReadings;
  final Map<String, List<IncidentWeatherSnapshot>> _weatherHistoryByArea = {};
  final Map<String, List<IncidentDecisionEntry>> _decisionHistoryByArea = {};

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

  // Disaster areas
  List<DisasterArea> _activeAreas = [];
  List<DisasterArea> _archivedAreas = [];
  List<DisasterArea> get activeAreas => _activeAreas;
  List<DisasterArea> get archivedAreas => _archivedAreas;

  // Admin-area ownership maps
  Map<String, String> _adminToArea = {};
  Map<String, String> _areaToAdmin = {};

  // Current admin session
  String? _loggedInEmail;
  String? _loggedInAreaId;
  String? _loginError;
  final Set<String> _dispatchingSosIds = {};
  final Set<String> _dispatchingAidIds = {};
  final Set<String> _closingAreaIds = {};
  String? get loggedInEmail => _loggedInEmail;
  String? get loggedInAreaId => _loggedInAreaId;
  String? get loginError => _loginError;
  bool isDispatchingSos(String id) => _dispatchingSosIds.contains(id);
  bool isDispatchingAid(String id) => _dispatchingAidIds.contains(id);
  bool isClosingArea(String id) => _closingAreaIds.contains(id);

  DisasterArea? get currentArea {
    final areaId = _loggedInAreaId;
    if (areaId == null) return null;
    for (final area in _activeAreas) {
      if (area.id == areaId) return area;
    }
    return null;
  }

  // Communication logs
  List<CommunicationLog> _communicationLogs = [];
  List<CommunicationLog> get communicationLogs => _communicationLogs;

  // Notification count
  int _notificationCount = 0;
  int get notificationCount => _notificationCount;

  // Current disaster type (set during simulation)
  String? _currentDisasterType;
  String? get currentDisasterType => _currentDisasterType;

  // Disaster simulation state
  DisasterEvent? _activeSimulation;
  final List<DisasterEvent> _simulationHistory = [];
  Timer? _simulationTimer;
  final Set<String> _simulationAreaIds = {};
  final Random _random = Random();
  int _simulationSequence = 0;
  SimulationSmsStatus? _lastSimulationSmsStatus;

  DisasterEvent? get activeSimulation => _activeSimulation;
  List<DisasterEvent> get simulationHistory => _simulationHistory;
  bool get isSimulationRunning => _activeSimulation?.isActive ?? false;
  SimulationSmsStatus? get lastSimulationSmsStatus => _lastSimulationSmsStatus;

  // AI suggestions for resource allocation
  Map<String, dynamic> _aiSuggestions = {
    'ambulances': 12,
    'boats': 8,
    'foodPackets': 5000,
    'medicalKits': 200,
  };
  Map<String, dynamic> get aiSuggestions => _aiSuggestions;

  // Decision audit trail
  final List<String> _decisionAudit = [];
  List<String> get decisionAudit => _decisionAudit;

  // Convenience getters for alert counts
  int get sosAlertsCount =>
      _sosRequests.where((r) => r.status == SosStatus.pending).length;
  int get aidRequestsCount =>
      _aidRequests.where((r) => r.status == AidStatus.pending).length;

  /// Initialize provider with mock data
  AdminProvider({
    AssessmentProvider? assessmentProvider,
    ApiService? apiService,
  }) : _assessmentProvider = assessmentProvider,
       _apiService = apiService ?? ApiService() {
    loadMockData();
    unawaited(refreshIncidentHistoryFromBackend());
  }

  void setAssessmentProvider(AssessmentProvider provider) {
    _assessmentProvider = provider;
  }

  /// Load mock data
  void loadMockData() {
    _agentStatuses = AdminDataService.getAgentStatuses();
    _sensorReadings = AdminDataService.getSensorReadings();
    _sosRequests = AdminDataService.getSosRequests();
    _aidRequests = AdminDataService.getAidRequests();
    _incidentHistory = [];
    _safeCamps = AdminDataService.getSafeCamps();
    _communicationLogs = AdminDataService.getCommunicationLogs();
    _updateNotificationCount();
    notifyListeners();
  }

  /// Load active areas from backend
  Future<void> refreshAreasFromBackend() async {
    final response = await _apiService.fetchActiveAreas();
    if (response.success && response.data != null) {
      _activeAreas = response.data!;
      _syncLoginToActiveAreas();
      notifyListeners();
    }
  }

  Future<void> refreshIncidentHistoryFromBackend() async {
    final response = await _apiService.fetchIncidentHistory();
    if (response.success && response.data != null) {
      _incidentHistory = response.data!;
      notifyListeners();
    }
  }

  /// Load aid requests for the currently logged-in area from backend
  Future<void> refreshAidRequestsForLoggedInArea() async {
    final areaId = _loggedInAreaId;
    if (areaId == null) return;

    final response = await _apiService.fetchAidRequestsForArea(areaId);
    if (response.success && response.data != null) {
      _aidRequests = response.data!;
      _updateNotificationCount();
      notifyListeners();
    }
  }

  /// Load SOS requests for the currently logged-in area from backend
  Future<void> refreshSosRequestsForLoggedInArea() async {
    final areaId = _loggedInAreaId;
    if (areaId == null) return;

    final response = await _apiService.fetchSosRequestsForArea(areaId);
    if (response.success && response.data != null) {
      _sosRequests = response.data!;
      _updateNotificationCount();
      notifyListeners();
    }
  }

  /// Update notification count based on pending requests
  void _updateNotificationCount() {
    final pendingSos = _sosRequests
        .where((r) => r.status == SosStatus.pending)
        .length;
    final pendingAid = _aidRequests
        .where((r) => r.status == AidStatus.pending)
        .length;
    _notificationCount = pendingSos + pendingAid;
  }

  /// Recompute disaster areas and reassign area metadata on all incidents
  void recomputeAreasFromIncidents() {
    final existingIds = _archivedAreas.map((a) => a.id).toSet();
    _activeAreas = DisasterAreaService.computeAreas(
      _sosRequests,
      _aidRequests,
      existingAreaIds: existingIds,
    );
    _assignAreaMetadata();
    _syncLoginToActiveAreas();
    _updateNotificationCount();
    _logActiveAreas();
    notifyListeners();
  }

  AreaRouteResult routeToArea(double lat, double lon) {
    return DisasterAreaService.routeToArea(lat, lon, _activeAreas);
  }

  List<SosRequest> get sosRequestsForCurrentArea {
    final areaId = _loggedInAreaId;
    if (areaId == null) return [];
    return _sosRequests.where((r) => r.areaId == areaId).toList();
  }

  List<SosRequest> get sosRequestsForAdminView {
    final simulation = _activeSimulation;
    if (simulation != null) {
      return _sosRequests
          .where(
            (r) => r.source == 'simulation' && r.disasterId == simulation.id,
          )
          .toList();
    }
    return sosRequestsForCurrentArea;
  }

  List<AidRequestAdmin> get aidRequestsForCurrentArea {
    final areaId = _loggedInAreaId;
    if (areaId == null) return [];
    return _aidRequests.where((r) => r.areaId == areaId).toList();
  }

  List<SafeCamp> get safeCampsForCurrentArea {
    final areaId = _loggedInAreaId;
    if (areaId == null) return [];
    return _safeCamps.where((c) => c.areaId == areaId).toList();
  }

  List<Object> get outsideBoundaryItemsForCurrentArea {
    final areaId = _loggedInAreaId;
    if (areaId == null) return [];
    return [
      ..._sosRequests.where(
        (r) => r.areaId == areaId && !r.insideControllableZone,
      ),
      ..._aidRequests.where(
        (r) => r.areaId == areaId && !r.insideControllableZone,
      ),
    ];
  }

  AreaRouteResult intakeSosRequest(SosRequest request) {
    if (request.source == 'simulation' && request.areaId.isNotEmpty) {
      final updated = request.copyWith(
        areaId: request.areaId,
        insideControllableZone: true,
      );
      _sosRequests.add(updated);
      _updateNotificationCount();
      notifyListeners();
      return AreaRouteResult(
        areaId: request.areaId,
        insideControllable: true,
        distanceM: 0,
      );
    }

    final createdArea = _createAreaForSos(
      request.latitude,
      request.longitude,
      trackForSimulation: request.source == 'simulation',
    );
    final updated = request.copyWith(
      areaId: createdArea.id,
      insideControllableZone: true,
    );
    _sosRequests.add(updated);
    _updateNotificationCount();
    _logActiveAreas();
    notifyListeners();
    return AreaRouteResult(
      areaId: createdArea.id,
      insideControllable: true,
      distanceM: 0,
    );
  }

  AreaRouteResult intakeAidRequest(AidRequestAdmin request) {
    final route = routeToArea(request.latitude, request.longitude);
    final updated = request.copyWith(
      areaId: route.areaId,
      insideControllableZone: route.insideControllable,
    );
    _aidRequests.add(updated);
    _updateNotificationCount();
    notifyListeners();
    return route;
  }

  bool loginToArea(String email, String areaId) {
    final normalizedEmail = email.trim().toLowerCase();
    DisasterArea? activeArea;
    for (final area in _activeAreas) {
      if (area.isActive && area.id == areaId) {
        activeArea = area;
        break;
      }
    }

    if (activeArea == null) {
      final wasArchived = _archivedAreas.any((a) => a.id == areaId);
      _loginError = wasArchived
          ? 'Area is no longer active'
          : 'Area not found or inactive';
      notifyListeners();
      return false;
    }

    final existingAreaForAdmin = _adminToArea[normalizedEmail];
    if (existingAreaForAdmin != null && existingAreaForAdmin != areaId) {
      _loginError = 'This admin is already bound to another area';
      notifyListeners();
      return false;
    }

    final existingAdminForArea = _areaToAdmin[areaId];
    if (existingAdminForArea != null &&
        existingAdminForArea != normalizedEmail) {
      _loginError = 'Area already claimed by another admin';
      notifyListeners();
      return false;
    }

    _adminToArea[normalizedEmail] = areaId;
    _areaToAdmin[areaId] = normalizedEmail;
    _loggedInEmail = normalizedEmail;
    _loggedInAreaId = areaId;
    _loginError = null;

    // Fetch live weather immediately for this area
    fetchLiveWeatherForArea();
    unawaited(restoreSimulationForCurrentArea());

    notifyListeners();
    return true;
  }

  void logoutAdmin() {
    _clearLoginState(releaseArea: true);
    notifyListeners();
  }

  void _upsertIncidentHistory(IncidentHistory incident) {
    _incidentHistory.removeWhere((entry) => entry.id == incident.id);
    _incidentHistory.insert(0, incident);
  }

  Map<String, int> _currentAiSuggestionSnapshot() {
    final snapshot = <String, int>{};
    _aiSuggestions.forEach((key, value) {
      snapshot[key] = value is int ? value : int.tryParse('$value') ?? 0;
    });
    return snapshot;
  }

  void _recordDecision({
    required String areaId,
    required String actor,
    required String type,
    required String summary,
    Map<String, int>? resourceSnapshot,
    DateTime? timestamp,
  }) {
    final entry = IncidentDecisionEntry(
      timestamp: timestamp ?? DateTime.now(),
      actor: actor,
      type: type,
      summary: summary,
      resourceSnapshot: resourceSnapshot ?? const {},
    );
    final history = _decisionHistoryByArea.putIfAbsent(areaId, () => []);
    history.insert(0, entry);
    _decisionAudit.insert(
      0,
      '[${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}] ${entry.summary}',
    );
  }

  void _recordCommunication({
    required String areaId,
    required CommunicationLogType type,
    required String message,
    DateTime? timestamp,
  }) {
    _communicationLogs.insert(
      0,
      CommunicationLog(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        message: message,
        timestamp: timestamp ?? DateTime.now(),
        areaId: areaId,
      ),
    );
  }

  void _recordWeatherSnapshot({
    required String areaId,
    required List<SensorReading> readings,
    required String riskLevel,
    required String condition,
    required String summary,
    DateTime? timestamp,
  }) {
    if (readings.isEmpty) {
      return;
    }

    final history = _weatherHistoryByArea.putIfAbsent(areaId, () => []);
    final recordedAt = timestamp ?? DateTime.now();
    final lastEntry = history.isNotEmpty ? history.first : null;
    if (lastEntry != null &&
        recordedAt.difference(lastEntry.timestamp).inSeconds < 10) {
      return;
    }

    history.insert(
      0,
      IncidentWeatherSnapshot(
        timestamp: recordedAt,
        riskLevel: riskLevel,
        condition: condition,
        summary: summary,
        readings: readings
            .map(
              (reading) => SensorReading(
                type: reading.type,
                value: reading.value,
                unit: reading.unit,
                trend: reading.trend,
                timestamp: reading.timestamp,
              ),
            )
            .toList(),
      ),
    );
  }

  IncidentSeverity _deriveIncidentSeverity(
    String? riskLevel,
    DisasterEvent? simulation,
    int totalSos,
    int affectedCount,
  ) {
    if (simulation?.severity == DisasterSeverity.high &&
        (totalSos >= 10 || affectedCount >= 50)) {
      return IncidentSeverity.critical;
    }
    switch ((riskLevel ?? '').toLowerCase()) {
      case 'high':
        return totalSos >= 10 || affectedCount >= 50
            ? IncidentSeverity.critical
            : IncidentSeverity.high;
      case 'medium':
        return IncidentSeverity.medium;
      default:
        if (simulation?.severity == DisasterSeverity.high) {
          return IncidentSeverity.high;
        }
        return IncidentSeverity.medium;
    }
  }

  DateTime _deriveSessionStartTime(
    DisasterArea area,
    List<SosRequest> sosLogs,
    List<AidRequestAdmin> aidLogs,
    List<SafeCamp> camps,
    List<IncidentWeatherSnapshot> weatherHistory,
    List<IncidentDecisionEntry> decisions,
    List<CommunicationLog> communications,
    DisasterEvent? simulation,
  ) {
    final candidates = <DateTime>[
      area.createdAt,
      ...sosLogs.map((entry) => entry.timestamp),
      ...aidLogs.map((entry) => entry.timestamp),
      ...weatherHistory.map((entry) => entry.timestamp),
      ...decisions.map((entry) => entry.timestamp),
      ...communications.map((entry) => entry.timestamp),
    ];
    if (simulation != null) {
      candidates.add(simulation.createdAt);
    }
    if (camps.isNotEmpty) {
      candidates.add(area.createdAt);
    }
    candidates.sort();
    return candidates.first;
  }

  Map<String, int> _buildRequestedResources(List<AidRequestAdmin> aidLogs) {
    final requested = <String, int>{};
    for (final request in aidLogs) {
      for (final resource in request.resources) {
        requested.update(resource, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return requested;
  }

  List<String> _buildKeyActions(
    List<IncidentDecisionEntry> decisions,
    List<CommunicationLog> communications,
  ) {
    final combined = <MapEntry<DateTime, String>>[
      ...decisions.map((entry) => MapEntry(entry.timestamp, entry.summary)),
      ...communications.map(
        (entry) => MapEntry(entry.timestamp, entry.message),
      ),
    ]..sort((a, b) => a.key.compareTo(b.key));

    return combined
        .map((entry) => entry.value)
        .where((value) => value.trim().isNotEmpty)
        .toList();
  }

  String _buildFinalOutcomeSummary({
    required DisasterArea area,
    required int totalSosLogs,
    required int dispatchedSosCount,
    required int totalAidRequests,
    required int dispatchedAidCount,
    required int safeCampCount,
    required int evacuatedCount,
  }) {
    return 'Area ${area.id} was closed after dispatching '
        '$dispatchedSosCount of $totalSosLogs SOS cases and '
        '$dispatchedAidCount of $totalAidRequests aid requests. '
        '$safeCampCount safe camps supported evacuation for $evacuatedCount people.';
  }

  IncidentHistory _buildArchivedIncident(DisasterArea area) {
    final areaId = area.id;
    final closedAt = area.closedAt ?? DateTime.now();
    final sosLogs = _sosRequests
        .where((entry) => entry.areaId == areaId)
        .toList();
    final aidLogs = _aidRequests
        .where((entry) => entry.areaId == areaId)
        .toList();
    final camps = _safeCamps.where((entry) => entry.areaId == areaId).toList();
    final scopedCommunications = _communicationLogs
        .where((entry) => entry.areaId == areaId)
        .toList();
    final communications =
        (scopedCommunications.isNotEmpty
                ? scopedCommunications
                : _communicationLogs.where((entry) => entry.areaId == null))
            .toList();
    final decisions = List<IncidentDecisionEntry>.from(
      _decisionHistoryByArea[areaId] ?? const <IncidentDecisionEntry>[],
    );
    final weatherHistory = List<IncidentWeatherSnapshot>.from(
      _weatherHistoryByArea[areaId] ?? const <IncidentWeatherSnapshot>[],
    );
    final simulation = _activeSimulation?.areaId == areaId
        ? _activeSimulation
        : null;
    final assessment = _assessmentProvider?.result;

    if (weatherHistory.isEmpty &&
        currentArea?.id == areaId &&
        _sensorReadings.isNotEmpty) {
      _recordWeatherSnapshot(
        areaId: areaId,
        readings: _sensorReadings,
        riskLevel:
            assessment?.weatherRiskLevel ??
            assessment?.overallRisk ??
            'unknown',
        condition: assessment?.weatherCondition ?? 'Latest weather snapshot',
        summary: 'Final weather snapshot captured at area close.',
        timestamp: closedAt,
      );
    }

    final updatedWeatherHistory = List<IncidentWeatherSnapshot>.from(
      _weatherHistoryByArea[areaId] ?? weatherHistory,
    );
    final startedAt = _deriveSessionStartTime(
      area,
      sosLogs,
      aidLogs,
      camps,
      updatedWeatherHistory,
      decisions,
      communications,
      simulation,
    );
    final dispatchedSosCount = sosLogs
        .where((entry) => entry.status == SosStatus.dispatched)
        .length;
    final pendingSosCount = sosLogs.length - dispatchedSosCount;
    final dispatchedAidCount = aidLogs
        .where((entry) => entry.status == AidStatus.dispatched)
        .length;
    final pendingAidCount = aidLogs.length - dispatchedAidCount;
    final totalDispatched = dispatchedSosCount + dispatchedAidCount;
    final affectedCount =
        simulation?.totalCitizens ??
        aidLogs.fold<int>(0, (count, request) => count + request.peopleCount);
    final evacuatedCount = camps.fold<int>(
      0,
      (count, camp) => count + camp.currentOccupancy,
    );
    final severity = _deriveIncidentSeverity(
      assessment?.overallRisk,
      simulation,
      sosLogs.length,
      affectedCount,
    );

    return IncidentHistory(
      id: 'INC-${DateTime.now().millisecondsSinceEpoch}',
      severity: severity,
      status: IncidentStatus.resolved,
      disasterType: simulation?.type ?? _currentDisasterType ?? 'Disaster',
      startedAt: startedAt,
      closedAt: closedAt,
      area: IncidentAreaSnapshot(
        areaId: area.id,
        centerLat: area.centerLat,
        centerLon: area.centerLon,
        redRadiusM: area.redRadiusM,
        warningRadiusM: area.warningRadiusM,
        greenRadiusM: area.greenRadiusM,
        controllableRadiusM: area.controllableRadiusM,
        createdAt: area.createdAt,
        closedAt: closedAt,
        summaryLabel:
            '${area.warningRadiusM.toStringAsFixed(0)} m warning radius around ${area.id}',
        mapSummary:
            'Red ${area.redRadiusM.toStringAsFixed(0)} m, warning ${area.warningRadiusM.toStringAsFixed(0)} m, green ${area.greenRadiusM.toStringAsFixed(0)} m.',
      ),
      affectedCount: affectedCount,
      evacuatedCount: evacuatedCount,
      totalSosLogs: sosLogs.length,
      pendingSosCount: pendingSosCount,
      dispatchedSosCount: dispatchedSosCount,
      totalAidRequests: aidLogs.length,
      pendingAidCount: pendingAidCount,
      dispatchedAidCount: dispatchedAidCount,
      totalDispatched: totalDispatched,
      safeCampCount: camps.length,
      wasSimulation: simulation != null,
      simulationId: simulation?.id,
      simulatedCitizens: simulation?.totalCitizens ?? 0,
      currentRisk: assessment?.overallRisk,
      alertMessage: assessment?.alertMessage,
      finalOutcomeSummary: _buildFinalOutcomeSummary(
        area: area,
        totalSosLogs: sosLogs.length,
        dispatchedSosCount: dispatchedSosCount,
        totalAidRequests: aidLogs.length,
        dispatchedAidCount: dispatchedAidCount,
        safeCampCount: camps.length,
        evacuatedCount: evacuatedCount,
      ),
      requestedResources: _buildRequestedResources(aidLogs),
      aiResourceSnapshot: _currentAiSuggestionSnapshot(),
      keyActions: _buildKeyActions(decisions, communications),
      sosLogs: sosLogs,
      aidLogs: aidLogs,
      safeCamps: camps,
      communicationLogs: communications,
      weatherHistory: updatedWeatherHistory,
      decisionHistory: decisions,
    );
  }

  void _evictAreaOperationalState(String areaId) {
    _sosRequests.removeWhere((entry) => entry.areaId == areaId);
    _aidRequests.removeWhere((entry) => entry.areaId == areaId);
    _safeCamps.removeWhere((entry) => entry.areaId == areaId);
    _communicationLogs.removeWhere((entry) => entry.areaId == areaId);
    _weatherHistoryByArea.remove(areaId);
    _decisionHistoryByArea.remove(areaId);
    _updateNotificationCount();

    if (_activeSimulation?.areaId == areaId) {
      _simulationTimer?.cancel();
      _simulationTimer = null;
      _simulationHistory.insert(
        0,
        _activeSimulation!.copyWith(status: DisasterStatus.inactive),
      );
      _activeSimulation = null;
      _systemStatus = SystemStatus.normal;
      _currentDisasterType = null;
    }
  }

  void _archiveClosedArea(DisasterArea area) {
    _activeAreas.removeWhere((a) => a.id == area.id);
    _archivedAreas.removeWhere((a) => a.id == area.id);
    _archivedAreas.add(
      area.copyWith(isActive: false, closedAt: area.closedAt ?? DateTime.now()),
    );

    _simulationAreaIds.remove(area.id);

    final owner = _areaToAdmin.remove(area.id);
    if (owner != null && _adminToArea[owner] == area.id) {
      _adminToArea.remove(owner);
    }

    if (_loggedInAreaId == area.id) {
      _clearLoginState(releaseArea: false);
    }
  }

  Future<ApiResponse<DisasterArea>> closeArea(String areaId) async {
    if (_closingAreaIds.contains(areaId)) {
      return ApiResponse(
        success: false,
        message: 'Area close is already in progress.',
      );
    }

    final index = _activeAreas.indexWhere((a) => a.id == areaId);
    if (index == -1) {
      return ApiResponse(success: false, message: 'Area not found.');
    }

    final area = _activeAreas[index];
    final closedAreaSnapshot = area.copyWith(
      isActive: false,
      closedAt: DateTime.now(),
    );
    final archive = _buildArchivedIncident(closedAreaSnapshot);
    if (_simulationAreaIds.contains(areaId)) {
      final closedArea = closedAreaSnapshot;
      _upsertIncidentHistory(archive.copyWith(closedAt: closedArea.closedAt));
      _archiveClosedArea(closedArea);
      _evictAreaOperationalState(areaId);
      notifyListeners();
      return ApiResponse(
        success: true,
        data: closedArea,
        message: 'Simulation area archived and closed locally.',
      );
    }

    _closingAreaIds.add(areaId);
    notifyListeners();
    try {
      final response = await _apiService.archiveAndCloseDisasterArea(
        areaId,
        archive,
      );
      if (response.success && response.data != null) {
        final payload = response.data!;
        final areaJson = payload['area'] as Map<String, dynamic>?;
        final incidentJson = payload['incident'] as Map<String, dynamic>?;
        if (areaJson == null || incidentJson == null) {
          return ApiResponse(
            success: false,
            message: 'Archive response was missing required data.',
          );
        }

        final closedArea = DisasterArea.fromJson(areaJson);
        final incident = IncidentHistory.fromJson(incidentJson);
        _upsertIncidentHistory(incident);
        _archiveClosedArea(closedArea);
        _evictAreaOperationalState(areaId);
        notifyListeners();
        return ApiResponse(
          success: true,
          data: closedArea,
          message: response.message,
        );
      }
      return ApiResponse(success: false, message: response.message);
    } finally {
      _closingAreaIds.remove(areaId);
      notifyListeners();
    }
  }

  @visibleForTesting
  void overrideAreasForTesting({
    required List<DisasterArea> active,
    List<DisasterArea>? archived,
  }) {
    _activeAreas = active;
    _archivedAreas = archived ?? [];
    _adminToArea = {};
    _areaToAdmin = {};
    _loggedInEmail = null;
    _loggedInAreaId = null;
    _loginError = null;
    notifyListeners();
  }

  @visibleForTesting
  void overrideIncidentHistoryForTesting(List<IncidentHistory> incidents) {
    _incidentHistory = incidents;
    notifyListeners();
  }

  @visibleForTesting
  void seedAreaSessionStateForTesting({
    List<SosRequest>? sosRequests,
    List<AidRequestAdmin>? aidRequests,
    List<SafeCamp>? safeCamps,
    List<CommunicationLog>? communicationLogs,
    List<IncidentWeatherSnapshot>? weatherHistory,
    List<IncidentDecisionEntry>? decisionHistory,
    Map<String, dynamic>? aiSuggestions,
    DisasterEvent? activeSimulation,
  }) {
    if (sosRequests != null) {
      _sosRequests = sosRequests;
    }
    if (aidRequests != null) {
      _aidRequests = aidRequests;
    }
    if (safeCamps != null) {
      _safeCamps = safeCamps;
    }
    if (communicationLogs != null) {
      _communicationLogs = communicationLogs;
    }
    final areaId = _loggedInAreaId;
    if (areaId != null && weatherHistory != null) {
      _weatherHistoryByArea[areaId] = weatherHistory;
    }
    if (areaId != null && decisionHistory != null) {
      _decisionHistoryByArea[areaId] = decisionHistory;
    }
    if (aiSuggestions != null) {
      _aiSuggestions = aiSuggestions;
    }
    if (activeSimulation != null) {
      _activeSimulation = activeSimulation;
    }
    _updateNotificationCount();
    notifyListeners();
  }

  @visibleForTesting
  void closeAreaLocallyForTesting(String areaId) {
    final index = _activeAreas.indexWhere((a) => a.id == areaId);
    if (index == -1) return;
    final area = _activeAreas[index].copyWith(
      isActive: false,
      closedAt: DateTime.now(),
    );
    _upsertIncidentHistory(_buildArchivedIncident(area));
    _archiveClosedArea(area);
    _evictAreaOperationalState(areaId);
    notifyListeners();
  }

  void _assignAreaMetadata() {
    _sosRequests = _sosRequests.map((sos) {
      final route = DisasterAreaService.routeToArea(
        sos.latitude,
        sos.longitude,
        _activeAreas,
      );
      return sos.copyWith(
        areaId: route.areaId,
        insideControllableZone: route.insideControllable,
      );
    }).toList();

    _aidRequests = _aidRequests.map((aid) {
      final route = DisasterAreaService.routeToArea(
        aid.latitude,
        aid.longitude,
        _activeAreas,
      );
      return aid.copyWith(
        areaId: route.areaId,
        insideControllableZone: route.insideControllable,
      );
    }).toList();

    _safeCamps = _safeCamps.map((camp) {
      final route = DisasterAreaService.routeToArea(
        camp.latitude,
        camp.longitude,
        _activeAreas,
      );
      return camp.copyWith(areaId: route.areaId);
    }).toList();
  }

  DisasterArea _createAreaForSos(
    double lat,
    double lon, {
    bool trackForSimulation = false,
  }) {
    final existingIds = {
      ..._activeAreas.map((a) => a.id),
      ..._archivedAreas.map((a) => a.id),
    };
    final area = DisasterAreaService.createAreaForPoint(lat, lon, existingIds);
    _activeAreas.add(area);
    if (trackForSimulation) {
      _simulationAreaIds.add(area.id);
    }
    return area;
  }

  void _syncLoginToActiveAreas() {
    if (_loggedInAreaId == null) return;
    final stillActive = _activeAreas.any((a) => a.id == _loggedInAreaId);
    if (!stillActive) {
      _clearLoginState(releaseArea: true);
    }
  }

  void _clearLoginState({required bool releaseArea}) {
    final email = _loggedInEmail;
    final areaId = _loggedInAreaId;
    if (releaseArea && email != null && areaId != null) {
      if (_adminToArea[email] == areaId) {
        _adminToArea.remove(email);
      }
      if (_areaToAdmin[areaId] == email) {
        _areaToAdmin.remove(areaId);
      }
    }
    _loggedInEmail = null;
    _loggedInAreaId = null;
    _loginError = null;
  }

  void _logActiveAreas() {
    if (_activeAreas.isEmpty) {
      debugPrint('AdminProvider: no active areas computed.');
      return;
    }
    final ids = _activeAreas.map((a) => a.id).join(', ');
    debugPrint('AdminProvider: active areas -> $ids');
  }

  void _upsertActiveArea(DisasterArea area) {
    _archivedAreas.removeWhere((entry) => entry.id == area.id);
    final index = _activeAreas.indexWhere((entry) => entry.id == area.id);
    if (index == -1) {
      _activeAreas.add(area);
    } else {
      _activeAreas[index] = area;
    }
  }

  void _applyAssessmentPayload(Map<String, dynamic>? payload) {
    if (payload == null) return;
    _assessmentProvider?.applyAssessmentResult(
      AssessmentResult.fromJson(payload),
    );
  }

  void _startLocalSimulationTimer(DisasterEvent simulation, Duration interval) {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(interval, (timer) {
      final active = _activeSimulation;
      if (active == null || !active.isActive) {
        timer.cancel();
        return;
      }
      if (active.generatedCitizens >= active.totalCitizens) {
        _completeSimulation();
        return;
      }

      final nextCount = active.generatedCitizens + 1;
      final sos = _buildSimulatedSos(active, sequence: nextCount);
      _activeSimulation = active.copyWith(generatedCitizens: nextCount);
      intakeSosRequest(sos);

      if (nextCount >= active.totalCitizens) {
        _completeSimulation();
      }
    });
  }

  Future<ApiResponse<DisasterEvent>> startDisasterSimulation({
    required String type,
    required double centerLat,
    required double centerLon,
    required double radiusM,
    required DisasterSeverity severity,
    int totalCitizens = 20,
    Duration interval = const Duration(seconds: 2),
  }) async {
    _simulationTimer?.cancel();
    _clearSimulationArtifacts();
    _lastSimulationSmsStatus = null;

    final sanitizedTotal = totalCitizens < 1 ? 1 : totalCitizens;
    final sanitizedRadius = radiusM <= 0 ? 500.0 : radiusM;
    final sanitizedInterval = interval.inMilliseconds < 500
        ? const Duration(milliseconds: 500)
        : interval;

    final response = await _apiService.startSimulation(
      areaId: _loggedInAreaId,
      latitude: centerLat,
      longitude: centerLon,
      radiusM: sanitizedRadius,
      disasterType: type,
      severity: severity.name,
      triggerAssessment: true,
      totalCitizens: sanitizedTotal,
      intervalSeconds: sanitizedInterval.inSeconds,
    );
    if (!response.success || response.data == null) {
      return ApiResponse(success: false, message: response.message);
    }

    final data = response.data!;
    final sessionJson = data['session'] as Map<String, dynamic>?;
    final areaJson = data['area'] as Map<String, dynamic>?;
    if (sessionJson == null || areaJson == null) {
      return ApiResponse(
        success: false,
        message: 'Simulation response was missing required data.',
      );
    }

    final updatedArea = DisasterArea.fromJson(areaJson);
    _upsertActiveArea(updatedArea);

    final simulation = DisasterEvent.fromSimulationJson(sessionJson).copyWith(
      totalCitizens:
          (sessionJson['totalCitizens'] as num?)?.toInt() ?? sanitizedTotal,
      generatedCitizens: 0,
    );

    _activeSimulation = simulation;
    _applyDisasterProfile(type);
    final assessmentPayload = data['assessment'] as Map<String, dynamic>?;
    _applyAssessmentPayload(assessmentPayload);
    _lastSimulationSmsStatus = SimulationSmsStatus.fromAssessmentPayload(
      assessmentPayload,
    );
    _recordDecision(
      areaId: updatedArea.id,
      actor: 'AI Decision Agent',
      type: 'ai_suggestion',
      summary:
          'Simulation started for $type at ${severity.name} severity. Resource recommendations refreshed for the active area.',
      resourceSnapshot: _currentAiSuggestionSnapshot(),
    );
    _recordCommunication(
      areaId: updatedArea.id,
      type: CommunicationLogType.alert,
      message:
          'Simulation started for ${updatedArea.id}. Backend alert flow was triggered for evaluator/demo mode.',
    );
    _startLocalSimulationTimer(simulation, sanitizedInterval);
    await fetchLiveWeatherForArea();
    notifyListeners();

    return ApiResponse(
      success: true,
      data: simulation,
      message: response.message,
    );
  }

  Future<ApiResponse<DisasterEvent>> stopSimulation({
    bool clearData = true,
    bool resetStatus = true,
  }) async {
    _simulationTimer?.cancel();
    _simulationTimer = null;

    final active = _activeSimulation;
    if (active == null) {
      if (clearData) {
        _clearSimulationArtifacts();
      }
      if (resetStatus) {
        _systemStatus = SystemStatus.normal;
        _currentDisasterType = null;
      }
      notifyListeners();
      return ApiResponse(
        success: false,
        message: 'No simulation is currently active.',
      );
    }

    final response = await _apiService.stopSimulation(
      areaId: active.areaId.isNotEmpty ? active.areaId : _loggedInAreaId,
      simulationId: active.id,
    );
    if (!response.success || response.data == null) {
      return ApiResponse(success: false, message: response.message);
    }

    final data = response.data!;
    final areaJson = data['area'] as Map<String, dynamic>?;
    if (areaJson != null) {
      _upsertActiveArea(DisasterArea.fromJson(areaJson));
    }

    final closed = active.copyWith(status: DisasterStatus.inactive);
    _lastSimulationSmsStatus = null;
    _recordCommunication(
      areaId: active.areaId,
      type: CommunicationLogType.alert,
      message:
          'Simulation ${active.id} was stopped and normal thresholds were restored.',
    );
    _simulationHistory.insert(0, closed);
    _activeSimulation = null;
    if (clearData) {
      _clearSimulationArtifacts();
    }
    if (resetStatus) {
      _systemStatus = SystemStatus.normal;
      _currentDisasterType = null;
    }
    await fetchLiveWeatherForArea();
    notifyListeners();
    return ApiResponse(success: true, data: closed, message: response.message);
  }

  Future<void> restoreSimulationForCurrentArea() async {
    final areaId = _loggedInAreaId;
    if (areaId == null) return;

    final response = await _apiService.fetchActiveSimulation(areaId);
    if (!response.success || response.data == null) return;

    final data = response.data!;
    final areaJson = data['area'] as Map<String, dynamic>?;
    if (areaJson != null) {
      _upsertActiveArea(DisasterArea.fromJson(areaJson));
    }

    final sessionJson = data['session'] as Map<String, dynamic>?;
    if (sessionJson == null) {
      if (_activeSimulation?.areaId == areaId) {
        _activeSimulation = null;
        _systemStatus = SystemStatus.normal;
        _currentDisasterType = null;
        notifyListeners();
      }
      return;
    }

    final simulation = DisasterEvent.fromSimulationJson(sessionJson);
    _activeSimulation = simulation;
    _applyDisasterProfile(simulation.type);
    notifyListeners();
  }

  void _completeSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    final active = _activeSimulation;
    if (active == null) return;
    final closed = active.copyWith(status: DisasterStatus.inactive);
    _activeSimulation = closed;
    _simulationHistory.insert(0, closed);
    notifyListeners();
  }

  SosRequest _buildSimulatedSos(
    DisasterEvent simulation, {
    required int sequence,
  }) {
    final point = _randomPointWithinRadius(
      simulation.centerLat,
      simulation.centerLon,
      simulation.radiusM,
    );

    return SosRequest(
      id: _nextSimulationSosId(),
      status: SosStatus.pending,
      callerName: 'Simulated Citizen ${sequence.toString().padLeft(3, '0')}',
      phoneNumber: '+00 0000 ${sequence.toString().padLeft(4, '0')}',
      address:
          'Simulated location near ${simulation.centerLat.toStringAsFixed(3)}, ${simulation.centerLon.toStringAsFixed(3)}',
      latitude: point.x,
      longitude: point.y,
      timestamp: DateTime.now(),
      areaId: simulation.areaId,
      insideControllableZone: true,
      source: 'simulation',
      disasterId: simulation.id,
    );
  }

  Point<double> _randomPointWithinRadius(
    double centerLat,
    double centerLon,
    double radiusM,
  ) {
    const metersPerDegree = 111320.0;
    final radiusInDegrees = radiusM / metersPerDegree;
    final u = _random.nextDouble();
    final v = _random.nextDouble();
    final w = radiusInDegrees * sqrt(u);
    final t = 2 * pi * v;
    final latOffset = w * cos(t);
    final lonOffset = w * sin(t) / cos(centerLat * pi / 180);
    return Point(centerLat + latOffset, centerLon + lonOffset);
  }

  String _nextSimulationSosId() {
    _simulationSequence += 1;
    return 'SIM-SOS-${_simulationSequence.toString().padLeft(4, '0')}';
  }

  void _clearSimulationArtifacts() {
    if (_sosRequests.isNotEmpty) {
      _sosRequests.removeWhere((r) => r.source == 'simulation');
    }

    _updateNotificationCount();
  }

  /// Simulate system status change
  void simulateStatusChange() {
    const statuses = SystemStatus.values;
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

  void _replaceSosRequest(SosRequest updated) {
    final index = _sosRequests.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;
    _sosRequests[index] = updated;
  }

  void _replaceAidRequest(AidRequestAdmin updated) {
    final index = _aidRequests.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;
    _aidRequests[index] = updated;
  }

  /// Dispatch rescue team for SOS request
  Future<ApiResponse<SosRequest>> dispatchRescueTeam(String sosId) async {
    final index = _sosRequests.indexWhere((r) => r.id == sosId);
    if (index == -1) {
      return ApiResponse(success: false, message: 'SOS request not found.');
    }

    final request = _sosRequests[index];
    if (_dispatchingSosIds.contains(sosId)) {
      return ApiResponse(
        success: false,
        message: 'SOS dispatch already in progress.',
      );
    }

    if (request.source == 'simulation') {
      final active = _activeSimulation;
      if (active == null || request.disasterId != active.id) {
        return ApiResponse(
          success: false,
          message: 'Simulation request is no longer active.',
        );
      }

      final updated = request.copyWith(
        status: SosStatus.dispatched,
        eta: request.eta ?? '15 minutes',
      );
      _replaceSosRequest(updated);
      _recordCommunication(
        areaId: updated.areaId,
        type: CommunicationLogType.evacuation,
        message: 'Simulation rescue dispatch confirmed for ${updated.id}.',
      );
      _updateNotificationCount();
      notifyListeners();
      return ApiResponse(
        success: true,
        data: updated,
        message: 'Simulation rescue team dispatched locally.',
      );
    }

    if (!request.insideControllableZone) {
      return ApiResponse(
        success: false,
        message: 'This SOS request is outside the controllable boundary.',
      );
    }
    if (_loggedInAreaId != null && request.areaId != _loggedInAreaId) {
      return ApiResponse(
        success: false,
        message: 'You can only dispatch SOS requests for your assigned area.',
      );
    }

    _dispatchingSosIds.add(sosId);
    notifyListeners();
    try {
      final response = await _apiService.dispatchSosRequest(sosId);
      if (response.success && response.data != null) {
        final updated = response.data!.copyWith(
          eta: response.data!.eta ?? '15 minutes',
        );
        _replaceSosRequest(updated);
        _recordCommunication(
          areaId: updated.areaId,
          type: CommunicationLogType.evacuation,
          message:
              'Rescue team dispatched for ${updated.id} with ETA ${updated.eta ?? 'pending'}.',
        );
        _updateNotificationCount();
        notifyListeners();
      }
      return response;
    } finally {
      _dispatchingSosIds.remove(sosId);
      notifyListeners();
    }
  }

  /// Dispatch aid for aid request
  Future<ApiResponse<AidRequestAdmin>> dispatchAid(String aidId) async {
    final index = _aidRequests.indexWhere((r) => r.id == aidId);
    if (index == -1) {
      return ApiResponse(success: false, message: 'Aid request not found.');
    }

    final request = _aidRequests[index];
    if (_dispatchingAidIds.contains(aidId)) {
      return ApiResponse(
        success: false,
        message: 'Aid dispatch already in progress.',
      );
    }

    if (!request.insideControllableZone) {
      return ApiResponse(
        success: false,
        message: 'This aid request is outside the controllable boundary.',
      );
    }
    if (_loggedInAreaId != null && request.areaId != _loggedInAreaId) {
      return ApiResponse(
        success: false,
        message: 'You can only dispatch aid requests for your assigned area.',
      );
    }

    _dispatchingAidIds.add(aidId);
    notifyListeners();
    try {
      final response = await _apiService.dispatchAidRequest(aidId);
      if (response.success && response.data != null) {
        final updated = response.data!;
        _replaceAidRequest(updated);
        _recordCommunication(
          areaId: updated.areaId,
          type: CommunicationLogType.resource,
          message:
              'Aid dispatch confirmed for ${updated.id}: ${updated.resourcesText}.',
        );
        _updateNotificationCount();
        notifyListeners();
      }
      return response;
    } finally {
      _dispatchingAidIds.remove(aidId);
      notifyListeners();
    }
  }

  /// Add new safe camp
  bool addSafeCamp(SafeCamp camp) {
    final route = routeToArea(camp.latitude, camp.longitude);
    if (route.areaId == 'UNASSIGNED') return false;
    if (_loggedInAreaId != null && route.areaId != _loggedInAreaId) {
      return false;
    }
    if (_loggedInAreaId != null && !route.insideControllable) {
      return false;
    }

    final resolvedAreaId = _loggedInAreaId ?? route.areaId;
    final updated = camp.copyWith(areaId: resolvedAreaId);
    _safeCamps.add(updated);
    _recordDecision(
      areaId: resolvedAreaId,
      actor: 'Admin',
      type: 'camp_created',
      summary:
          'Safe camp ${updated.name} created with capacity ${updated.capacity} at ${updated.coordinates}.',
    );
    notifyListeners();
    return true;
  }

  /// Delete safe camp
  void deleteSafeCamp(String campId) {
    SafeCamp? target;
    for (final camp in _safeCamps) {
      if (camp.id == campId) {
        target = camp;
        break;
      }
    }
    if (target == null) return;
    if (_loggedInAreaId != null && target.areaId != _loggedInAreaId) {
      return;
    }
    _safeCamps.removeWhere((c) => c.id == campId);
    _recordDecision(
      areaId: target.areaId,
      actor: 'Admin',
      type: 'camp_deleted',
      summary:
          'Safe camp ${target.name} was removed from the active response plan.',
    );
    notifyListeners();
  }

  /// Get total sessions count
  int get totalSessions => _incidentHistory.length;

  /// Load a dummy disaster scenario and update AI suggestions accordingly
  void loadDummyScenario(String disasterType) {
    _applyDisasterProfile(disasterType);
    notifyListeners();
  }

  void _applyDisasterProfile(String disasterType) {
    _currentDisasterType = disasterType;
    _systemStatus = SystemStatus.critical;

    // Adjust AI suggestions based on disaster type
    switch (disasterType.toLowerCase()) {
      case 'coastal flood':
        _aiSuggestions = {
          'ambulances': 20,
          'boats': 15,
          'foodPackets': 8000,
          'medicalKits': 350,
        };
        break;
      case 'cyclone':
        _aiSuggestions = {
          'ambulances': 25,
          'boats': 10,
          'foodPackets': 10000,
          'medicalKits': 500,
        };
        break;
      case 'earthquake':
        _aiSuggestions = {
          'ambulances': 30,
          'boats': 2,
          'foodPackets': 12000,
          'medicalKits': 600,
        };
        break;
      case 'forest fire':
        _aiSuggestions = {
          'ambulances': 15,
          'boats': 0,
          'foodPackets': 5000,
          'medicalKits': 300,
        };
        break;
      default:
        _aiSuggestions = {
          'ambulances': 12,
          'boats': 8,
          'foodPackets': 5000,
          'medicalKits': 200,
        };
    }
  }

  /// Apply admin resource overrides, merge into AI suggestions, and log audit
  void applyResourceOverrides(Map<String, int> overrides) {
    overrides.forEach((key, value) {
      _aiSuggestions[key] = value;
    });

    final timestamp = DateTime.now();
    final auditEntry =
        '[${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}] '
        'Admin override applied: ${overrides.entries.map((e) => '${e.key}=${e.value}').join(', ')}';
    final areaId = _loggedInAreaId;
    if (areaId != null) {
      _recordDecision(
        areaId: areaId,
        actor: 'Admin',
        type: 'admin_override',
        summary:
            'Admin override applied: ${overrides.entries.map((e) => '${e.key}=${e.value}').join(', ')}.',
        resourceSnapshot: _currentAiSuggestionSnapshot(),
        timestamp: timestamp,
      );
      _recordCommunication(
        areaId: areaId,
        type: CommunicationLogType.resource,
        message:
            'Resource allocation updated for $areaId after manual admin overrides.',
        timestamp: timestamp,
      );
    } else {
      _decisionAudit.insert(0, auditEntry);
    }

    notifyListeners();
  }

  /// Fetch live weather readings for the current active area from the backend
  Future<void> fetchLiveWeatherForArea() async {
    final area = currentArea;
    if (area == null) {
      // No active area, use mock data
      _sensorReadings = AdminDataService.getSensorReadings();
      notifyListeners();
      return;
    }

    try {
      // Pass area coordinates to backend for accurate weather
      final response = await _apiService.fetchLiveWeatherStatus(
        area.id,
        latitude: area.centerLat,
        longitude: area.centerLon,
      );

      if (response.success && response.data != null) {
        debugPrint(
          'AdminProvider: Successfully fetched ${response.data!.readings.length} sensor readings',
        );
        // Convert API response to SensorReading objects
        final weather = response.data!;
        final readingsList = weather.readings;
        _sensorReadings = readingsList.map((reading) {
          return SensorReading(
            type: reading['type'] ?? 'Unknown',
            value: (reading['value'] as num?)?.toDouble() ?? 0.0,
            unit: reading['unit'] ?? '',
            trend: SensorTrend.values.firstWhere(
              (e) => e.name == reading['trend'],
              orElse: () => SensorTrend.stable,
            ),
            timestamp: reading['timestamp'] != null
                ? DateTime.parse(reading['timestamp'] as String)
                : DateTime.now(),
          );
        }).toList();
        _recordWeatherSnapshot(
          areaId: area.id,
          readings: _sensorReadings,
          riskLevel:
              _assessmentProvider?.result?.weatherRiskLevel ??
              weather.riskLevel,
          condition:
              _assessmentProvider?.result?.weatherCondition ??
              weather.condition,
          summary: 'Weather snapshot captured while monitoring ${area.id}.',
          timestamp: weather.timestamp != null
              ? DateTime.tryParse(weather.timestamp!)
              : null,
        );
      } else {
        debugPrint(
          'AdminProvider: API returned no data or failed: ${response.message}. Using mock data.',
        );
        // API returned no data, use mock data
        _sensorReadings = AdminDataService.getSensorReadings();
        _recordWeatherSnapshot(
          areaId: area.id,
          readings: _sensorReadings,
          riskLevel: _assessmentProvider?.result?.weatherRiskLevel ?? 'unknown',
          condition:
              _assessmentProvider?.result?.weatherCondition ?? 'Mock fallback',
          summary: 'Fallback weather snapshot recorded for ${area.id}.',
        );
      }
    } catch (e) {
      debugPrint(
        'AdminProvider: Error fetching live weather: $e. Falling back to mock data.',
      );
      // On error, fall back to mock data
      _sensorReadings = AdminDataService.getSensorReadings();
      _recordWeatherSnapshot(
        areaId: area.id,
        readings: _sensorReadings,
        riskLevel: _assessmentProvider?.result?.weatherRiskLevel ?? 'unknown',
        condition:
            _assessmentProvider?.result?.weatherCondition ?? 'Mock fallback',
        summary: 'Weather fallback snapshot recorded after an API error.',
      );
    }

    notifyListeners();

    // Schedule next fetch if not already scheduled
    _startWeatherRefreshTimer();
  }

  Timer? _weatherRefreshTimer;

  void _startWeatherRefreshTimer() {
    if (_weatherRefreshTimer != null && _weatherRefreshTimer!.isActive) return;

    _weatherRefreshTimer = Timer(const Duration(seconds: 30), () {
      if (_loggedInAreaId != null) {
        fetchLiveWeatherForArea();
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _weatherRefreshTimer?.cancel();
    super.dispose();
  }
}
