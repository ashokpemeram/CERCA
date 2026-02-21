import '../models/zone.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

/// Service for zone detection and management
class ZoneService {
  static final ZoneService _instance = ZoneService._internal();
  factory ZoneService() => _instance;
  ZoneService._internal();

  /// Check if a location is within a zone
  bool isLocationInZone({
    required double latitude,
    required double longitude,
    required Zone zone,
  }) {
    final double distance = Helpers.calculateDistance(
      latitude,
      longitude,
      zone.latitude,
      zone.longitude,
    );

    return distance <= zone.radiusInMeters;
  }

  /// Get all zones that contain the given location
  List<Zone> getZonesContainingLocation({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
  }) {
    return allZones.where((zone) {
      return isLocationInZone(
        latitude: latitude,
        longitude: longitude,
        zone: zone,
      );
    }).toList();
  }

  /// Get danger zones containing the location
  List<Zone> getDangerZonesAtLocation({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
  }) {
    return getZonesContainingLocation(
      latitude: latitude,
      longitude: longitude,
      allZones: allZones,
    ).where((zone) => zone.type == ZoneType.danger).toList();
  }

  /// Get safe zones containing the location
  List<Zone> getSafeZonesAtLocation({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
  }) {
    return getZonesContainingLocation(
      latitude: latitude,
      longitude: longitude,
      allZones: allZones,
    ).where((zone) => zone.type == ZoneType.safe).toList();
  }

  /// Check if location is near any danger zone (within threshold)
  bool isNearDangerZone({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
    double threshold = AppConstants.dangerZoneThreshold,
  }) {
    for (final zone in allZones) {
      if (zone.type == ZoneType.danger) {
        final double distance = Helpers.calculateDistance(
          latitude,
          longitude,
          zone.latitude,
          zone.longitude,
        );

        // Check if within zone or within threshold distance
        if (distance <= zone.radiusInMeters + threshold) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get nearest danger zone
  Zone? getNearestDangerZone({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
  }) {
    Zone? nearestZone;
    double minDistance = double.infinity;

    for (final zone in allZones) {
      if (zone.type == ZoneType.danger) {
        final double distance = Helpers.calculateDistance(
          latitude,
          longitude,
          zone.latitude,
          zone.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestZone = zone;
        }
      }
    }

    return nearestZone;
  }

  /// Get nearest safe zone
  Zone? getNearestSafeZone({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
  }) {
    Zone? nearestZone;
    double minDistance = double.infinity;

    for (final zone in allZones) {
      if (zone.type == ZoneType.safe) {
        final double distance = Helpers.calculateDistance(
          latitude,
          longitude,
          zone.latitude,
          zone.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestZone = zone;
        }
      }
    }

    return nearestZone;
  }

  /// Get distance to zone edge
  double getDistanceToZone({
    required double latitude,
    required double longitude,
    required Zone zone,
  }) {
    final double distanceToCenter = Helpers.calculateDistance(
      latitude,
      longitude,
      zone.latitude,
      zone.longitude,
    );

    // If inside zone, return 0
    if (distanceToCenter <= zone.radiusInMeters) {
      return 0;
    }

    // Return distance to zone edge
    return distanceToCenter - zone.radiusInMeters;
  }

  /// Get zone status summary for a location
  ZoneStatus getZoneStatus({
    required double latitude,
    required double longitude,
    required List<Zone> allZones,
  }) {
    final dangerZones = getDangerZonesAtLocation(
      latitude: latitude,
      longitude: longitude,
      allZones: allZones,
    );

    final safeZones = getSafeZonesAtLocation(
      latitude: latitude,
      longitude: longitude,
      allZones: allZones,
    );

    final safeCamps = getZonesContainingLocation(
      latitude: latitude,
      longitude: longitude,
      allZones: allZones,
    ).where((zone) => zone.type == ZoneType.safeCamp).toList();

    final isNearDanger = isNearDangerZone(
      latitude: latitude,
      longitude: longitude,
      allZones: allZones,
    );

    // Prioritize high-intensity zones
    Zone? highestPriorityZone;
    ZoneIntensity? highestIntensity;
    
    for (final zone in dangerZones) {
      if (zone.intensity == ZoneIntensity.high) {
        highestPriorityZone = zone;
        highestIntensity = ZoneIntensity.high;
        break; // High is the highest priority
      } else if (zone.intensity == ZoneIntensity.medium && highestIntensity == null) {
        highestPriorityZone = zone;
        highestIntensity = ZoneIntensity.medium;
      }
    }

    return ZoneStatus(
      isInDangerZone: dangerZones.isNotEmpty,
      isInSafeZone: safeZones.isNotEmpty,
      isNearDangerZone: isNearDanger,
      dangerZones: dangerZones,
      safeZones: safeZones,
      safeCamps: safeCamps,
      highestIntensity: highestIntensity,
      priorityZone: highestPriorityZone,
    );
  }
}

/// Zone status information
class ZoneStatus {
  final bool isInDangerZone;
  final bool isInSafeZone;
  final bool isNearDangerZone;
  final List<Zone> dangerZones;
  final List<Zone> safeZones;
  final List<Zone> safeCamps;
  final ZoneIntensity? highestIntensity;
  final Zone? priorityZone;

  ZoneStatus({
    required this.isInDangerZone,
    required this.isInSafeZone,
    required this.isNearDangerZone,
    required this.dangerZones,
    required this.safeZones,
    this.safeCamps = const [],
    this.highestIntensity,
    this.priorityZone,
  });

  bool get isInHighIntensityZone => highestIntensity == ZoneIntensity.high;
  bool get isInMediumRiskZone => highestIntensity == ZoneIntensity.medium;
  bool get isInSafeCamp => safeCamps.isNotEmpty;

  String get statusMessage {
    if (isInHighIntensityZone) {
      return '⚠️ DANGER: You are in a High-Intensity Zone';
    } else if (isInMediumRiskZone) {
      return '⚠️ WARNING: You are in a Medium-Risk Zone';
    } else if (isInSafeCamp) {
      return '✓ You are in a Safe Camp';
    } else if (isInSafeZone) {
      return '✓ You are in a safe zone';
    } else if (isNearDangerZone) {
      return '⚠ You are near a danger zone. Be cautious!';
    } else {
      return 'No zones detected nearby';
    }
  }
}
