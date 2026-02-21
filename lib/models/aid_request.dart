/// Model representing an aid request
class AidRequest {
  final String? id;
  final String resourceType;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status;

  AidRequest({
    this.id,
    required this.resourceType,
    required this.description,
    required this.latitude,
    required this.longitude,
    DateTime? timestamp,
    this.status = 'pending',
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resourceType': resourceType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  // Create from JSON
  factory AidRequest.fromJson(Map<String, dynamic> json) {
    return AidRequest(
      id: json['id'] as String?,
      resourceType: json['resourceType'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  // Copy with method for updating fields
  AidRequest copyWith({
    String? id,
    String? resourceType,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? status,
  }) {
    return AidRequest(
      id: id ?? this.id,
      resourceType: resourceType ?? this.resourceType,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
