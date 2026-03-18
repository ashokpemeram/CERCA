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
  final String areaId;
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
    required this.areaId,
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

  factory DisasterEvent.fromSimulationJson(Map<String, dynamic> json) {
    final severityName =
        (json['severity'] as String?)?.toLowerCase() ?? 'medium';
    return DisasterEvent(
      id: json['id'] as String,
      areaId: json['areaId'] as String? ?? '',
      type: json['disasterType'] as String? ?? 'Disaster',
      centerLat: (json['centerLat'] as num?)?.toDouble() ?? 0,
      centerLon: (json['centerLon'] as num?)?.toDouble() ?? 0,
      radiusM: (json['radiusM'] as num?)?.toDouble() ?? 0,
      severity: DisasterSeverity.values.firstWhere(
        (value) => value.name == severityName,
        orElse: () => DisasterSeverity.medium,
      ),
      createdAt: DateTime.tryParse(
            json['startedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      status: (json['isActive'] as bool? ?? false)
          ? DisasterStatus.active
          : DisasterStatus.inactive,
      totalCitizens: (json['totalCitizens'] as num?)?.toInt() ?? 0,
      generatedCitizens: (json['generatedCitizens'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isActive => status == DisasterStatus.active;

  DisasterEvent copyWith({
    String? id,
    String? areaId,
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
      areaId: areaId ?? this.areaId,
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
