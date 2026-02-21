import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/zone_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/status_chip.dart';
import '../../../models/zone.dart' as app_zone;

/// Map tab for admin dashboard
class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminProvider, ZoneProvider>(
      builder: (context, adminProvider, zoneProvider, child) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              color: AppConstants.primaryColor,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Incident Map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCampDialog(context, adminProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('ADD CAMP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              flex: 2,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(19.0760, 72.8777),
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.cerca.app',
                  ),
                  // Zone Circles (danger and safe zones)
                  CircleLayer(
                    circles: _buildCircleLayers(zoneProvider.zones),
                  ),
                  // Markers (safe camps and zone centers)
                  MarkerLayer(
                    markers: _buildMarkers(adminProvider, zoneProvider.zones),
                  ),
                ],
              ),
            ),

            // Safe Camps List
            Expanded(
              flex: 1,
              child: Container(
                color: AppConstants.backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Text(
                        'Registered Safe Camps',
                        style: AppConstants.subheadingStyle,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                        ),
                        itemCount: adminProvider.safeCamps.length,
                        itemBuilder: (context, index) {
                          final camp = adminProvider.safeCamps[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InfoCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              camp.id,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            StatusChip.success(camp.statusText),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          camp.name,
                                          style: AppConstants.bodyStyle,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          camp.coordinates,
                                          style: AppConstants.captionStyle,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Capacity: ${camp.capacityInfo}',
                                          style: AppConstants.captionStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _confirmDelete(
                                      context,
                                      adminProvider,
                                      camp.id,
                                    ),
                                    icon: const Icon(Icons.delete),
                                    color: AppConstants.dangerColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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

  List<Marker> _buildMarkers(AdminProvider adminProvider, List<app_zone.Zone> zones) {
    final markers = <Marker>[];

    // Add safe camp markers from admin provider
    for (final camp in adminProvider.safeCamps) {
      markers.add(
        Marker(
          point: LatLng(camp.latitude, camp.longitude),
          width: 80,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppConstants.safeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  camp.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.home,
                color: AppConstants.safeColor,
                size: 32,
              ),
            ],
          ),
        ),
      );
    }

    // Add zone markers ONLY for danger and safe zones (not safeCamp type)
    // SafeCamps are already shown above from AdminProvider
    for (final zone in zones) {
      // Skip safeCamp zones as they're shown from AdminProvider
      if (zone.type == app_zone.ZoneType.safeCamp) {
        continue;
      }

      Color markerColor;
      IconData markerIcon;

      if (zone.type == app_zone.ZoneType.danger) {
        if (zone.intensity == app_zone.ZoneIntensity.high) {
          markerColor = AppConstants.dangerColor;
          markerIcon = Icons.warning;
        } else {
          markerColor = AppConstants.mediumRiskColor;
          markerIcon = Icons.warning_amber;
        }
      } else {
        // Safe zone
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

  void _showAddCampDialog(BuildContext context, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Safe Camp'),
        content: const Text(
          'This feature will allow you to add new safe camps to the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminProvider adminProvider,
    String campId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Camp'),
        content: const Text('Are you sure you want to delete this camp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              adminProvider.deleteSafeCamp(campId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.dangerColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
