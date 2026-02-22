# Spend Tracker

Offline personal expense tracker built with Flutter, Provider, SQLite, and FL Chart.

## Tech Stack
- Flutter (Material 3, dark UI)
- Provider for state management
- sqflite for local persistence
- fl_chart for dashboard analytics

## Run Locally
```bash
flutter pub get
flutter run
```

## Quality Checks
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Android Release Setup
1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill keystore values in `android/key.properties`.
3. Ensure `storeFile` points to your `.jks` file.
4. Build:
```bash
flutter build appbundle --release
```

Note: if `android/key.properties` is missing, release builds fall back to debug signing for local testing only.

## iOS Build / Release Setup
**If you see "could not find Generated.xcconfig" or build fails from Xcode:**

1. From the project root, run (this creates `ios/Flutter/Generated.xcconfig` and installs pods):
   ```bash
   flutter pub get && cd ios && pod install && cd ..
   ```
   Or use the script: `sh scripts/ios_prepare.sh`
2. Open **`ios/Runner.xcworkspace`** in Xcode (use the `.xcworkspace`, not `.xcodeproj`).
3. Set your Team, Bundle Identifier, and Signing Certificate in the Runner target.
4. Build from Xcode or run:
   ```bash
   flutter run
   # or for release:
   flutter build ipa --release
   ```

## App Assets
- Launcher icon and splash are generated from: `assets/icon/app_icon.png`
- Regenerate when icon changes:
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
