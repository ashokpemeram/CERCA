import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import '../../models/admin/communication_log.dart';
import 'tabs/overview_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/sos_tab.dart';
import 'tabs/aid_tab.dart';
import 'tabs/history_tab.dart';

/// Admin dashboard with 5 tabs
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _tabs = const [
    OverviewTab(),
    MapTab(),
    SosTab(),
    AidTab(),
    HistoryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Logout',
                ),
              ],
            ),
            body: PageStorage(
              bucket: _bucket,
              child: IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppConstants.primaryColor,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Overview',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sos),
                  label: 'SOS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.help_outline),
                  label: 'Aid',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
              ],
            ),
            floatingActionButton: _currentIndex == 0
                ? FloatingActionButton(
                    onPressed: () => _showCommunicationLog(context, adminProvider),
                    backgroundColor: AppConstants.primaryColor,
                    child: const Icon(Icons.message, color: Colors.white),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _showCommunicationLog(BuildContext context, AdminProvider adminProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.message,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COMMUNICATION LOG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real-time message dispatch history',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Log List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: adminProvider.communicationLogs.length,
                    itemBuilder: (context, index) {
                      final log = adminProvider.communicationLogs[index];
                      return _buildLogItem(log);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(CommunicationLog log) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (log.type) {
      case CommunicationLogType.sms:
        icon = Icons.message;
        iconColor = AppConstants.primaryColor;
        iconBgColor = AppConstants.primaryColor.withOpacity(0.1);
        break;
      case CommunicationLogType.alert:
        icon = Icons.error;
        iconColor = AppConstants.dangerColor;
        iconBgColor = AppConstants.dangerColor.withOpacity(0.1);
        break;
      case CommunicationLogType.evacuation:
        icon = Icons.message;
        iconColor = AppConstants.primaryColor;
        iconBgColor = AppConstants.primaryColor.withOpacity(0.1);
        break;
      case CommunicationLogType.resource:
        icon = Icons.check_circle;
        iconColor = AppConstants.safeColor;
        iconBgColor = AppConstants.safeColor.withOpacity(0.1);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.formattedTime,
                  style: AppConstants.captionStyle.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  log.message,
                  style: AppConstants.bodyStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
