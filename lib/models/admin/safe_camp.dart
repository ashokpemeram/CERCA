/// Safe camp status enumeration
enum CampStatus {
  active,
  inactive,
}

/// Model for safe camps
class SafeCamp {
  final String id;
  final String name;
  final CampStatus status;
  final double latitude;
  final double longitude;
  final int capacity;
  final int currentOccupancy;
  final String areaId;

  SafeCamp({
    required this.id,
    required this.name,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.currentOccupancy,
    this.areaId = 'UNASSIGNED',
  });

  /// Create from JSON
  factory SafeCamp.fromJson(Map<String, dynamic> json) {
    return SafeCamp(
      id: json['id'] as String,
      name: json['name'] as String,
      status: CampStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CampStatus.active,
      ),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: json['capacity'] as int,
      currentOccupancy: json['currentOccupancy'] as int,
      areaId: (json['areaId'] as String?) ?? 'UNASSIGNED',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'areaId': areaId,
    };
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case CampStatus.active:
        return 'Active';
      case CampStatus.inactive:
        return 'Inactive';
    }
  }

  /// Get location coordinates as string
  String get coordinates => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Get capacity info as string
  String get capacityInfo => '$currentOccupancy / $capacity';

  /// Get occupancy percentage
  double get occupancyPercentage => (currentOccupancy / capacity) * 100;

  /// Check if camp is full
  bool get isFull => currentOccupancy >= capacity;

  SafeCamp copyWith({
    String? id,
    String? name,
    CampStatus? status,
    double? latitude,
    double? longitude,
    int? capacity,
    int? currentOccupancy,
    String? areaId,
  }) {
    return SafeCamp(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      areaId: areaId ?? this.areaId,
    );
  }
}
