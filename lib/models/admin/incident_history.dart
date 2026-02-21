/// Incident severity enumeration
enum IncidentSeverity {
  high,
  critical,
  medium,
}

/// Incident status enumeration
enum IncidentStatus {
  resolved,
  ongoing,
}

/// Model for disaster history
class IncidentHistory {
  final String id;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final String disasterType;
  final String duration;
  final String responseTime;
  final int affectedCount;
  final int evacuatedCount;
  final DateTime timestamp;

  IncidentHistory({
    required this.id,
    required this.severity,
    required this.status,
    required this.disasterType,
    required this.duration,
    required this.responseTime,
    required this.affectedCount,
    required this.evacuatedCount,
    required this.timestamp,
  });

  /// Create from JSON
  factory IncidentHistory.fromJson(Map<String, dynamic> json) {
    return IncidentHistory(
      id: json['id'] as String,
      severity: IncidentSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => IncidentSeverity.medium,
      ),
      status: IncidentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IncidentStatus.ongoing,
      ),
      disasterType: json['disasterType'] as String,
      duration: json['duration'] as String,
      responseTime: json['responseTime'] as String,
      affectedCount: json['affectedCount'] as int,
      evacuatedCount: json['evacuatedCount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'severity': severity.name,
      'status': status.name,
      'disasterType': disasterType,
      'duration': duration,
      'responseTime': responseTime,
      'affectedCount': affectedCount,
      'evacuatedCount': evacuatedCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get severity display text
  String get severityText {
    switch (severity) {
      case IncidentSeverity.high:
        return 'High';
      case IncidentSeverity.critical:
        return 'Critical';
      case IncidentSeverity.medium:
        return 'Medium';
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.ongoing:
        return 'Ongoing';
    }
  }
}
