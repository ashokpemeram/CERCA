import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/zone_provider.dart';
import '../../../utils/constants.dart';
import '../../../models/admin/safe_camp.dart';
import '../../../widgets/admin/info_card.dart';
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
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withBlue(150),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INCIDENT MAP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Real-time hazard zones & resources',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddCampDialog(context, adminProvider),
                          icon: const Icon(Icons.add_location, size: 16),
                          label: const Text(
                            'ADD CAMP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Map
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  FlutterMap(
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
                  // Map Legend
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'MAP LEGEND',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _buildLegendItem('High Hazard', AppConstants.dangerColor),
                              _buildLegendItem('Moderate', AppConstants.mediumRiskColor),
                              _buildLegendItem('Safe Camp', AppConstants.safeColor),
                              _buildLegendItem('Control Center', Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield,
                            color: AppConstants.safeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REGISTERED SAFE CAMPS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: adminProvider.safeCamps.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No safe camps registered',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              itemCount: adminProvider.safeCamps.length,
                              itemBuilder: (context, index) {
                                final camp = adminProvider.safeCamps[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InfoCard(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: AppConstants.safeColor,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppConstants.safeColor,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        camp.id,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppConstants.safeColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        camp.statusText.toUpperCase(),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10,
                                                          color: AppConstants.safeColor,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  camp.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      camp.coordinates,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontFamily: 'monospace',
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.people,
                                                      size: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Capacity: ${camp.capacityInfo}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
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
                                            tooltip: 'Delete camp',
                                          ),
                                        ],
                                      ),
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

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppConstants.safeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.safeColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add zone markers ONLY for danger and safe zones
    for (final zone in zones) {
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
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final capacityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.safeColor,
                      AppConstants.safeColor.withGreen(180),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADD SAFE CAMP LOCATION',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Location will sync to all citizen dashboards',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Form content
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Camp Name
                        Text(
                          'CAMP NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Central Community Shelter',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppConstants.safeColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter camp name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Latitude & Longitude
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LATITUDE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: latController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '13.1950',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontFamily: 'monospace',
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppConstants.safeColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                    style: const TextStyle(fontFamily: 'monospace'),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LONGITUDE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: lngController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '79.8750',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontFamily: 'monospace',
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppConstants.safeColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                    style: const TextStyle(fontFamily: 'monospace'),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Capacity
                        Text(
                          'CAPACITY (PEOPLE)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '500',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppConstants.safeColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter capacity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Info note
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: Colors.blue[600]!,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue[800],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This location will immediately appear on all citizen mobile dashboards as a safe evacuation point.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final name = nameController.text.trim();
                            final lat = double.parse(latController.text.trim());
                            final lng = double.parse(lngController.text.trim());
                            final capacity = int.parse(capacityController.text.trim());

                            // Generate unique ID
                            final id = 'SC-${(adminProvider.safeCamps.length + 1).toString().padLeft(3, '0')}';

                            final camp = SafeCamp(
                              id: id,
                              name: name,
                              status: CampStatus.active,
                              latitude: lat,
                              longitude: lng,
                              capacity: capacity,
                              currentOccupancy: 0,
                            );

                            adminProvider.addSafeCamp(camp);
                            Navigator.pop(context);

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Safe camp added successfully! Location will sync to all citizen dashboards.',
                                ),
                                backgroundColor: AppConstants.safeColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.safeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'ADD SAFE CAMP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppConstants.dangerColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Safe Camp',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this safe camp? This action cannot be undone and will remove the location from all citizen dashboards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              adminProvider.deleteSafeCamp(campId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Safe camp removed. Citizen dashboards updated.',
                  ),
                  backgroundColor: AppConstants.dangerColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.dangerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}