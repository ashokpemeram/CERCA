/// Agent status enumeration
enum AgentStatusType {
  online,
  offline,
  standby,
}

/// Model for agent health monitoring
class AgentStatus {
  final String name;
  final AgentStatusType status;
  final DateTime lastUpdate;

  AgentStatus({
    required this.name,
    required this.status,
    required this.lastUpdate,
  });

  /// Create from JSON
  factory AgentStatus.fromJson(Map<String, dynamic> json) {
    return AgentStatus(
      name: json['name'] as String,
      status: AgentStatusType.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AgentStatusType.offline,
      ),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status.name,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case AgentStatusType.online:
        return 'Online';
      case AgentStatusType.offline:
        return 'Offline';
      case AgentStatusType.standby:
        return 'Standby';
    }
  }
}
