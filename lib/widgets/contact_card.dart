import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Reusable contact card widget
class ContactCard extends StatelessWidget {
  final EmergencyContact contact;

  const ContactCard({
    super.key,
    required this.contact,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Icon(
            contact.icon,
            color: AppConstants.primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          contact.name,
          style: AppConstants.subheadingStyle.copyWith(fontSize: 16),
        ),
        subtitle: Text(
          Helpers.formatPhoneNumber(contact.phoneNumber),
          style: AppConstants.bodyStyle.copyWith(fontSize: 14),
        ),
        trailing: IconButton(
          onPressed: () => _makePhoneCall(contact.phoneNumber),
          icon: const Icon(
            Icons.phone,
            color: AppConstants.safeColor,
            size: 28,
          ),
          tooltip: 'Call ${contact.name}',
        ),
      ),
    );
  }

  /// Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint('Could not launch $launchUri');
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
    }
  }
}
