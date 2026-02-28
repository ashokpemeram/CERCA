import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/zone_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../models/zone.dart' as app_zone;
import '../../models/assessment_result.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

/// Map tab showing user location, static zones, and live AI risk circle
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();
  bool _hasAutoAssessed = false;
  Timer? _assessmentTimer;

  @override
  void initState() {
    super.initState();
    // Re-assess every 60 seconds
    _assessmentTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final loc = context.read<LocationProvider>();
      if (loc.latitude != null && loc.longitude != null) {
        context
            .read<AssessmentProvider>()
            .assessByCoordinates(loc.latitude!, loc.longitude!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-assess on first load once location is ready
    if (!_hasAutoAssessed) {
      final loc = context.read<LocationProvider>();
      if (loc.latitude != null && loc.longitude != null) {
        _hasAutoAssessed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<AssessmentProvider>()
              .assessByCoordinates(loc.latitude!, loc.longitude!);
        });
      }
    }
  }

  @override
  void dispose() {
    _assessmentTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocationProvider, ZoneProvider, AssessmentProvider>(
      builder: (context, locationProvider, zoneProvider, assessmentProvider, child) {
        if (locationProvider.isLoading) {
          return const LoadingIndicator(message: 'Getting your location...');
        }

        if (locationProvider.errorMessage != null) {
          return _buildErrorView(locationProvider);
        }

        if (locationProvider.currentPosition == null) {
          return const Center(child: Text('Unable to get location'));
        }

        final position = locationProvider.currentPosition!;
        final currentLatLng = LatLng(position.latitude, position.longitude);
        final result = assessmentProvider.result;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentLatLng,
                initialZoom: AppConstants.defaultZoom,
                minZoom: 5.0,
                maxZoom: 18.0,
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cerca.app',
                ),

                // Static zone circles — only shown when no AI result yet
                CircleLayer(
                  circles: _buildCircleLayers(zoneProvider.zones, result),
                ),

                // Live AI risk circle — drawn around the user's location
                if (result != null)
                  CircleLayer(
                    circles: [_buildAiRiskCircle(currentLatLng, result)],
                  ),

                // Markers (user + safe camp icons always; danger icons only without AI)
                MarkerLayer(
                  markers: _buildMarkers(
                    currentLatLng,
                    zoneProvider.zones,
                    result,
                    assessmentProvider.isLoading,
                  ),
                ),
              ],
            ),

            // Legend
            Positioned(
              top: 16,
              right: 16,
              child: _buildLegend(result != null),
            ),

            // Recenter button
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildRecenterButton(currentLatLng),
            ),

            // AI Risk banner (replaces static zone banner)
            Positioned(
              top: 16,
              left: 16,
              right: 100,
              child: _buildRiskBanner(
                position.latitude,
                position.longitude,
                zoneProvider,
                assessmentProvider,
              ),
            ),

            // Loading indicator overlay (small, non-blocking)
            if (assessmentProvider.isLoading)
              Positioned(
                bottom: 80,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Updating risk...',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds a filled circle around the user's GPS position coloured by AI risk
  CircleMarker _buildAiRiskCircle(LatLng center, AssessmentResult result) {
    Color color;
    Color border;
    double radius;

    switch (result.overallRisk.toLowerCase()) {
      case 'high':
        color = AppConstants.dangerColor.withOpacity(0.25);
        border = AppConstants.dangerColor;
        radius = 1200; // metres
        break;
      case 'medium':
        color = AppConstants.warningColor.withOpacity(0.20);
        border = AppConstants.warningColor;
        radius = 900;
        break;
      default:
        color = AppConstants.safeColor.withOpacity(0.15);
        border = AppConstants.safeColor;
        radius = 600;
        break;
    }

    return CircleMarker(
      point: center,
      radius: radius,
      useRadiusInMeter: true,
      color: color,
      borderColor: border,
      borderStrokeWidth: 2.5,
    );
  }

  Widget _buildRiskBanner(
    double latitude,
    double longitude,
    ZoneProvider zoneProvider,
    AssessmentProvider assessmentProvider,
  ) {
    final result = assessmentProvider.result;

    // Use AI result if available
    if (result != null) {
      Color bannerColor;
      IconData bannerIcon;
      String message;

      switch (result.overallRisk.toLowerCase()) {
        case 'high':
          bannerColor = AppConstants.dangerColor;
          bannerIcon = Icons.warning_amber_rounded;
          message = result.alertMessage != null
              ? '⚠️ HIGH RISK: ${result.alertMessage!.split('.').first}.'
              : '⚠️ HIGH RISK in your area';
          break;
        case 'medium':
          bannerColor = AppConstants.warningColor;
          bannerIcon = Icons.warning_outlined;
          message = result.alertMessage != null
              ? '⚠️ MEDIUM RISK: ${result.alertMessage!.split('.').first}.'
              : '⚠️ MEDIUM RISK in your area';
          break;
        default:
          bannerColor = AppConstants.safeColor;
          bannerIcon = Icons.check_circle_outline;
          message = result.weatherCondition != null
              ? '✓ Area is safe  •  ${result.weatherCondition}  ${result.temperatureC?.toStringAsFixed(0) ?? ''}°C'
              : '✓ Area is safe';
          break;
      }

      return _bannerCard(bannerColor, bannerIcon, message);
    }

    // Fallback to static zone status while AI is loading/unavailable
    if (zoneProvider.zones.isEmpty) return const SizedBox.shrink();

    final zoneStatus =
        zoneProvider.getZoneStatus(latitude: latitude, longitude: longitude);

    Color bannerColor = AppConstants.primaryColor;
    IconData bannerIcon = Icons.info;
    if (zoneStatus.isInHighIntensityZone) {
      bannerColor = AppConstants.dangerColor;
      bannerIcon = Icons.warning;
    } else if (zoneStatus.isInMediumRiskZone) {
      bannerColor = AppConstants.mediumRiskColor;
      bannerIcon = Icons.warning_amber;
    } else if (zoneStatus.isInSafeZone || zoneStatus.isInSafeCamp) {
      bannerColor = AppConstants.safeColor;
      bannerIcon = Icons.verified_user;
    } else if (zoneStatus.isNearDangerZone) {
      bannerColor = AppConstants.warningColor;
      bannerIcon = Icons.warning_amber;
    }

    return _bannerCard(bannerColor, bannerIcon, zoneStatus.statusMessage);
  }

  Widget _bannerCard(Color color, IconData icon, String message) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Card(
        color: color,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(LocationProvider locationProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off,
                size: 64, color: AppConstants.dangerColor),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              locationProvider.errorMessage ?? 'Location error',
              style: AppConstants.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: () => locationProvider.requestPermission(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(bool hasAiCircle) {
    return Card(
      margin: const EdgeInsets.only(top: 45),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Legend',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            _buildLegendItem(Colors.blue, 'Your Location'),
            if (hasAiCircle) ...[
              const SizedBox(height: 4),
              _buildLegendItem(AppConstants.dangerColor, 'High Risk (AI)'),
              const SizedBox(height: 4),
              _buildLegendItem(AppConstants.warningColor, 'Medium Risk (AI)'),
              const SizedBox(height: 4),
              _buildLegendItem(AppConstants.safeColor, 'Safe Area (AI)'),
            ],
            const SizedBox(height: 4),
            _buildLegendItem(AppConstants.mediumRiskColor, 'Orange Zone'),
            const SizedBox(height: 4),
            _buildLegendItem(AppConstants.safeColor, 'Safe Camp'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecenterButton(LatLng currentLatLng) {
    return FloatingActionButton(
      onPressed: () => _mapController.move(currentLatLng, AppConstants.defaultZoom),
      backgroundColor: AppConstants.primaryColor,
      child: const Icon(Icons.my_location, color: Colors.white),
    );
  }

  List<CircleMarker> _buildCircleLayers(
      List<app_zone.Zone> zones, AssessmentResult? result) {
    // Suppress mock circles when:
    // - AI result is available (real circle is shown instead), OR
    // - AI is still loading (avoid flashing wrong data)
    if (result != null) return [];

    List<CircleMarker> circles = [];

    final orangeZones = zones
        .where((z) =>
            z.type == app_zone.ZoneType.danger &&
            z.intensity == app_zone.ZoneIntensity.medium)
        .toList();

    final redZones = zones
        .where((z) =>
            z.type == app_zone.ZoneType.danger &&
            z.intensity == app_zone.ZoneIntensity.high)
        .toList();

    final safeZones =
        zones.where((z) => z.type == app_zone.ZoneType.safe).toList();

    for (final zone in orangeZones) {
      if (zone.radiusInMeters > 0) {
        circles.add(CircleMarker(
          point: LatLng(zone.latitude, zone.longitude),
          radius: zone.radiusInMeters,
          useRadiusInMeter: true,
          color: AppConstants.mediumRiskColor.withOpacity(0.4),
          borderColor: AppConstants.mediumRiskColor,
          borderStrokeWidth: 2,
        ));
      }
    }

    for (final zone in redZones) {
      if (zone.radiusInMeters > 0) {
        circles.add(CircleMarker(
          point: LatLng(zone.latitude, zone.longitude),
          radius: zone.radiusInMeters,
          useRadiusInMeter: true,
          color: AppConstants.dangerColor.withOpacity(0.45),
          borderColor: AppConstants.dangerColor,
          borderStrokeWidth: 3,
        ));
      }
    }

    for (final zone in safeZones) {
      if (zone.radiusInMeters > 0) {
        circles.add(CircleMarker(
          point: LatLng(zone.latitude, zone.longitude),
          radius: zone.radiusInMeters,
          useRadiusInMeter: true,
          color: AppConstants.safeColor.withOpacity(0.2),
          borderColor: AppConstants.safeColor,
          borderStrokeWidth: 2,
        ));
      }
    }

    return circles;
  }

  List<Marker> _buildMarkers(
      LatLng currentLatLng,
      List<app_zone.Zone> zones,
      AssessmentResult? result,
      bool isLoading) {
    List<Marker> markers = [];

    markers.add(Marker(
      point: currentLatLng,
      width: 40,
      height: 40,
      child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
    ));

    for (final zone in zones) {
      // While AI is loading OR result is available, suppress mock zone markers
      // to avoid showing wrong data. Show zone markers only if no AI data yet.
      if (isLoading || result != null) {
        final isLow = result?.overallRisk.toLowerCase() == 'low';
        // For low risk: hide everything
        if (isLow || result == null) continue;
        // For medium/high: hide only danger markers, keep safe camps
        if (zone.type == app_zone.ZoneType.danger) continue;
      }

      Color markerColor;
      IconData markerIcon;

      if (zone.type == app_zone.ZoneType.safeCamp) {
        markerColor = AppConstants.safeColor;
        markerIcon = Icons.home;
      } else if (zone.type == app_zone.ZoneType.danger) {
        if (zone.intensity == app_zone.ZoneIntensity.high) {
          markerColor = AppConstants.dangerColor;
          markerIcon = Icons.warning;
        } else {
          markerColor = AppConstants.mediumRiskColor;
          markerIcon = Icons.warning_amber;
        }
      } else {
        markerColor = AppConstants.safeColor;
        markerIcon = Icons.verified_user;
      }

      markers.add(Marker(
        point: LatLng(zone.latitude, zone.longitude),
        width: 40,
        height: 40,
        child: Icon(markerIcon, color: markerColor, size: 40),
      ));
    }

    return markers;
  }
}
