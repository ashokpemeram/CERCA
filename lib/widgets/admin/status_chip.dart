import 'package:flutter/material.dart';

/// Reusable status chip widget with color-coded backgrounds
class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.icon,
  });

  /// Factory for success/active status
  factory StatusChip.success(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      backgroundColor: Colors.green,
      icon: icon,
    );
  }

  /// Factory for danger/error status
  factory StatusChip.danger(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      backgroundColor: Colors.red,
      icon: icon,
    );
  }

  /// Factory for warning status
  factory StatusChip.warning(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      backgroundColor: Colors.orange,
      icon: icon,
    );
  }

  /// Factory for info/primary status
  factory StatusChip.info(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      backgroundColor: Colors.blue,
      icon: icon,
    );
  }

  /// Factory for pending/neutral status
  factory StatusChip.pending(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      backgroundColor: Colors.grey,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
