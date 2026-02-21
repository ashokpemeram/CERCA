import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/status_chip.dart';
import '../../../models/admin/sos_request.dart';

/// SOS tab for admin dashboard
class SosTab extends StatelessWidget {
  const SosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Priority Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              color: AppConstants.dangerColor,
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Priority-1: Critical Distress Calls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // SOS Request List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                itemCount: adminProvider.sosRequests.length,
                itemBuilder: (context, index) {
                  final sos = adminProvider.sosRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Text(
                                sos.id,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              sos.status == SosStatus.pending
                                  ? StatusChip.warning('Pending')
                                  : StatusChip.success('Dispatched'),
                              const Spacer(),
                              Text(
                                DateFormat('HH:mm').format(sos.timestamp),
                                style: AppConstants.captionStyle,
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Caller Details
                          _buildDetailRow(
                            Icons.person,
                            'Caller',
                            sos.callerName,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.phone,
                            'Phone',
                            sos.phoneNumber,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.location_on,
                            'Address',
                            sos.address,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.my_location,
                            'Location',
                            sos.coordinates,
                          ),

                          // Action Button or Status
                          const SizedBox(height: 16),
                          if (sos.status == SosStatus.pending)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    adminProvider.dispatchRescueTeam(sos.id),
                                icon: const Icon(Icons.local_shipping),
                                label: const Text('DISPATCH RESCUE TEAM'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.dangerColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppConstants.safeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppConstants.safeColor,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Rescue team en-route',
                                        style: TextStyle(
                                          color: AppConstants.safeColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (sos.eta != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'ETA: ${sos.eta}',
                                      style: AppConstants.captionStyle,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppConstants.captionStyle.copyWith(fontSize: 12),
              ),
              Text(
                value,
                style: AppConstants.bodyStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
