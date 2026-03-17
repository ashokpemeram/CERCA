import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../services/api_service.dart';
import '../../models/admin/sos_request.dart';
import '../../widgets/sos_button.dart';
import '../../utils/constants.dart';

/// SOS tab with emergency button
class SosTab extends StatefulWidget {
  const SosTab({super.key});

  @override
  State<SosTab> createState() => _SosTabState();
}

class _SosTabState extends State<SosTab> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.sosButtonColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SOS Button
                SosButton(
                  onPressed: () => _handleSosPress(locationProvider),
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                // Instructions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Emergency SOS',
                        style: AppConstants.headingStyle.copyWith(
                          color: AppConstants.sosButtonColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Press the button to send an emergency alert with your location to emergency contacts and services.',
                        style: AppConstants.bodyStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppConstants.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusMedium,
                          ),
                          border: Border.all(
                            color: AppConstants.warningColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: AppConstants.warningColor,
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Expanded(
                              child: Text(
                                'Use only in real emergencies',
                                style: AppConstants.bodyStyle.copyWith(
                                  color: AppConstants.warningColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSosPress(LocationProvider locationProvider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppConstants.dangerColor),
            SizedBox(width: 8),
            Text('Confirm SOS Alert'),
          ],
        ),
        content: const Text(
          'Are you sure you want to send an emergency SOS alert? This will notify emergency contacts and services with your current location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.dangerColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final position = locationProvider.currentPosition;

      if (position == null) {
        throw Exception('Location not available');
      }

      final sosRequest = SosRequest(
        id: 'SOS-${DateTime.now().millisecondsSinceEpoch}',
        status: SosStatus.pending,
        callerName: 'Citizen',
        phoneNumber: 'N/A',
        address: 'GPS location',
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        source: 'citizen',
      );

      final response = await _apiService.submitSosRequest(sosRequest);

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response.success) {
        final assigned = response.data;
        final assignedAreaId = assigned?.areaId ?? 'UNASSIGNED';
        final inside = assigned?.insideControllableZone ?? false;
        final areaMessage = assignedAreaId == 'UNASSIGNED'
            ? 'No active area found for this location.'
            : 'Assigned Area: $assignedAreaId'
                '${inside ? '' : ' (outside controllable boundary)'}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(areaMessage),
            backgroundColor: AppConstants.primaryColor,
          ),
        );

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppConstants.safeColor),
                SizedBox(width: 8),
                Text('SOS Sent'),
              ],
            ),
            content: Text(
              'Your emergency alert has been sent successfully. Help is on the way.\n\n$areaMessage',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: AppConstants.dangerColor),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text('Failed to send SOS alert: $e'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
