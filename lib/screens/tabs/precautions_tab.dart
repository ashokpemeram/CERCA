import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/zone_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

/// Precautions tab with disaster-specific and general precautions
class PrecautionsTab extends StatefulWidget {
  const PrecautionsTab({super.key});

  @override
  State<PrecautionsTab> createState() => _PrecautionsTabState();
}

class _PrecautionsTabState extends State<PrecautionsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Card
        Container(
          color: AppConstants.primaryColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.white, size: 28),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Safety Precautions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stay safe with these guidelines',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: 'Disaster Specific'),
                    Tab(text: 'General'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDisasterSpecificTab(),
              _buildGeneralTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisasterSpecificTab() {
    return Consumer2<ZoneProvider, LocationProvider>(
      builder: (context, zoneProvider, locationProvider, child) {
        if (zoneProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading precautions...');
        }

        if (zoneProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppConstants.dangerColor),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    zoneProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppConstants.bodyStyle,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton(
                    onPressed: () => zoneProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final position = locationProvider.currentPosition;
        if (position == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Text(
                'Location not available. Please enable location services.',
                textAlign: TextAlign.center,
                style: AppConstants.bodyStyle,
              ),
            ),
          );
        }

        final precautions = zoneProvider.getPrecautionsForLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        // Filter for disaster-specific (danger zone) precautions
        final disasterPrecautions = precautions
            .where((p) => p.applicableZone != null)
            .toList();

        if (disasterPrecautions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppConstants.safeColor,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  const Text(
                    'No disaster-specific precautions for your current location',
                    textAlign: TextAlign.center,
                    style: AppConstants.subheadingStyle,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'You are in a safe area. Check general precautions for everyday safety tips.',
                    textAlign: TextAlign.center,
                    style: AppConstants.bodyStyle,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: disasterPrecautions.length,
          itemBuilder: (context, index) {
            final precaution = disasterPrecautions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.dangerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    precaution.icon,
                    color: AppConstants.dangerColor,
                    size: 28,
                  ),
                ),
                title: Text(
                  precaution.title,
                  style: AppConstants.subheadingStyle.copyWith(fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    precaution.description,
                    style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGeneralTab() {
    return Consumer2<ZoneProvider, LocationProvider>(
      builder: (context, zoneProvider, locationProvider, child) {
        if (zoneProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading precautions...');
        }

        if (zoneProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppConstants.dangerColor),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    zoneProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppConstants.bodyStyle,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton(
                    onPressed: () => zoneProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final position = locationProvider.currentPosition;
        if (position == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Text(
                'Location not available. Please enable location services.',
                textAlign: TextAlign.center,
                style: AppConstants.bodyStyle,
              ),
            ),
          );
        }

        final precautions = zoneProvider.getPrecautionsForLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        // Filter for general precautions (no specific zone)
        final generalPrecautions = precautions
            .where((p) => p.applicableZone == null)
            .toList();

        if (generalPrecautions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium),
              child: Text(
                'No general precautions available',
                textAlign: TextAlign.center,
                style: AppConstants.bodyStyle,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: generalPrecautions.length,
          itemBuilder: (context, index) {
            final precaution = generalPrecautions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    precaution.icon,
                    color: AppConstants.primaryColor,
                    size: 28,
                  ),
                ),
                title: Text(
                  precaution.title,
                  style: AppConstants.subheadingStyle.copyWith(fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    precaution.description,
                    style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
