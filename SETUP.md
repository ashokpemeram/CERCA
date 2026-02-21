# 🚀 CERCA App - Quick Start Guide

## ✅ What's Been Created

A complete Flutter safety application with:
- ✅ 25+ Dart files
- ✅ 5 functional tabs (Map, Precautions, SOS, Contacts, Request Aid)
- ✅ Admin portal
- ✅ Location tracking
- ✅ Google Maps integration
- ✅ Emergency SOS system
- ✅ Resource request system

## 📋 Prerequisites

Before running the app, ensure you have:

1. **Flutter SDK** installed (latest stable version)
   ```bash
   flutter --version
   ```

2. **Android Studio** or **Xcode** (for iOS)

3. **Google Maps API Key** (required for maps to work)

## 🔑 Getting Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key

## ⚙️ Configuration Steps

### Step 1: Add Google Maps API Key

#### For Android:
Open `android/app/src/main/AndroidManifest.xml` and replace:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

#### For iOS:
Open `ios/Runner/Info.plist` and replace:
```xml
<key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
```

### Step 2: Install Dependencies

```bash
cd d:\CERCA-APP
flutter pub get
```

### Step 3: Run the App

#### On Android:
```bash
flutter run
```

#### On iOS:
```bash
cd ios
pod install
cd ..
flutter run
```

## 📱 Testing the App

### 1. Location Permissions
- When app launches, grant location permissions
- If denied, use the retry button

### 2. Map Tab
- Should show your current location
- Mock danger zones (red) and safe zones (green) will appear
- Tap recenter button to return to your location

### 3. Precautions Tab
- Shows safety tips based on your location
- Pull down to refresh

### 4. SOS Tab
- Tap the red SOS button
- Confirm the alert
- Check success message

### 5. Contacts Tab
- Tap phone icon next to any contact
- Phone dialer should open

### 6. Request Aid Tab
- Select resource type
- Enter description
- Submit request
- Check success message

### 7. Admin Portal
- Tap "Admin" button in app bar
- Enter any email/password (demo mode)
- View dashboard

## 🔧 Customization

### Change Colors
Edit `lib/utils/constants.dart`:
```dart
static const Color primaryColor = Color(0xFF1976D2);
static const Color dangerColor = Color(0xFFD32F2F);
static const Color safeColor = Color(0xFF388E3C);
```

### Add Emergency Contacts
Edit `lib/screens/tabs/contacts_tab.dart`:
```dart
EmergencyContact(
  id: 'custom',
  name: 'Custom Contact',
  phoneNumber: '1234567890',
  icon: Icons.phone,
  category: 'Custom',
),
```

### Modify Resource Types
Edit `lib/utils/constants.dart`:
```dart
static const List<String> resourceTypes = [
  'Food',
  'Water',
  // Add more...
];
```

## 🌐 Backend Integration

Currently using mock APIs. To integrate with real backend:

1. Update base URL in `lib/utils/constants.dart`:
```dart
static const String baseUrl = 'https://your-api.com';
```

2. Update `lib/services/api_service.dart`:
   - Uncomment actual HTTP implementations
   - Remove mock delays and responses

## 🏗️ Building for Production

### Android APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle:
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS:
```bash
flutter build ios --release
```

## 📂 Project Structure

```
CERCA-APP/
├── lib/
│   ├── models/              # Data models (4 files)
│   ├── services/            # Business logic (3 files)
│   ├── providers/           # State management (3 files)
│   ├── screens/             # UI screens (8 files)
│   ├── widgets/             # Reusable widgets (5 files)
│   ├── utils/               # Utilities (2 files)
│   └── main.dart            # App entry point
├── android/                 # Android configuration
├── ios/                     # iOS configuration
├── test/                    # Tests
├── pubspec.yaml            # Dependencies
└── README.md               # Documentation
```

## 🐛 Troubleshooting

### Map not showing?
- ✅ Check if Google Maps API key is added
- ✅ Verify API is enabled in Google Cloud Console
- ✅ Check location permissions are granted

### Location not working?
- ✅ Grant location permissions
- ✅ Enable location services on device
- ✅ Check if running on physical device (emulators may have issues)

### Phone dialing not working?
- ✅ Test on physical device (emulators don't have phone capability)
- ✅ Check CALL_PHONE permission in AndroidManifest.xml

### Build errors?
```bash
flutter clean
flutter pub get
flutter run
```

## 📞 Support

For issues or questions:
1. Check the [README.md](file:///d:/CERCA-APP/README.md)
2. Review the [walkthrough.md](file:///C:/Users/Win/.gemini/antigravity/brain/222d5197-fb0a-4c8f-b490-5d15696df3be/walkthrough.md)
3. Check Flutter documentation

## 🎯 Next Steps

1. ✅ Add Google Maps API key
2. ✅ Run `flutter pub get`
3. ✅ Test on device/emulator
4. ✅ Customize colors and content
5. ✅ Integrate with backend
6. ✅ Build for production

---

**Your app is ready to run! Just add the Google Maps API key and you're good to go! 🚀**
