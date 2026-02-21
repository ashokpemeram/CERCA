# CERCA - Safety & Emergency Assistance App

A cross-platform mobile application built with Flutter focused on user safety, real-time location tracking, emergency assistance, and resource requests.

## Features

### 🗺️ Map Tab
- Real-time location tracking
- Google Maps integration
- Danger zones (red markers)
- Safe zones (green markers)
- Zone status banner
- Legend and recenter button

### ⚠️ Precautions Tab
- Dynamic safety precautions based on location
- Zone-specific advice
- General safety tips
- Color-coded by zone type

### 🚨 SOS Tab
- Large, animated emergency button
- Confirmation dialog
- Sends location to emergency services
- Visual feedback

### 📞 Contacts Tab
- Emergency contact numbers
- Direct dial functionality
- Police, Ambulance, Fire, Disaster Helpline, Women Helpline

### 📝 Request Aid Tab
- Resource request form
- Multiple resource types (Food, Water, Shelter, Medical Aid, etc.)
- Auto-filled location
- Form validation
- Success/failure feedback

### 👤 Admin Portal
- Admin login
- Dashboard with placeholder features
- User management (coming soon)
- SOS alerts monitoring (coming soon)
- Zone management (coming soon)

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Permissions**: Permission Handler
- **Phone Dialing**: URL Launcher
- **Animations**: Flutter Animate
- **HTTP**: http package

## Project Structure

```
lib/
├── models/              # Data models
│   ├── emergency_contact.dart
│   ├── aid_request.dart
│   ├── zone.dart
│   └── precaution.dart
├── services/            # Business logic services
│   ├── location_service.dart
│   ├── api_service.dart
│   └── zone_service.dart
├── providers/           # State management
│   ├── location_provider.dart
│   ├── navigation_provider.dart
│   └── zone_provider.dart
├── screens/             # UI screens
│   ├── main_screen.dart
│   ├── tabs/
│   │   ├── map_tab.dart
│   │   ├── precautions_tab.dart
│   │   ├── sos_tab.dart
│   │   ├── contacts_tab.dart
│   │   └── request_aid_tab.dart
│   └── admin/
│       ├── admin_login.dart
│       └── admin_dashboard.dart
├── widgets/             # Reusable widgets
│   ├── custom_app_bar.dart
│   ├── contact_card.dart
│   ├── precaution_card.dart
│   ├── sos_button.dart
│   └── loading_indicator.dart
├── utils/               # Utilities
│   ├── constants.dart
│   └── helpers.dart
└── main.dart            # App entry point
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter (latest stable version)
   ```bash
   flutter --version
   ```

2. **Google Maps API Key**: 
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing
   - Enable "Maps SDK for Android" and "Maps SDK for iOS"
   - Create API credentials (API Key)

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd CERCA-APP
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API Key**

   **For Android:**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

   **For iOS:**
   - Open `ios/Runner/Info.plist`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key
   - Also add the API key to `ios/Runner/AppDelegate.swift`:
     ```swift
     import GoogleMaps
     
     GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
     ```

4. **Run the app**

   **For Android:**
   ```bash
   flutter run
   ```

   **For iOS:**
   ```bash
   cd ios
   pod install
   cd ..
   flutter run
   ```

## Permissions

### Android
- `ACCESS_FINE_LOCATION` - Precise location access
- `ACCESS_COARSE_LOCATION` - Approximate location access
- `INTERNET` - Network access
- `CALL_PHONE` - Direct phone dialing

### iOS
- `NSLocationWhenInUseUsageDescription` - Location while using app
- `NSLocationAlwaysUsageDescription` - Background location access
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Combined location access

## API Integration

The app currently uses **mock APIs** for:
- SOS alerts
- Aid requests
- Zone data

To integrate with a real backend:

1. Update `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'https://your-api.com';
   ```

2. Modify `lib/services/api_service.dart`:
   - Uncomment the actual HTTP implementation
   - Remove mock delays and responses

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Testing

### Run tests
```bash
flutter test
```

### Run on device
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Customization

### Colors
Edit `lib/utils/constants.dart` to change app colors:
```dart
static const Color primaryColor = Color(0xFF1976D2);
static const Color dangerColor = Color(0xFFD32F2F);
static const Color safeColor = Color(0xFF388E3C);
```

### Emergency Contacts
Edit `lib/screens/tabs/contacts_tab.dart` to modify emergency numbers.

### Resource Types
Edit `lib/utils/constants.dart` to add/remove resource types:
```dart
static const List<String> resourceTypes = [
  'Food',
  'Water',
  'Shelter',
  // Add more...
];
```

## Known Issues

1. **Google Maps API Key**: You must add your own API key for maps to work
2. **Mock APIs**: Backend integration required for production use
3. **Admin Authentication**: Currently accepts any credentials (demo only)

## Future Enhancements

- [ ] Real-time chat with emergency services
- [ ] Offline map caching
- [ ] Push notifications for alerts
- [ ] User profile management
- [ ] Historical SOS tracking
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Geofencing alerts

## License

This project is created for educational and demonstration purposes.

## Support

For issues or questions, please contact the development team.

---

**Built with ❤️ using Flutter**
