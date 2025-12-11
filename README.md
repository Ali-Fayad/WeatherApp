```markdown
# WeatherApp (Flutter)

Mobile weather application built with Flutter. Shows live weather data, city search, charts, and includes authentication + local storage.  
Note: This app uses a local SQLite database (sqflite) and therefore is NOT compatible with Flutter Web builds without modifications — see "Web" section below.

---

## Contents

- Features
- Requirements
- Quick start
- Run on Android
- Run on iOS
- Run on Desktop (optional)
- Web (NOT supported by default)
- Release builds
- Troubleshooting
- Project structure
- What's implemented (mapping to assignment)
- License & contact

---

## Features

- Authentication (simple username/password stored as a hashed password in local SQLite)
- Tabbed UI with 3 main tabs: Currently, Weekly, Today
- City search with suggestions
- Charts (fl_chart) for weather data
- Favorites screen with full CRUD stored in SQLite
- Settings screen demonstrating multiple input widgets (Dropdown, Switch, Radio, Checkbox)
- Loading overlay (Stack) while calling APIs
- SnackBar & AlertDialog error handling (e.g., city not found, permission issues)

---

## Requirements

- Flutter SDK (stable) — tested with Flutter 3.x / 4.x (run `flutter --version`)
- Android SDK (for Android builds)
- Xcode (macOS, for iOS builds)
- CocoaPods (for iOS): `sudo gem install cocoapods`
- A physical iOS device or simulator to test on iOS
- Note: The app uses `sqflite` (native plugin). sqflite is not supported on web.

Key pubspec dependencies (examples):
- geolocator
- http
- flutter_dotenv
- fl_chart
- sqflite, path_provider
- crypto
- permission_handler (optional; if causing build errors, update/remove as described in Troubleshooting)

---

## Quick start

1. Clone the repo:
   ```
   git clone https://github.com/Ali-Fayad/WeatherApp.git
   cd WeatherApp
   ```

2. Install packages:
   ```
   flutter pub get
   ```

3. Run the app (choose device/emulator):

   - List devices:
     ```
     flutter devices
     ```

   - Run on default device:
     ```
     flutter run
     ```

---

## Run on Android

1. Start an Android emulator or connect a real device.
2. Ensure device is listed with `flutter devices`.
3. Run:
   ```
   flutter run -d <deviceId>
   ```
   or simply:
   ```
   flutter run
   ```

---

## Run on iOS (macOS required)

1. Open `ios/Runner.xcworkspace` in Xcode to set signing & capabilities (Team).
2. Ensure `ios/Podfile` has a suitable platform (e.g., `platform :ios, '11.0'` or higher).
3. Install pods:
   ```
   cd ios
   pod repo update
   pod install
   cd ..
   ```
4. Run from terminal:
   ```
   flutter run -d <your_ios_device_id>
   ```
   Or run from Xcode (select device and press Run).

Notes:
- Add usage descriptions in `ios/Runner/Info.plist` for permissions:
  - `NSLocationWhenInUseUsageDescription` (location)
  - Add others if needed.
- For release/TestFlight/App Store distribution you need a paid Apple Developer account and follow Xcode Archive flow.

---

## Run on Desktop (optional)

If you want to test a desktop build (Windows / macOS / Linux), sqflite requires the `sqflite_common_ffi` initialization. Example `main()` snippet:

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const WeatherApp());
}
```

Also add `sqflite_common_ffi` to `pubspec.yaml` when targeting desktop.

---

## Web — Important: NOT supported by default

This project uses `sqflite`, which is a native SQLite plugin not supported on Flutter Web. If you run on Chrome or other web platforms, you will get the error:

```
Error: Bad state: databaseFactory not initialized
databaseFactory is only initialized when using sqflite. When using `sqflite_common_ffi`...
```

Options:
- Quick unblock: run the app on mobile or desktop. For web development, avoid calling DB on web by detecting `kIsWeb` and skipping DB code.
- Proper web support: implement a web fallback (recommended choices)
  - `shared_preferences` (for simple key/value)
  - `hive` with web support
  - `sembast_web` or other browser-capable DB

Example: guard `DB` calls in `main.dart`:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

Future<bool> _hasUser() async {
  if (kIsWeb) return false; // skip sqflite on web
  final db = DBHelper();
  final user = await db.getAnyUser();
  return user != null;
}
```

For persistent login on web, implement a small web store using `shared_preferences`.

---

## Build release

Android (APK):
```
flutter build apk --release
```

Android (bundle):
```
flutter build appbundle --release
```

iOS (release):
```
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and Archive for App Store / TestFlight
```

Desktop (example):
```
flutter build windows
# or macos/linux depending on your platform
```

---

## Troubleshooting

- Asset errors (missing file):
  - If you see `No file or variants found for asset: assets/weather.png`, either:
    - Add `assets/weather.png` to the `assets/` folder, or
    - Remove/comment the asset path from `pubspec.yaml` and run `flutter pub get && flutter clean`.

- Permission handler plugin error (v1 embedding reference):
  - If you see Java compile errors referencing `PluginRegistry.Registrar`, run:
    ```
    flutter pub upgrade
    flutter clean
    rm -rf .dart_tool build
    flutter pub get
    ```
  - If the error persists, try removing `permission_handler` or update it to a newer version compatible with your Flutter SDK.

- Web DB error:
  - If running on web, guard DB calls using `kIsWeb` or implement a web fallback storage.

- "Waiting for another flutter command to release the startup lock":
  - Kill lingering flutter/dart processes (e.g., `pkill -f flutter` on macOS/Linux), remove `.dart_tool`, then `flutter clean` and retry.

- DatabaseFactory not initialized on desktop:
  - Make sure you call `sqfliteFfiInit(); databaseFactory = databaseFactoryFfi;` before any DB access when running on desktop.

---

## Project structure (important files)

- lib/
  - main.dart — app entry (handles auth redirect)
  - data/
    - db_helper.dart — SQLite helper (sqflite)
  - models/
    - user.dart, favorite.dart, city.dart
  - screens/
    - auth_screen.dart — login/register
    - main_app.dart — tabbed app shell
    - settings_screen.dart, favorites_screen.dart
  - tabs/
    - currently_tab.dart
    - weekly_tab.dart
    - today_tab.dart
  - services/
    - geocoding_service.dart
    - location_service.dart
  - widgets/
    - loading_overlay.dart

---

## What's implemented (assignment mapping)

- 4+ major screens: Auth + Currently + Weekly + Today (+ Settings + Favorites)
- 2+ third-party packages: geolocator, http, fl_chart, plus sqflite, etc.
- Layout widgets: Row, Column, Stack (loading overlay)
- State lifting: main_app holds selected state and passes to tabs
- Local SQL database: sqflite used for users & favorites (insert/select/update/delete)
- 2+ Dialog/SnackBar: SnackBar for city-not-found; AlertDialog for permission errors and add-favorite
- ListView usage: suggestions, weekly, hourly, favorites
- User input widgets: TextField (search), DropdownButton, SwitchListTile, RadioListTile, CheckboxListTile (in Settings)
- Navigators: Auth -> MainApp via Navigator, push to Settings/Favorites
- Models & project organization: lib/models, lib/data, lib/screens, lib/widgets

---

## Testing / Verification

- Register a user (Auth screen) -> should create an entry in sqflite (mobile).
- Login with the same credentials -> navigates to MainApp.
- Search for a city -> suggestions should appear or a SnackBar if not found.
- Deny location permission -> AlertDialog shown prompting action.
- Add favorite -> appears in Favorites screen and persists in SQLite.
- Run on Chrome -> app should load but no DB-backed persistence (unless you implement web fallback).

---

## Notes & Security

- For the assignment a hashed password stored in SQLite is acceptable. For production use:
  - Use per-user salt + bcrypt/PBKDF2
  - Use secure storage (Keychain / Android Keystore / flutter_secure_storage) for secrets/tokens

---

## Contact

If you need a PR with these changes applied, or want me to generate platform-specific patches (web fallback or iOS Info.plist edits), tell me which target and I will prepare the exact files.

---
```
