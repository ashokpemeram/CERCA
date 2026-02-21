import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/admin/info_card.dart';
import '../../../widgets/admin/status_chip.dart';
import '../../../models/admin/aid_request_admin.dart';

/// Aid requests tab for admin dashboard
class AidTab extends StatelessWidget {
  const AidTab({super.key});

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
              color: AppConstants.warningColor,
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Priority Note: Non-emergency resource allocation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Aid Request List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                itemCount: adminProvider.aidRequests.length,
                itemBuilder: (context, index) {
                  final aid = adminProvider.aidRequests[index];
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
                                aid.id,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _getPriorityChip(aid.priority),
                              const SizedBox(width: 8),
                              aid.status == AidStatus.pending
                                  ? StatusChip.warning('Pending')
                                  : StatusChip.success('Dispatched'),
                              const Spacer(),
                              Text(
                                DateFormat('HH:mm').format(aid.timestamp),
                                style: AppConstants.captionStyle,
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Request Details
                          _buildDetailRow(
                            Icons.person,
                            'Requester',
                            aid.requesterName,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.inventory,
                            'Resources',
                            aid.resourcesText,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.people,
                            'People',
                            '${aid.peopleCount} persons',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.location_on,
                            'Location',
                            aid.location,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.my_location,
                            'Coordinates',
                            aid.coordinates,
                          ),

                          // Action Button or Status
                          const SizedBox(height: 16),
                          if (aid.status == AidStatus.pending)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    adminProvider.dispatchAid(aid.id),
                                icon: const Icon(Icons.send),
                                label: const Text('DISPATCH AID'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.primaryColor,
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
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppConstants.safeColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Aid dispatched successfully',
                                    style: TextStyle(
                                      color: AppConstants.safeColor,
                                      fontWeight: FontWeight.bold,
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getPriorityChip(AidPriority priority) {
    switch (priority) {
      case AidPriority.high:
        return StatusChip.danger('High Priority');
      case AidPriority.medium:
        return StatusChip.warning('Medium Priority');
      case AidPriority.low:
        return StatusChip.info('Low Priority');
    }
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
