/// SOS request status enumeration
enum SosStatus {
  pending,
  dispatched,
}

/// Model for SOS emergency requests
class SosRequest {
  final String id;
  final SosStatus status;
  final String callerName;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? eta;
  final String areaId;
  final bool insideControllableZone;
  final String source;
  final String? disasterId;

  SosRequest({
    required this.id,
    required this.status,
    required this.callerName,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.eta,
    this.areaId = 'UNASSIGNED',
    this.insideControllableZone = false,
    this.source = 'citizen',
    this.disasterId,
  });

  /// Create from JSON
  factory SosRequest.fromJson(Map<String, dynamic> json) {
    return SosRequest(
      id: json['id'] as String,
      status: SosStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SosStatus.pending,
      ),
      callerName: json['callerName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      eta: json['eta'] as String?,
      areaId: (json['areaId'] as String?) ?? 'UNASSIGNED',
      insideControllableZone:
          (json['insideControllableZone'] as bool?) ?? false,
      source: (json['source'] as String?) ?? 'citizen',
      disasterId: json['disasterId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'callerName': callerName,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'eta': eta,
      'areaId': areaId,
      'insideControllableZone': insideControllableZone,
      'source': source,
      'disasterId': disasterId,
    };
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case SosStatus.pending:
        return 'Pending';
      case SosStatus.dispatched:
        return 'Dispatched';
    }
  }

  /// Get location coordinates as string
  String get coordinates => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Create a copy with updated fields
  SosRequest copyWith({
    String? id,
    SosStatus? status,
    String? callerName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? eta,
    String? areaId,
    bool? insideControllableZone,
    String? source,
    String? disasterId,
  }) {
    return SosRequest(
      id: id ?? this.id,
      status: status ?? this.status,
      callerName: callerName ?? this.callerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      eta: eta ?? this.eta,
      areaId: areaId ?? this.areaId,
      insideControllableZone:
          insideControllableZone ?? this.insideControllableZone,
      source: source ?? this.source,
      disasterId: disasterId ?? this.disasterId,
    );
  }
}
