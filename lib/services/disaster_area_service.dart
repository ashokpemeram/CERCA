import 'dart:math';
import '../models/admin/disaster_area.dart';
import '../models/admin/sos_request.dart';
import '../models/admin/aid_request_admin.dart';
import '../utils/helpers.dart';

class DisasterAreaService {
  static const double _clusterDistanceM = 2500;
  static const int _minEventsPerCluster = 3;
  static const double _redMinM = 300;
  static const double _redMaxM = 2000;
  static const double _warningMaxM = 5000;
  static final Random _random = Random();

  static List<DisasterArea> computeAreas(
    List<SosRequest> sos,
    List<AidRequestAdmin> aid, {
    Set<String>? existingAreaIds,
  }) {
    final points = <_IncidentPoint>[
      for (final s in sos)
        _IncidentPoint(
          lat: s.latitude,
          lon: s.longitude,
          weight: 3.0,
          isCritical: true,
          isMediumOrHigher: true,
        ),
      for (final a in aid)
        _IncidentPoint(
          lat: a.latitude,
          lon: a.longitude,
          weight: _aidWeight(a.priority),
          isCritical: a.priority == AidPriority.high,
          isMediumOrHigher: a.priority != AidPriority.low,
        ),
    ];

    if (points.isEmpty) {
      return [];
    }

    var clusters = _clusterPoints(points)
        .where((cluster) => cluster.length >= _minEventsPerCluster)
        .toList();

    if (clusters.isEmpty && points.length >= _minEventsPerCluster) {
      clusters = [points];
    }

    if (clusters.isEmpty) {
      return [];
    }

    final ids = {...?existingAreaIds};
    final now = DateTime.now();

    return [
      for (final cluster in clusters)
        _buildAreaForCluster(cluster, ids, now),
    ];
  }

  static AreaRouteResult routeToArea(
    double lat,
    double lon,
    List<DisasterArea> areas,
  ) {
    final activeAreas = areas.where((a) => a.isActive).toList();
    if (activeAreas.isEmpty) {
      return const AreaRouteResult(
        areaId: 'UNASSIGNED',
        insideControllable: false,
        distanceM: double.infinity,
      );
    }

    DisasterArea? nearest;
    double nearestDistance = double.infinity;
    for (final area in activeAreas) {
      final distance = Helpers.calculateDistance(
        lat,
        lon,
        area.centerLat,
        area.centerLon,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = area;
      }
    }

    final resolvedArea = nearest ?? activeAreas.first;
    final inside = nearestDistance <= resolvedArea.controllableRadiusM;
    return AreaRouteResult(
      areaId: resolvedArea.id,
      insideControllable: inside,
      distanceM: nearestDistance,
    );
  }

  static DisasterArea _buildAreaForCluster(
    List<_IncidentPoint> cluster,
    Set<String> existingIds,
    DateTime now,
  ) {
    final center = _weightedCentroid(cluster);
    final distancesAll = _sortedDistances(cluster, center);

    final criticalPoints = cluster.where((p) => p.isCritical).toList();
    final criticalDistances = _sortedDistances(criticalPoints, center);
    final criticalMediumPoints =
        cluster.where((p) => p.isMediumOrHigher).toList();
    final criticalMediumDistances =
        _sortedDistances(criticalMediumPoints, center);

    final redBase = _percentile(
      criticalDistances.isNotEmpty ? criticalDistances : distancesAll,
      0.85,
    );
    final redRadius = redBase.clamp(_redMinM, _redMaxM);

    final warningBase = _percentile(
      criticalMediumDistances.isNotEmpty
          ? criticalMediumDistances
          : distancesAll,
      0.85,
    );
    final warningRadius = max(warningBase, redRadius + 200).clamp(
      redRadius + 200,
      _warningMaxM,
    );

    final controllableRadius = warningRadius * 2.0;

    final greenBase = _percentile(distancesAll, 0.90);
    final greenMin = warningRadius + 100;
    final greenMax = controllableRadius - 100;
    final greenRadius = greenMax >= greenMin
        ? greenBase.clamp(greenMin, greenMax)
        : greenMin;

    return DisasterArea(
      id: generateAreaId(existingIds, now: now),
      centerLat: center.lat,
      centerLon: center.lon,
      redRadiusM: redRadius,
      warningRadiusM: warningRadius,
      greenRadiusM: greenRadius,
      controllableRadiusM: controllableRadius,
      createdAt: now,
    );
  }

  static double _aidWeight(AidPriority priority) {
    switch (priority) {
      case AidPriority.high:
        return 2.0;
      case AidPriority.medium:
        return 1.5;
      case AidPriority.low:
        return 1.0;
    }
  }

  static List<List<_IncidentPoint>> _clusterPoints(
    List<_IncidentPoint> points,
  ) {
    final clusters = <List<_IncidentPoint>>[];
    for (final point in points) {
      final matching = <List<_IncidentPoint>>[];
      for (final cluster in clusters) {
        final isNear = cluster.any(
          (p) =>
              Helpers.calculateDistance(p.lat, p.lon, point.lat, point.lon) <=
              _clusterDistanceM,
        );
        if (isNear) {
          matching.add(cluster);
        }
      }

      if (matching.isEmpty) {
        clusters.add([point]);
      } else {
        final merged = <_IncidentPoint>[point];
        for (final cluster in matching) {
          merged.addAll(cluster);
        }
        clusters.removeWhere((cluster) => matching.contains(cluster));
        clusters.add(merged);
      }
    }
    return clusters;
  }

  static _Centroid _weightedCentroid(List<_IncidentPoint> points) {
    double sumLat = 0;
    double sumLon = 0;
    double sumWeight = 0;
    for (final point in points) {
      sumLat += point.lat * point.weight;
      sumLon += point.lon * point.weight;
      sumWeight += point.weight;
    }
    if (sumWeight == 0) {
      return _Centroid(points.first.lat, points.first.lon);
    }
    return _Centroid(sumLat / sumWeight, sumLon / sumWeight);
  }

  static List<double> _sortedDistances(
    List<_IncidentPoint> points,
    _Centroid center,
  ) {
    if (points.isEmpty) {
      return [];
    }
    final distances = [
      for (final p in points)
        Helpers.calculateDistance(center.lat, center.lon, p.lat, p.lon),
    ];
    distances.sort();
    return distances;
  }

  static double _percentile(List<double> sorted, double p) {
    if (sorted.isEmpty) {
      return 0;
    }
    if (sorted.length == 1) {
      return sorted.first;
    }
    final clampedP = p.clamp(0.0, 1.0);
    final index = (sorted.length - 1) * clampedP;
    final lower = index.floor();
    final upper = index.ceil();
    if (lower == upper) {
      return sorted[lower];
    }
    final fraction = index - lower;
    return sorted[lower] + (sorted[upper] - sorted[lower]) * fraction;
  }

  static String generateAreaId(
    Set<String> existingIds, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final datePart =
        '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';

    String id;
    do {
      final value = _random.nextInt(36 * 36 * 36 * 36);
      final suffix = value.toRadixString(36).toUpperCase().padLeft(4, '0');
      id = 'AREA-$datePart-$suffix';
    } while (existingIds.contains(id));

    existingIds.add(id);
    return id;
  }

  static DisasterArea createAreaForPoint(
    double lat,
    double lon,
    Set<String> existingIds, {
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();
    final id = generateAreaId(existingIds, now: createdAt);

    const redRadius = 300.0;
    const warningRadius = 600.0;
    const controllableRadius = 1200.0;
    const greenRadius = 900.0;

    return DisasterArea(
      id: id,
      centerLat: lat,
      centerLon: lon,
      redRadiusM: redRadius,
      warningRadiusM: warningRadius,
      greenRadiusM: greenRadius,
      controllableRadiusM: controllableRadius,
      createdAt: createdAt,
    );
  }
}

class _IncidentPoint {
  final double lat;
  final double lon;
  final double weight;
  final bool isCritical;
  final bool isMediumOrHigher;

  _IncidentPoint({
    required this.lat,
    required this.lon,
    required this.weight,
    required this.isCritical,
    required this.isMediumOrHigher,
  });
}

class _Centroid {
  final double lat;
  final double lon;

  const _Centroid(this.lat, this.lon);
}
