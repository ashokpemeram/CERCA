/// Sensor trend enumeration
enum SensorTrend {
  up,
  down,
  stable,
}

/// Model for live sensor data
class SensorReading {
  final String type;
  final double value;
  final String unit;
  final SensorTrend trend;
  final DateTime timestamp;

  SensorReading({
    required this.type,
    required this.value,
    required this.unit,
    required this.trend,
    required this.timestamp,
  });

  /// Create from JSON
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      trend: SensorTrend.values.firstWhere(
        (e) => e.name == json['trend'],
        orElse: () => SensorTrend.stable,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'unit': unit,
      'trend': trend.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get formatted value with unit
  String get formattedValue => '$value $unit';

  /// Get trend display text
  String get trendText {
    switch (trend) {
      case SensorTrend.up:
        return 'Up';
      case SensorTrend.down:
        return 'Down';
      case SensorTrend.stable:
        return 'Stable';
    }
  }
}
