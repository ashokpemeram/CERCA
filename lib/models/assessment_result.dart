/// Model for the response from POST /assess on the disaster_system backend.
class AssessmentResult {
  final String location;
  final String overallRisk; // "low", "medium", "high"
  final String? alertMessage; // AI-generated message, present when risk >= medium
  final String? safeMessage; // Present when area is safe
  final double? temperatureC;
  final String? weatherCondition;
  final double? windKph;
  final List<String> newsEvents;
  final String? weatherRiskLevel;
  final String? newsRiskLevel;

  AssessmentResult({
    required this.location,
    required this.overallRisk,
    this.alertMessage,
    this.safeMessage,
    this.temperatureC,
    this.weatherCondition,
    this.windKph,
    this.newsEvents = const [],
    this.weatherRiskLevel,
    this.newsRiskLevel,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    String location = '';
    String overallRisk = 'low';
    String? alertMessage;
    String? safeMessage;
    double? temperatureC;
    String? weatherCondition;
    double? windKph;
    List<String> newsEvents = [];
    String? weatherRiskLevel;
    String? newsRiskLevel;

    // Case 1: medium/high risk — response has alert_message + risk
    if (json.containsKey('alert_message')) {
      alertMessage = json['alert_message'] as String?;
      final risk = json['risk'] as Map<String, dynamic>?;
      if (risk != null) {
        location = risk['location'] as String? ?? '';
        overallRisk = risk['overall_risk'] as String? ?? 'medium';
        _extractWeatherNews(
          risk,
          setTemp: (v) => temperatureC = v,
          setCondition: (v) => weatherCondition = v,
          setWind: (v) => windKph = v,
          setEvents: (v) => newsEvents = v,
          setWeatherRisk: (v) => weatherRiskLevel = v,
          setNewsRisk: (v) => newsRiskLevel = v,
        );
      }
    }
    // Case 2: low risk — response has message + risk
    else if (json.containsKey('message') && json.containsKey('risk')) {
      safeMessage = json['message'] as String?;
      final risk = json['risk'] as Map<String, dynamic>?;
      if (risk != null) {
        location = risk['location'] as String? ?? '';
        overallRisk = risk['overall_risk'] as String? ?? 'low';
        _extractWeatherNews(
          risk,
          setTemp: (v) => temperatureC = v,
          setCondition: (v) => weatherCondition = v,
          setWind: (v) => windKph = v,
          setEvents: (v) => newsEvents = v,
          setWeatherRisk: (v) => weatherRiskLevel = v,
          setNewsRisk: (v) => newsRiskLevel = v,
        );
      }
    }

    return AssessmentResult(
      location: location,
      overallRisk: overallRisk,
      alertMessage: alertMessage,
      safeMessage: safeMessage,
      temperatureC: temperatureC,
      weatherCondition: weatherCondition,
      windKph: windKph,
      newsEvents: newsEvents,
      weatherRiskLevel: weatherRiskLevel,
      newsRiskLevel: newsRiskLevel,
    );
  }

  static void _extractWeatherNews(
    Map<String, dynamic> risk, {
    required void Function(double?) setTemp,
    required void Function(String?) setCondition,
    required void Function(double?) setWind,
    required void Function(List<String>) setEvents,
    required void Function(String?) setWeatherRisk,
    required void Function(String?) setNewsRisk,
  }) {
    final weather = risk['weather'] as Map<String, dynamic>?;
    if (weather != null) {
      setWeatherRisk(weather['risk_level'] as String?);
      final rawData = weather['raw_data'] as Map<String, dynamic>?;
      final current = rawData?['current'] as Map<String, dynamic>?;
      if (current != null) {
        setTemp((current['temp_c'] as num?)?.toDouble());
        setWind((current['wind_kph'] as num?)?.toDouble());
        final condition = current['condition'] as Map<String, dynamic>?;
        setCondition(condition?['text'] as String?);
      }
    }
    final news = risk['news'] as Map<String, dynamic>?;
    if (news != null) {
      setNewsRisk(news['risk_level'] as String?);
      final events = news['events'] as List<dynamic>?;
      setEvents(events?.cast<String>() ?? []);
    }
  }
}
