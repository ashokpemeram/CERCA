enum DisasterSeverity {
  low,
  medium,
  high,
}

enum DisasterStatus {
  active,
  inactive,
}

class DisasterEvent {
  final String id;
  final String type;
  final double centerLat;
  final double centerLon;
  final double radiusM;
  final DisasterSeverity severity;
  final DateTime createdAt;
  final DisasterStatus status;
  final int totalCitizens;
  final int generatedCitizens;

  DisasterEvent({
    required this.id,
    required this.type,
    required this.centerLat,
    required this.centerLon,
    required this.radiusM,
    required this.severity,
    required this.createdAt,
    required this.status,
    required this.totalCitizens,
    required this.generatedCitizens,
  });

  bool get isActive => status == DisasterStatus.active;

  DisasterEvent copyWith({
    String? id,
    String? type,
    double? centerLat,
    double? centerLon,
    double? radiusM,
    DisasterSeverity? severity,
    DateTime? createdAt,
    DisasterStatus? status,
    int? totalCitizens,
    int? generatedCitizens,
  }) {
    return DisasterEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      centerLat: centerLat ?? this.centerLat,
      centerLon: centerLon ?? this.centerLon,
      radiusM: radiusM ?? this.radiusM,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalCitizens: totalCitizens ?? this.totalCitizens,
      generatedCitizens: generatedCitizens ?? this.generatedCitizens,
    );
  }
}
