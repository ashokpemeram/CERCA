import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/zone_provider.dart';
import '../../models/zone.dart' as app_zone;
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

/// Map tab showing user location and zones using OpenStreetMap
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, ZoneProvider>(
      builder: (context, locationProvider, zoneProvider, child) {
        if (locationProvider.isLoading) {
          return const LoadingIndicator(message: 'Getting your location...');
        }

        if (locationProvider.errorMessage != null) {
          return _buildErrorView(locationProvider);
        }

        if (locationProvider.currentPosition == null) {
          return const Center(
            child: Text('Unable to get location'),
          );
        }

        final position = locationProvider.currentPosition!;
        final currentLatLng = LatLng(position.latitude, position.longitude);

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
                // Map Tiles - Using OpenStreetMap (colored map)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cerca.app',
                ),
                
                // Zone Circles
                CircleLayer(
                  circles: _buildCircleLayers(zoneProvider.zones),
                ),
                
                // Markers (User location, zones, safe camps)
                MarkerLayer(
                  markers: _buildMarkers(currentLatLng, zoneProvider.zones),
                ),
              ],
            ),
            
            // Legend
            Positioned(
              top: 16,
              right: 16,
              child: _buildLegend(),
            ),
            
            // Recenter button
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildRecenterButton(currentLatLng),
            ),
            
            // Zone status banner
            if (zoneProvider.zones.isNotEmpty)
              Positioned(
                top: 16,
                left: 16,
                right: 100,
                child: _buildZoneStatusBanner(
                  position.latitude,
                  position.longitude,
                  zoneProvider,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildErrorView(LocationProvider locationProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: AppConstants.dangerColor,
            ),
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

  Widget _buildLegend() {
    return Card(
      margin: const EdgeInsets.only(top: 45),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Legend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(Colors.blue, 'Your Location'),
            const SizedBox(height: 4),
            _buildLegendItem(AppConstants.dangerColor, 'Red Zone (High)'),
            const SizedBox(height: 4),
            _buildLegendItem(AppConstants.mediumRiskColor, 'Orange Zone (Medium)'),
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
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecenterButton(LatLng currentLatLng) {
    return FloatingActionButton(
      onPressed: () {
        _mapController.move(currentLatLng, AppConstants.defaultZoom);
      },
      backgroundColor: AppConstants.primaryColor,
      child: const Icon(Icons.my_location, color: Colors.white),
    );
  }

  Widget _buildZoneStatusBanner(
    double latitude,
    double longitude,
    ZoneProvider zoneProvider,
  ) {
    final zoneStatus = zoneProvider.getZoneStatus(
      latitude: latitude,
      longitude: longitude,
    );

    Color bannerColor = AppConstants.primaryColor;
    IconData bannerIcon = Icons.info;

    if (zoneStatus.isInHighIntensityZone) {
      bannerColor = AppConstants.dangerColor;
      bannerIcon = Icons.warning;
    } else if (zoneStatus.isInMediumRiskZone) {
      bannerColor = AppConstants.mediumRiskColor;
      bannerIcon = Icons.warning_amber;
    } else if (zoneStatus.isInSafeCamp) {
      bannerColor = AppConstants.safeColor;
      bannerIcon = Icons.verified_user;
    } else if (zoneStatus.isInSafeZone) {
      bannerColor = AppConstants.safeColor;
      bannerIcon = Icons.verified_user;
    } else if (zoneStatus.isNearDangerZone) {
      bannerColor = AppConstants.warningColor;
      bannerIcon = Icons.warning_amber;
    }

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 350,
      ),
      child: Card(
        color: bannerColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(bannerIcon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  zoneStatus.statusMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<CircleMarker> _buildCircleLayers(List<app_zone.Zone> zones) {
    List<CircleMarker> circles = [];

    // Separate zones by type for proper layering
    final orangeZones = zones.where((z) =>
      z.type == app_zone.ZoneType.danger &&
      z.intensity == app_zone.ZoneIntensity.medium
    ).toList();

    final redZones = zones.where((z) =>
      z.type == app_zone.ZoneType.danger &&
      z.intensity == app_zone.ZoneIntensity.high
    ).toList();

    final safeZones = zones.where((z) => z.type == app_zone.ZoneType.safe).toList();

    // Add orange zones first (bottom layer)
    for (final zone in orangeZones) {
      if (zone.radiusInMeters > 0) {
        circles.add(
          CircleMarker(
            point: LatLng(zone.latitude, zone.longitude),
            radius: zone.radiusInMeters,
            useRadiusInMeter: true,
            color: AppConstants.mediumRiskColor.withOpacity(0.4),
            borderColor: AppConstants.mediumRiskColor,
            borderStrokeWidth: 2,
          ),
        );
      }
    }

    // Add red zones (top layer)
    for (final zone in redZones) {
      if (zone.radiusInMeters > 0) {
        circles.add(
          CircleMarker(
            point: LatLng(zone.latitude, zone.longitude),
            radius: zone.radiusInMeters,
            useRadiusInMeter: true,
            color: AppConstants.dangerColor.withOpacity(0.45),
            borderColor: AppConstants.dangerColor,
            borderStrokeWidth: 3,
          ),
        );
      }
    }

    // Add safe zones
    for (final zone in safeZones) {
      if (zone.radiusInMeters > 0) {
        circles.add(
          CircleMarker(
            point: LatLng(zone.latitude, zone.longitude),
            radius: zone.radiusInMeters,
            useRadiusInMeter: true,
            color: AppConstants.safeColor.withOpacity(0.2),
            borderColor: AppConstants.safeColor,
            borderStrokeWidth: 2,
          ),
        );
      }
    }

    return circles;
  }

  List<Marker> _buildMarkers(LatLng currentLatLng, List<app_zone.Zone> zones) {
    List<Marker> markers = [];

    // User location marker
    markers.add(
      Marker(
        point: currentLatLng,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );

    // Zone markers
    for (final zone in zones) {
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

      markers.add(
        Marker(
          point: LatLng(zone.latitude, zone.longitude),
          width: 40,
          height: 40,
          child: Icon(
            markerIcon,
            color: markerColor,
            size: 40,
          ),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
