/// Communication log type enumeration
enum CommunicationLogType { sms, alert, evacuation, resource }

/// Model for communication logs
class CommunicationLog {
  final String id;
  final CommunicationLogType type;
  final String message;
  final DateTime timestamp;
  final String? areaId;

  CommunicationLog({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.areaId,
  });

  /// Create from JSON
  factory CommunicationLog.fromJson(Map<String, dynamic> json) {
    return CommunicationLog(
      id: json['id'] as String,
      type: CommunicationLogType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CommunicationLogType.sms,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      areaId: json['areaId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'areaId': areaId,
    };
  }

  /// Get formatted time
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
