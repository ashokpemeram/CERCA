import 'package:flutter/material.dart';
import '../models/precaution.dart';
import '../utils/constants.dart';

/// Reusable precaution card widget
class PrecautionCard extends StatelessWidget {
  final Precaution precaution;

  const PrecautionCard({
    super.key,
    required this.precaution,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Icon(
                precaution.icon,
                color: _getIconColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    precaution.title,
                    style: AppConstants.subheadingStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    precaution.description,
                    style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconBackgroundColor() {
    if (precaution.applicableZone == null) {
      return AppConstants.primaryColor.withOpacity(0.1);
    }
    
    switch (precaution.applicableZone!.toString().split('.').last) {
      case 'danger':
        return AppConstants.dangerColor.withOpacity(0.1);
      case 'safe':
        return AppConstants.safeColor.withOpacity(0.1);
      default:
        return AppConstants.primaryColor.withOpacity(0.1);
    }
  }

  Color _getIconColor() {
    if (precaution.applicableZone == null) {
      return AppConstants.primaryColor;
    }
    
    switch (precaution.applicableZone!.toString().split('.').last) {
      case 'danger':
        return AppConstants.dangerColor;
      case 'safe':
        return AppConstants.safeColor;
      default:
        return AppConstants.primaryColor;
    }
  }
}
