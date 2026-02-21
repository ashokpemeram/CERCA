/// Enum for zone types
enum ZoneType {
  danger,
  safe,
  safeCamp,
}

/// Enum for danger zone intensity levels
enum ZoneIntensity {
  high,   // Red zone - high-intensity danger
  medium, // Orange zone - medium-risk
}

/// Model representing a geographical zone (danger or safe)
class Zone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final ZoneType type;
  final String? description;
  final ZoneIntensity? intensity; // Only applicable for danger zones

  Zone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    required this.type,
    this.description,
    this.intensity,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusInMeters': radiusInMeters,
      'type': type.toString().split('.').last,
      'description': description,
      'intensity': intensity?.toString().split('.').last,
    };
  }

  // Create from JSON
  factory Zone.fromJson(Map<String, dynamic> json) {
    ZoneType zoneType;
    switch (json['type'] as String) {
      case 'danger':
        zoneType = ZoneType.danger;
        break;
      case 'safeCamp':
        zoneType = ZoneType.safeCamp;
        break;
      default:
        zoneType = ZoneType.safe;
    }

    ZoneIntensity? intensity;
    if (json['intensity'] != null) {
      intensity = json['intensity'] == 'high'
          ? ZoneIntensity.high
          : ZoneIntensity.medium;
    }

    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusInMeters: (json['radiusInMeters'] as num).toDouble(),
      type: zoneType,
      description: json['description'] as String?,
      intensity: intensity,
    );
  }
}
