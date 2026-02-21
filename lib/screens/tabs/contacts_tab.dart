import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/emergency_contact.dart';
import '../../utils/constants.dart';

/// Contacts tab with disaster-specific and general emergency contacts
class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Disaster-specific emergency contacts
  final List<EmergencyContact> _disasterContacts = [
    EmergencyContact(
      id: 'd1',
      name: 'National Disaster Helpline',
      phoneNumber: AppConstants.disasterHelpline,
      icon: Icons.warning_amber,
      category: 'Disaster',
    ),
    EmergencyContact(
      id: 'd2',
      name: 'Fire Department',
      phoneNumber: AppConstants.fireNumber,
      icon: Icons.local_fire_department,
      category: 'Disaster',
    ),
    EmergencyContact(
      id: 'd3',
      name: 'Ambulance',
      phoneNumber: AppConstants.ambulanceNumber,
      icon: Icons.local_hospital,
      category: 'Disaster',
    ),
    EmergencyContact(
      id: 'd4',
      name: 'Rescue Services',
      phoneNumber: '108',
      icon: Icons.sos,
      category: 'Disaster',
    ),
    EmergencyContact(
      id: 'd5',
      name: 'Earthquake Helpline',
      phoneNumber: '1092',
      icon: Icons.landscape,
      category: 'Disaster',
    ),
    EmergencyContact(
      id: 'd6',
      name: 'Flood Control',
      phoneNumber: '1070',
      icon: Icons.water,
      category: 'Disaster',
    ),
  ];

  // General emergency contacts
  final List<EmergencyContact> _generalContacts = [
    EmergencyContact(
      id: 'g1',
      name: 'Police',
      phoneNumber: AppConstants.policeNumber,
      icon: Icons.local_police,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g2',
      name: 'Ambulance',
      phoneNumber: AppConstants.ambulanceNumber,
      icon: Icons.local_hospital,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g3',
      name: 'Women Helpline',
      phoneNumber: AppConstants.womenHelpline,
      icon: Icons.woman,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g4',
      name: 'Child Helpline',
      phoneNumber: '1098',
      icon: Icons.child_care,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g5',
      name: 'Senior Citizen Helpline',
      phoneNumber: '14567',
      icon: Icons.elderly,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g6',
      name: 'Road Accident',
      phoneNumber: '1073',
      icon: Icons.car_crash,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g7',
      name: 'Medical Emergency',
      phoneNumber: '108',
      icon: Icons.medical_services,
      category: 'General',
    ),
    EmergencyContact(
      id: 'g8',
      name: 'Blood Bank',
      phoneNumber: '104',
      icon: Icons.bloodtype,
      category: 'General',
    ),
  ];

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
                    const Icon(Icons.contacts, color: Colors.white, size: 28),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emergency Contacts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quick access to emergency services',
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
              _buildContactsList(_disasterContacts, AppConstants.dangerColor),
              _buildContactsList(_generalContacts, AppConstants.primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsList(List<EmergencyContact> contacts, Color accentColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
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
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              ),
              child: Icon(
                contact.icon,
                color: accentColor,
                size: 28,
              ),
            ),
            title: Text(
              contact.name,
              style: AppConstants.subheadingStyle.copyWith(fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    contact.phoneNumber,
                    style: AppConstants.bodyStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.phone_in_talk,
                color: accentColor,
                size: 28,
              ),
              onPressed: () => _makePhoneCall(contact.phoneNumber),
            ),
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (!mounted) return;
        _showErrorDialog('Could not launch phone dialer');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error making phone call: $e');
    }
  }

  void _showErrorDialog(String message) {
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
        content: Text(message),
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
