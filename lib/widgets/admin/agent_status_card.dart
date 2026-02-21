import 'package:flutter/material.dart';
import '../../models/admin/agent_status.dart';
import '../../utils/constants.dart';
import 'info_card.dart';

/// Agent status display card with colored dot indicator
class AgentStatusCard extends StatelessWidget {
  final String agentName;
  final AgentStatusType status;

  const AgentStatusCard({
    super.key,
    required this.agentName,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case AgentStatusType.online:
        return AppConstants.safeColor;
      case AgentStatusType.offline:
        return AppConstants.dangerColor;
      case AgentStatusType.standby:
        return AppConstants.warningColor;
    }
  }

  String get _statusText {
    switch (status) {
      case AgentStatusType.online:
        return 'Online';
      case AgentStatusType.offline:
        return 'Offline';
      case AgentStatusType.standby:
        return 'Standby';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agentName,
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusText,
                  style: AppConstants.captionStyle.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
