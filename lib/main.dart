import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/location_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/zone_provider.dart';
import 'providers/assessment_provider.dart';
import 'screens/main_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const CercaApp());
}

class CercaApp extends StatelessWidget {
  const CercaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ZoneProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppConstants.primaryColor,
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: const CardThemeData(
            color: AppConstants.cardColor,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
            ),
          ),
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

/// Widget to initialize app services
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.initialize();

    final zoneProvider = context.read<ZoneProvider>();
    await zoneProvider.initialize(
      latitude: locationProvider.latitude,
      longitude: locationProvider.longitude,
    );

    // Start AI assessment immediately at launch using GPS location
    final lat = locationProvider.latitude;
    final lon = locationProvider.longitude;
    if (lat != null && lon != null) {
      context.read<AssessmentProvider>().assessByCoordinates(lat, lon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
