import 'package:flutter/foundation.dart';
import '../models/zone.dart';
import '../models/precaution.dart';
import '../services/api_service.dart';
import '../services/zone_service.dart';
import 'package:flutter/material.dart';

/// Provider for zone and precaution state management
class ZoneProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ZoneService _zoneService = ZoneService();

  List<Zone> _zones = [];
  List<Precaution> _allPrecautions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Zone> get zones => _zones;
  List<Zone> get dangerZones =>
      _zones.where((z) => z.type == ZoneType.danger).toList();
  List<Zone> get safeZones =>
      _zones.where((z) => z.type == ZoneType.safe).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  /// Initialize and fetch zones
  /// Optionally provide user's location to position zones around them
  Future<void> initialize({double? latitude, double? longitude}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch zones from API, positioned around user's location if provided
      final response = await _apiService.fetchZones(
        latitude: latitude,
        longitude: longitude,
      );

      if (response.success && response.data != null) {
        _zones = response.data!.map((json) => Zone.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }

      // Initialize precautions
      _initializePrecautions();
    } catch (e) {
      _errorMessage = 'Error fetching zones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get precautions based on location
  List<Precaution> getPrecautionsForLocation({
    required double latitude,
    required double longitude,
  }) {
    final zoneStatus = _zoneService.getZoneStatus(
      latitude: latitude,
      longitude: longitude,
      allZones: _zones,
    );

    // Return all general precautions
    List<Precaution> applicablePrecautions = _allPrecautions
        .where((p) => p.applicableZone == null)
        .toList();

    // Add danger zone specific precautions if in or near danger zone
    if (zoneStatus.isInDangerZone || zoneStatus.isNearDangerZone) {
      applicablePrecautions.addAll(
        _allPrecautions.where((p) => p.applicableZone == ZoneType.danger),
      );
    }

    // Add safe zone specific precautions if in safe zone
    if (zoneStatus.isInSafeZone) {
      applicablePrecautions.addAll(
        _allPrecautions.where((p) => p.applicableZone == ZoneType.safe),
      );
    }

    return applicablePrecautions;
  }

  /// Get zone status for location
  ZoneStatus getZoneStatus({
    required double latitude,
    required double longitude,
  }) {
    return _zoneService.getZoneStatus(
      latitude: latitude,
      longitude: longitude,
      allZones: _zones,
    );
  }

  /// Initialize precautions data
  void _initializePrecautions() {
    _allPrecautions = [
      // General precautions
      Precaution(
        id: 'p1',
        title: 'Stay Alert',
        description: 'Always be aware of your surroundings and trust your instincts.',
        icon: Icons.visibility,
        applicableZone: null,
      ),
      Precaution(
        id: 'p2',
        title: 'Keep Phone Charged',
        description: 'Ensure your phone has sufficient battery for emergencies.',
        icon: Icons.battery_charging_full,
        applicableZone: null,
      ),
      Precaution(
        id: 'p3',
        title: 'Share Location',
        description: 'Share your location with trusted contacts when traveling.',
        icon: Icons.share_location,
        applicableZone: null,
      ),
      Precaution(
        id: 'p4',
        title: 'Emergency Contacts',
        description: 'Keep emergency contact numbers readily accessible.',
        icon: Icons.contact_phone,
        applicableZone: null,
      ),

      // Danger zone specific
      Precaution(
        id: 'p5',
        title: 'Avoid Isolated Areas',
        description: 'Stay in well-lit, populated areas. Avoid shortcuts through isolated places.',
        icon: Icons.warning_amber,
        applicableZone: ZoneType.danger,
      ),
      Precaution(
        id: 'p6',
        title: 'Travel in Groups',
        description: 'If possible, travel with others. There is safety in numbers.',
        icon: Icons.group,
        applicableZone: ZoneType.danger,
      ),
      Precaution(
        id: 'p7',
        title: 'Be Prepared to Call for Help',
        description: 'Have emergency services on speed dial and be ready to use SOS.',
        icon: Icons.phone_in_talk,
        applicableZone: ZoneType.danger,
      ),
      Precaution(
        id: 'p8',
        title: 'Stay Visible',
        description: 'Keep to well-lit areas and avoid dark corners or alleys.',
        icon: Icons.lightbulb,
        applicableZone: ZoneType.danger,
      ),

      // Safe zone specific
      Precaution(
        id: 'p9',
        title: 'You\'re in a Safe Area',
        description: 'This area is monitored and has good security presence.',
        icon: Icons.verified_user,
        applicableZone: ZoneType.safe,
      ),
      Precaution(
        id: 'p10',
        title: 'Community Support',
        description: 'Local community and authorities are active in this area.',
        icon: Icons.people,
        applicableZone: ZoneType.safe,
      ),
    ];
  }

  /// Refresh zones
  Future<void> refresh() async {
    await initialize();
  }
}
