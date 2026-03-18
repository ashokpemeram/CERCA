import 'aid_request_admin.dart';
import 'communication_log.dart';
import 'safe_camp.dart';
import 'sensor_reading.dart';
import 'sos_request.dart';

enum IncidentSeverity { medium, high, critical }

enum IncidentStatus { resolved, ongoing }

IncidentSeverity _parseSeverity(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  switch (normalized) {
    case 'critical':
      return IncidentSeverity.critical;
    case 'high':
      return IncidentSeverity.high;
    case 'medium':
    default:
      return IncidentSeverity.medium;
  }
}

IncidentStatus _parseStatus(Object? value) {
  final normalized = value?.toString().trim().toLowerCase();
  switch (normalized) {
    case 'resolved':
    case 'closed':
      return IncidentStatus.resolved;
    case 'ongoing':
    default:
      return IncidentStatus.ongoing;
  }
}

DateTime _parseDateTime(Object? value, DateTime fallback) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? fallback;
  }
  return fallback;
}

int _parseInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

Map<String, int> _parseIntMap(Object? value) {
  if (value is! Map) {
    return const {};
  }
  final result = <String, int>{};
  for (final entry in value.entries) {
    final key = entry.key.toString().trim();
    if (key.isEmpty) {
      continue;
    }
    result[key] = _parseInt(entry.value);
  }
  return result;
}

String _formatDuration(Duration duration) {
  if (duration.inMinutes < 1) {
    return '< 1 min';
  }
  if (duration.inHours < 1) {
    return '${duration.inMinutes} min';
  }
  if (duration.inDays < 1) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $minutes min';
  }

  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  if (hours == 0) {
    return '$days day${days == 1 ? '' : 's'}';
  }
  return '$days day${days == 1 ? '' : 's'} $hours hr';
}

class IncidentAreaSnapshot {
  final String areaId;
  final double centerLat;
  final double centerLon;
  final double redRadiusM;
  final double warningRadiusM;
  final double greenRadiusM;
  final double controllableRadiusM;
  final DateTime? createdAt;
  final DateTime? closedAt;
  final String summaryLabel;
  final String? mapSummary;

  const IncidentAreaSnapshot({
    required this.areaId,
    required this.centerLat,
    required this.centerLon,
    required this.redRadiusM,
    required this.warningRadiusM,
    required this.greenRadiusM,
    required this.controllableRadiusM,
    required this.summaryLabel,
    this.createdAt,
    this.closedAt,
    this.mapSummary,
  });

  factory IncidentAreaSnapshot.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return IncidentAreaSnapshot(
      areaId:
          (json['areaId'] as String?) ??
          (json['id'] as String?) ??
          'UNASSIGNED',
      centerLat: (json['centerLat'] as num?)?.toDouble() ?? 0,
      centerLon: (json['centerLon'] as num?)?.toDouble() ?? 0,
      redRadiusM: (json['redRadiusM'] as num?)?.toDouble() ?? 0,
      warningRadiusM: (json['warningRadiusM'] as num?)?.toDouble() ?? 0,
      greenRadiusM: (json['greenRadiusM'] as num?)?.toDouble() ?? 0,
      controllableRadiusM:
          (json['controllableRadiusM'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'], now)
          : null,
      closedAt: json['closedAt'] != null
          ? _parseDateTime(json['closedAt'], now)
          : null,
      summaryLabel:
          (json['summaryLabel'] as String?) ??
          (json['label'] as String?) ??
          (json['areaSummary'] as String?) ??
          'Archived impact area',
      mapSummary: json['mapSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': areaId,
      'areaId': areaId,
      'centerLat': centerLat,
      'centerLon': centerLon,
      'redRadiusM': redRadiusM,
      'warningRadiusM': warningRadiusM,
      'greenRadiusM': greenRadiusM,
      'controllableRadiusM': controllableRadiusM,
      'createdAt': createdAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'summaryLabel': summaryLabel,
      'mapSummary': mapSummary,
    };
  }

  String get coordinates =>
      '${centerLat.toStringAsFixed(6)}, ${centerLon.toStringAsFixed(6)}';
}

class IncidentWeatherSnapshot {
  final DateTime timestamp;
  final String riskLevel;
  final String condition;
  final String summary;
  final List<SensorReading> readings;

  const IncidentWeatherSnapshot({
    required this.timestamp,
    required this.riskLevel,
    required this.condition,
    required this.summary,
    required this.readings,
  });

  factory IncidentWeatherSnapshot.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return IncidentWeatherSnapshot(
      timestamp: _parseDateTime(json['timestamp'], now),
      riskLevel: (json['riskLevel'] as String?) ?? 'unknown',
      condition: (json['condition'] as String?) ?? 'Unknown',
      summary: (json['summary'] as String?) ?? 'Weather observation recorded.',
      readings: ((json['readings'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SensorReading.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'riskLevel': riskLevel,
      'condition': condition,
      'summary': summary,
      'readings': readings.map((reading) => reading.toJson()).toList(),
    };
  }
}

class IncidentDecisionEntry {
  final DateTime timestamp;
  final String actor;
  final String type;
  final String summary;
  final Map<String, int> resourceSnapshot;

  const IncidentDecisionEntry({
    required this.timestamp,
    required this.actor,
    required this.type,
    required this.summary,
    this.resourceSnapshot = const {},
  });

  factory IncidentDecisionEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return IncidentDecisionEntry(
      timestamp: _parseDateTime(json['timestamp'], now),
      actor: (json['actor'] as String?) ?? 'System',
      type: (json['type'] as String?) ?? 'note',
      summary: (json['summary'] as String?) ?? '',
      resourceSnapshot: _parseIntMap(json['resourceSnapshot']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'actor': actor,
      'type': type,
      'summary': summary,
      'resourceSnapshot': resourceSnapshot,
    };
  }
}

class IncidentHistory {
  final String id;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final String disasterType;
  final DateTime startedAt;
  final DateTime closedAt;
  final IncidentAreaSnapshot area;
  final int affectedCount;
  final int evacuatedCount;
  final int totalSosLogs;
  final int pendingSosCount;
  final int dispatchedSosCount;
  final int totalAidRequests;
  final int pendingAidCount;
  final int dispatchedAidCount;
  final int totalDispatched;
  final int safeCampCount;
  final bool wasSimulation;
  final String? simulationId;
  final int simulatedCitizens;
  final String? currentRisk;
  final String? alertMessage;
  final String? finalOutcomeSummary;
  final Map<String, int> requestedResources;
  final Map<String, int> aiResourceSnapshot;
  final List<String> keyActions;
  final List<SosRequest> sosLogs;
  final List<AidRequestAdmin> aidLogs;
  final List<SafeCamp> safeCamps;
  final List<CommunicationLog> communicationLogs;
  final List<IncidentWeatherSnapshot> weatherHistory;
  final List<IncidentDecisionEntry> decisionHistory;

  IncidentHistory({
    required this.id,
    required this.severity,
    required this.status,
    required this.disasterType,
    required this.startedAt,
    required this.closedAt,
    required this.area,
    required this.affectedCount,
    required this.evacuatedCount,
    required this.totalSosLogs,
    required this.pendingSosCount,
    required this.dispatchedSosCount,
    required this.totalAidRequests,
    required this.pendingAidCount,
    required this.dispatchedAidCount,
    required this.totalDispatched,
    required this.safeCampCount,
    this.wasSimulation = false,
    this.simulationId,
    this.simulatedCitizens = 0,
    this.currentRisk,
    this.alertMessage,
    this.finalOutcomeSummary,
    this.requestedResources = const {},
    this.aiResourceSnapshot = const {},
    this.keyActions = const [],
    this.sosLogs = const [],
    this.aidLogs = const [],
    this.safeCamps = const [],
    this.communicationLogs = const [],
    this.weatherHistory = const [],
    this.decisionHistory = const [],
  });

  factory IncidentHistory.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final startedAt = _parseDateTime(
      json['startedAt'] ?? json['timestamp'],
      now,
    );
    final closedAt = _parseDateTime(
      json['closedAt'] ?? json['timestamp'] ?? startedAt.toIso8601String(),
      startedAt,
    );

    final legacyDuration = (json['duration'] as String?) ?? '';
    final areaJson =
        (json['area'] as Map<String, dynamic>?) ??
        <String, dynamic>{
          'id': json['areaId'],
          'areaId': json['areaId'],
          'summaryLabel': json['areaSummary'],
        };

    return IncidentHistory(
      id: json['id'] as String,
      severity: _parseSeverity(json['severity']),
      status: _parseStatus(json['status']),
      disasterType: (json['disasterType'] as String?) ?? 'Disaster',
      startedAt: startedAt,
      closedAt: closedAt,
      area: IncidentAreaSnapshot.fromJson(areaJson),
      affectedCount: _parseInt(json['affectedCount']),
      evacuatedCount: _parseInt(json['evacuatedCount']),
      totalSosLogs: _parseInt(json['totalSosLogs']),
      pendingSosCount: _parseInt(json['pendingSosCount']),
      dispatchedSosCount: _parseInt(json['dispatchedSosCount']),
      totalAidRequests: _parseInt(json['totalAidRequests']),
      pendingAidCount: _parseInt(json['pendingAidCount']),
      dispatchedAidCount: _parseInt(json['dispatchedAidCount']),
      totalDispatched: _parseInt(
        json['totalDispatched'] ??
            _parseInt(json['dispatchedSosCount']) +
                _parseInt(json['dispatchedAidCount']),
      ),
      safeCampCount: _parseInt(json['safeCampCount']),
      wasSimulation: json['wasSimulation'] as bool? ?? false,
      simulationId: json['simulationId'] as String?,
      simulatedCitizens: _parseInt(json['simulatedCitizens']),
      currentRisk: json['currentRisk'] as String?,
      alertMessage: json['alertMessage'] as String?,
      finalOutcomeSummary: json['finalOutcomeSummary'] as String?,
      requestedResources: _parseIntMap(json['requestedResources']),
      aiResourceSnapshot: _parseIntMap(json['aiResourceSnapshot']),
      keyActions: ((json['keyActions'] as List?) ?? const [])
          .map((entry) => entry.toString())
          .where((entry) => entry.trim().isNotEmpty)
          .toList(),
      sosLogs: ((json['sosLogs'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SosRequest.fromJson)
          .toList(),
      aidLogs: ((json['aidLogs'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AidRequestAdmin.fromJson)
          .toList(),
      safeCamps: ((json['safeCamps'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SafeCamp.fromJson)
          .toList(),
      communicationLogs: ((json['communicationLogs'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CommunicationLog.fromJson)
          .toList(),
      weatherHistory: ((json['weatherHistory'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(IncidentWeatherSnapshot.fromJson)
          .toList(),
      decisionHistory: ((json['decisionHistory'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(IncidentDecisionEntry.fromJson)
          .toList(),
    )._withLegacyDurationFallback(legacyDuration);
  }

  IncidentHistory _withLegacyDurationFallback(String legacyDuration) {
    if (legacyDuration.trim().isEmpty) {
      return this;
    }
    return copyWith(
      closedAt: startedAt.add(_parseLegacyDuration(legacyDuration)),
    );
  }

  static Duration _parseLegacyDuration(String value) {
    final normalized = value.toLowerCase();
    final number = int.tryParse(normalized.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null || number <= 0) {
      return const Duration(hours: 1);
    }
    if (normalized.contains('day')) {
      return Duration(days: number);
    }
    if (normalized.contains('hour') || normalized.contains('hr')) {
      return Duration(hours: number);
    }
    return Duration(minutes: number);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'severity': severity.name,
      'status': status.name,
      'disasterType': disasterType,
      'startedAt': startedAt.toIso8601String(),
      'closedAt': closedAt.toIso8601String(),
      'affectedCount': affectedCount,
      'evacuatedCount': evacuatedCount,
      'totalSosLogs': totalSosLogs,
      'pendingSosCount': pendingSosCount,
      'dispatchedSosCount': dispatchedSosCount,
      'totalAidRequests': totalAidRequests,
      'pendingAidCount': pendingAidCount,
      'dispatchedAidCount': dispatchedAidCount,
      'totalDispatched': totalDispatched,
      'safeCampCount': safeCampCount,
      'wasSimulation': wasSimulation,
      'simulationId': simulationId,
      'simulatedCitizens': simulatedCitizens,
      'currentRisk': currentRisk,
      'alertMessage': alertMessage,
      'finalOutcomeSummary': finalOutcomeSummary,
      'requestedResources': requestedResources,
      'aiResourceSnapshot': aiResourceSnapshot,
      'keyActions': keyActions,
      'areaSummary': area.summaryLabel,
      'area': area.toJson(),
      'sosLogs': sosLogs.map((entry) => entry.toJson()).toList(),
      'aidLogs': aidLogs.map((entry) => entry.toJson()).toList(),
      'safeCamps': safeCamps.map((entry) => entry.toJson()).toList(),
      'communicationLogs': communicationLogs
          .map((entry) => entry.toJson())
          .toList(),
      'weatherHistory': weatherHistory.map((entry) => entry.toJson()).toList(),
      'decisionHistory': decisionHistory
          .map((entry) => entry.toJson())
          .toList(),
    };
  }

  IncidentHistory copyWith({
    String? id,
    IncidentSeverity? severity,
    IncidentStatus? status,
    String? disasterType,
    DateTime? startedAt,
    DateTime? closedAt,
    IncidentAreaSnapshot? area,
    int? affectedCount,
    int? evacuatedCount,
    int? totalSosLogs,
    int? pendingSosCount,
    int? dispatchedSosCount,
    int? totalAidRequests,
    int? pendingAidCount,
    int? dispatchedAidCount,
    int? totalDispatched,
    int? safeCampCount,
    bool? wasSimulation,
    String? simulationId,
    int? simulatedCitizens,
    String? currentRisk,
    String? alertMessage,
    String? finalOutcomeSummary,
    Map<String, int>? requestedResources,
    Map<String, int>? aiResourceSnapshot,
    List<String>? keyActions,
    List<SosRequest>? sosLogs,
    List<AidRequestAdmin>? aidLogs,
    List<SafeCamp>? safeCamps,
    List<CommunicationLog>? communicationLogs,
    List<IncidentWeatherSnapshot>? weatherHistory,
    List<IncidentDecisionEntry>? decisionHistory,
  }) {
    return IncidentHistory(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      disasterType: disasterType ?? this.disasterType,
      startedAt: startedAt ?? this.startedAt,
      closedAt: closedAt ?? this.closedAt,
      area: area ?? this.area,
      affectedCount: affectedCount ?? this.affectedCount,
      evacuatedCount: evacuatedCount ?? this.evacuatedCount,
      totalSosLogs: totalSosLogs ?? this.totalSosLogs,
      pendingSosCount: pendingSosCount ?? this.pendingSosCount,
      dispatchedSosCount: dispatchedSosCount ?? this.dispatchedSosCount,
      totalAidRequests: totalAidRequests ?? this.totalAidRequests,
      pendingAidCount: pendingAidCount ?? this.pendingAidCount,
      dispatchedAidCount: dispatchedAidCount ?? this.dispatchedAidCount,
      totalDispatched: totalDispatched ?? this.totalDispatched,
      safeCampCount: safeCampCount ?? this.safeCampCount,
      wasSimulation: wasSimulation ?? this.wasSimulation,
      simulationId: simulationId ?? this.simulationId,
      simulatedCitizens: simulatedCitizens ?? this.simulatedCitizens,
      currentRisk: currentRisk ?? this.currentRisk,
      alertMessage: alertMessage ?? this.alertMessage,
      finalOutcomeSummary: finalOutcomeSummary ?? this.finalOutcomeSummary,
      requestedResources: requestedResources ?? this.requestedResources,
      aiResourceSnapshot: aiResourceSnapshot ?? this.aiResourceSnapshot,
      keyActions: keyActions ?? this.keyActions,
      sosLogs: sosLogs ?? this.sosLogs,
      aidLogs: aidLogs ?? this.aidLogs,
      safeCamps: safeCamps ?? this.safeCamps,
      communicationLogs: communicationLogs ?? this.communicationLogs,
      weatherHistory: weatherHistory ?? this.weatherHistory,
      decisionHistory: decisionHistory ?? this.decisionHistory,
    );
  }

  String get severityText {
    switch (severity) {
      case IncidentSeverity.medium:
        return 'Medium';
      case IncidentSeverity.high:
        return 'High';
      case IncidentSeverity.critical:
        return 'Critical';
    }
  }

  String get statusText {
    switch (status) {
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.ongoing:
        return 'Ongoing';
    }
  }

  DateTime get timestamp => closedAt;

  String get duration => _formatDuration(closedAt.difference(startedAt));

  String get responseTime {
    final candidates = <DateTime>[
      ...decisionHistory.map((entry) => entry.timestamp),
      ...communicationLogs.map((entry) => entry.timestamp),
      ...weatherHistory.map((entry) => entry.timestamp),
    ]..sort();

    if (candidates.isEmpty) {
      return '--';
    }

    final firstAction = candidates.first;
    if (firstAction.isBefore(startedAt)) {
      return '--';
    }
    return _formatDuration(firstAction.difference(startedAt));
  }

  String get areaSummary => area.summaryLabel;

  int get totalAffectedPopulation => affectedCount;

  List<String> get aiSuggestionSummaries => decisionHistory
      .where((entry) => entry.type == 'ai_suggestion')
      .map((entry) => entry.summary)
      .toList();
}
