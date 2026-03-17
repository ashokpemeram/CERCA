import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import '../services/api_service.dart';

/// System status enumeration
enum SystemStatus {
  normal,
  critical,
  degraded,
}

/// Provider for admin dashboard state management
class AdminProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
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
  String? get loggedInEmail => _loggedInEmail;
  String? get loggedInAreaId => _loggedInAreaId;
  String? get loginError => _loginError;

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
  List<DisasterEvent> _simulationHistory = [];
  Timer? _simulationTimer;
  final Set<String> _simulationAreaIds = {};
  final Random _random = Random();
  int _simulationSequence = 0;

  DisasterEvent? get activeSimulation => _activeSimulation;
  List<DisasterEvent> get simulationHistory => _simulationHistory;
  bool get isSimulationRunning => _activeSimulation?.isActive ?? false;

  // AI suggestions for resource allocation
  Map<String, dynamic> _aiSuggestions = {
    'ambulances': 12,
    'boats': 8,
    'foodPackets': 5000,
    'medicalKits': 200,
  };
  Map<String, dynamic> get aiSuggestions => _aiSuggestions;

  // Decision audit trail
  List<String> _decisionAudit = [];
  List<String> get decisionAudit => _decisionAudit;

  // Convenience getters for alert counts
  int get sosAlertsCount =>
      _sosRequests.where((r) => r.status == SosStatus.pending).length;
  int get aidRequestsCount =>
      _aidRequests.where((r) => r.status == AidStatus.pending).length;

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

  /// Load active areas from backend
  Future<void> refreshAreasFromBackend() async {
    final response = await _apiService.fetchActiveAreas();
    if (response.success && response.data != null) {
      _activeAreas = response.data!;
      _archivedAreas = [];
      _syncLoginToActiveAreas();
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
    final pendingSos = _sosRequests.where((r) => r.status == SosStatus.pending).length;
    final pendingAid = _aidRequests.where((r) => r.status == AidStatus.pending).length;
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
            (r) =>
                r.source == 'simulation' && r.disasterId == simulation.id,
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
    
    notifyListeners();
    return true;
  }

  void logoutAdmin() {
    _clearLoginState(releaseArea: true);
    notifyListeners();
  }

  void closeArea(String areaId) {
    final index = _activeAreas.indexWhere((a) => a.id == areaId);
    if (index == -1) return;

    final area = _activeAreas.removeAt(index);
    _archivedAreas.add(area.copyWith(closedAt: DateTime.now()));

    final owner = _areaToAdmin.remove(areaId);
    if (owner != null && _adminToArea[owner] == areaId) {
      _adminToArea.remove(owner);
    }

    if (_loggedInAreaId == areaId) {
      _clearLoginState(releaseArea: false);
    }

    notifyListeners();
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

  void _assignAreaMetadata() {
    _sosRequests = _sosRequests
        .map((sos) {
          final route = DisasterAreaService.routeToArea(
            sos.latitude,
            sos.longitude,
            _activeAreas,
          );
          return sos.copyWith(
            areaId: route.areaId,
            insideControllableZone: route.insideControllable,
          );
        })
        .toList();

    _aidRequests = _aidRequests
        .map((aid) {
          final route = DisasterAreaService.routeToArea(
            aid.latitude,
            aid.longitude,
            _activeAreas,
          );
          return aid.copyWith(
            areaId: route.areaId,
            insideControllableZone: route.insideControllable,
          );
        })
        .toList();

    _safeCamps = _safeCamps
        .map((camp) {
          final route = DisasterAreaService.routeToArea(
            camp.latitude,
            camp.longitude,
            _activeAreas,
          );
          return camp.copyWith(areaId: route.areaId);
        })
        .toList();
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
    final area = DisasterAreaService.createAreaForPoint(
      lat,
      lon,
      existingIds,
    );
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

  void startDisasterSimulation({
    required String type,
    required double centerLat,
    required double centerLon,
    required double radiusM,
    required DisasterSeverity severity,
    int totalCitizens = 20,
    Duration interval = const Duration(seconds: 2),
  }) {
    _simulationTimer?.cancel();
    _clearSimulationArtifacts();

    final sanitizedTotal = totalCitizens < 1 ? 1 : totalCitizens;
    final sanitizedRadius = radiusM <= 0 ? 500.0 : radiusM;
    final sanitizedInterval =
        interval.inMilliseconds < 500 ? const Duration(milliseconds: 500) : interval;

    final simulation = DisasterEvent(
      id: _generateDisasterId(),
      type: type,
      centerLat: centerLat,
      centerLon: centerLon,
      radiusM: sanitizedRadius,
      severity: severity,
      createdAt: DateTime.now(),
      status: DisasterStatus.active,
      totalCitizens: sanitizedTotal,
      generatedCitizens: 0,
    );

    _activeSimulation = simulation;
    _applyDisasterProfile(type);
    notifyListeners();

    _simulationTimer = Timer.periodic(sanitizedInterval, (timer) {
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

  void stopSimulation({
    bool clearData = true,
    bool resetStatus = true,
  }) {
    _simulationTimer?.cancel();
    _simulationTimer = null;

    final active = _activeSimulation;
    if (active != null) {
      final closed = active.copyWith(status: DisasterStatus.inactive);
      _simulationHistory.insert(0, closed);
    }

    _activeSimulation = null;
    if (clearData) {
      _clearSimulationArtifacts();
    }
    if (resetStatus) {
      _systemStatus = SystemStatus.normal;
      _currentDisasterType = null;
    }
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

  SosRequest _buildSimulatedSos(DisasterEvent simulation, {required int sequence}) {
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

  String _generateDisasterId() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = (_random.nextInt(9000) + 1000).toString();
    return 'DIS-$date-$suffix';
  }

  String _nextSimulationSosId() {
    _simulationSequence += 1;
    return 'SIM-SOS-${_simulationSequence.toString().padLeft(4, '0')}';
  }

  void _clearSimulationArtifacts() {
    if (_sosRequests.isNotEmpty) {
      _sosRequests.removeWhere((r) => r.source == 'simulation');
    }

    if (_simulationAreaIds.isNotEmpty) {
      _activeAreas.removeWhere((a) => _simulationAreaIds.contains(a.id));
      _archivedAreas.removeWhere((a) => _simulationAreaIds.contains(a.id));

      for (final areaId in _simulationAreaIds) {
        final owner = _areaToAdmin.remove(areaId);
        if (owner != null && _adminToArea[owner] == areaId) {
          _adminToArea.remove(owner);
        }
      }

      if (_loggedInAreaId != null &&
          _simulationAreaIds.contains(_loggedInAreaId)) {
        _clearLoginState(releaseArea: false);
      }

      _simulationAreaIds.clear();
    }

    _updateNotificationCount();
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
      final request = _sosRequests[index];
      if (request.source == 'simulation') {
        final active = _activeSimulation;
        if (active == null || request.disasterId != active.id) {
          return;
        }
      } else {
        if (!request.insideControllableZone) return;
        if (_loggedInAreaId != null && request.areaId != _loggedInAreaId) {
          return;
        }
      }
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
      final request = _aidRequests[index];
      if (!request.insideControllableZone) return;
      if (_loggedInAreaId != null && request.areaId != _loggedInAreaId) {
        return;
      }
      _aidRequests[index] = _aidRequests[index].copyWith(
        status: AidStatus.dispatched,
      );
      _updateNotificationCount();
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
    _decisionAudit.insert(0, auditEntry);

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
      final apiService = ApiService();
      // Pass area coordinates to backend for accurate weather
      final response = await apiService.fetchLiveWeatherReadings(
        area.id,
        latitude: area.centerLat,
        longitude: area.centerLon,
      );

      if (response.success && response.data != null) {
        debugPrint('AdminProvider: Successfully fetched ${response.data!.length} sensor readings');
        // Convert API response to SensorReading objects
        final readingsList = response.data!;
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
      } else {
        debugPrint('AdminProvider: API returned no data or failed: ${response.message}. Using mock data.');
        // API returned no data, use mock data
        _sensorReadings = AdminDataService.getSensorReadings();
      }
    } catch (e) {
      debugPrint('AdminProvider: Error fetching live weather: $e. Falling back to mock data.');
      // On error, fall back to mock data
      _sensorReadings = AdminDataService.getSensorReadings();
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
