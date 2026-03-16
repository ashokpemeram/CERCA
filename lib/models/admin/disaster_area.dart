class DisasterArea {
  final String id; // AREA-YYYYMMDD-XXXX
  final double centerLat;
  final double centerLon;
  final double redRadiusM;
  final double warningRadiusM;
  final double greenRadiusM;
  final double controllableRadiusM;
  final DateTime createdAt;
  DateTime? closedAt;

  DisasterArea({
    required this.id,
    required this.centerLat,
    required this.centerLon,
    required this.redRadiusM,
    required this.warningRadiusM,
    required this.greenRadiusM,
    required this.controllableRadiusM,
    required this.createdAt,
    this.closedAt,
  });

  bool get isActive => closedAt == null;

  DisasterArea copyWith({
    String? id,
    double? centerLat,
    double? centerLon,
    double? redRadiusM,
    double? warningRadiusM,
    double? greenRadiusM,
    double? controllableRadiusM,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return DisasterArea(
      id: id ?? this.id,
      centerLat: centerLat ?? this.centerLat,
      centerLon: centerLon ?? this.centerLon,
      redRadiusM: redRadiusM ?? this.redRadiusM,
      warningRadiusM: warningRadiusM ?? this.warningRadiusM,
      greenRadiusM: greenRadiusM ?? this.greenRadiusM,
      controllableRadiusM: controllableRadiusM ?? this.controllableRadiusM,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }
}

class AreaRouteResult {
  final String areaId;
  final bool insideControllable;
  final double distanceM;

  const AreaRouteResult({
    required this.areaId,
    required this.insideControllable,
    required this.distanceM,
  });
}
