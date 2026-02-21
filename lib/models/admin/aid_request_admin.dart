/// Aid request priority enumeration
enum AidPriority {
  high,
  medium,
  low,
}

/// Aid request status enumeration
enum AidStatus {
  pending,
  dispatched,
}

/// Model for aid requests
class AidRequestAdmin {
  final String id;
  final AidPriority priority;
  final AidStatus status;
  final String requesterName;
  final List<String> resources;
  final int peopleCount;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  AidRequestAdmin({
    required this.id,
    required this.priority,
    required this.status,
    required this.requesterName,
    required this.resources,
    required this.peopleCount,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  /// Create from JSON
  factory AidRequestAdmin.fromJson(Map<String, dynamic> json) {
    return AidRequestAdmin(
      id: json['id'] as String,
      priority: AidPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AidPriority.medium,
      ),
      status: AidStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AidStatus.pending,
      ),
      requesterName: json['requesterName'] as String,
      resources: List<String>.from(json['resources'] as List),
      peopleCount: json['peopleCount'] as int,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priority': priority.name,
      'status': status.name,
      'requesterName': requesterName,
      'resources': resources,
      'peopleCount': peopleCount,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get priority display text
  String get priorityText {
    switch (priority) {
      case AidPriority.high:
        return 'High';
      case AidPriority.medium:
        return 'Medium';
      case AidPriority.low:
        return 'Low';
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case AidStatus.pending:
        return 'Pending';
      case AidStatus.dispatched:
        return 'Dispatched';
    }
  }

  /// Get resources as comma-separated string
  String get resourcesText => resources.join(', ');

  /// Get location coordinates as string
  String get coordinates => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Create a copy with updated fields
  AidRequestAdmin copyWith({
    String? id,
    AidPriority? priority,
    AidStatus? status,
    String? requesterName,
    List<String>? resources,
    int? peopleCount,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) {
    return AidRequestAdmin(
      id: id ?? this.id,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      requesterName: requesterName ?? this.requesterName,
      resources: resources ?? this.resources,
      peopleCount: peopleCount ?? this.peopleCount,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
