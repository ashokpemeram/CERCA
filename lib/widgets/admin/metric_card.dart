import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'info_card.dart';

/// Reusable metric display card with large value and trend indicator
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? statusText;
  final IconData? trendIcon;
  final Color? trendColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.statusText,
    this.trendIcon,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppConstants.bodyStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          if (statusText != null || trendIcon != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (trendIcon != null) ...[
                  Icon(
                    trendIcon,
                    size: 16,
                    color: trendColor ?? Colors.grey,
                  ),
                  const SizedBox(width: 4),
                ],
                if (statusText != null)
                  Text(
                    statusText!,
                    style: AppConstants.captionStyle.copyWith(
                      color: trendColor ?? AppConstants.captionStyle.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
