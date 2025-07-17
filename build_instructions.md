# 🚀 Build Instructions for AgriWise Stock Scanner

## 📱 Step 1: Add App Icon

1. **Create or download a 1024x1024 PNG app icon**
2. **Save it as:** `assets/icons/app_icon.png`
3. **Run icon generation:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons:main
   ```

## 🔨 Step 2: Build APK

### Debug APK (for testing):
```bash
flutter build apk --debug
```

### Release APK (for distribution):
```bash
flutter build apk --release
```

### Build App Bundle (for Google Play Store):
```bash
flutter build appbundle --release
```

## 📍 Output Locations:

- **Debug APK:** `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle:** `build/app/outputs/bundle/release/app-release.aab`

## 🎯 Quick Commands:

```bash
# Get dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Build release APK
flutter build apk --release

# Install on connected device
flutter install
```

## 📝 Notes:

- Make sure your app icon is 1024x1024 PNG format
- The app will be named "AgriWise Stock Scanner"
- Green theme color: #356033
- For Play Store: use app bundle (.aab) instead of APK
