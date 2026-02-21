import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/constants.dart';
import 'tabs/map_tab.dart';
import 'tabs/precautions_tab.dart';
import 'tabs/sos_tab.dart';
import 'tabs/contacts_tab.dart';
import 'tabs/request_aid_tab.dart';
import 'admin/admin_login.dart';

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Keep state of each tab using PageStorage
  final PageStorageBucket _bucket = PageStorageBucket();

  // List of tabs
  final List<Widget> _tabs = [
    const MapTab(),
    const PrecautionsTab(),
    const SosTab(),
    ContactsTab(),
    const RequestAidTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            onAdminPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminLogin(),
                ),
              );
            },
          ),
          body: PageStorage(
            bucket: _bucket,
            child: IndexedStack(
              index: navigationProvider.currentIndex,
              children: _tabs,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: navigationProvider.setIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.warning_amber),
                label: 'Precautions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sos),
                label: 'SOS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts),
                label: 'Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                label: 'Request Aid',
              ),
            ],
          ),
        );
      },
    );
  }
}
