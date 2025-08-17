# App Configuration System

This document explains how to use the centralized app configuration system for the Focus Timer app.

## 📁 Files Overview

### Configuration Files
- **`app_config.yaml`** - Main configuration file (edit this to change app settings)
- **`scripts/update_app_config.py`** - Python script that applies configuration changes
- **`update_config.sh`** - Shell script to easily run configuration updates
- **`lib/config/app_config.dart`** - Generated Dart file for accessing config in code

## 🚀 Quick Start

### 1. Edit Configuration
Open `app_config.yaml` and modify the values you want to change:

```yaml
app:
  name: "Focus Timer"
  version: "1.0.0"
  build_number: 1
  android_package_name: "com.example.taptimer"
  # ... other settings
```

### 2. Apply Changes
Run the update script:

```bash
./update_config.sh
```

### 3. Build and Test
The changes are now applied across all platforms!

## 📋 Configuration Options

### Basic App Information
```yaml
app:
  name: "Focus Timer"                    # App display name
  description: "A simple Pomodoro timer" # App description
  version: "1.0.0"                      # Semantic version
  build_number: 1                       # Build number for stores
```

### Package/Bundle Identifiers
```yaml
app:
  android_package_name: "com.example.taptimer"
  ios_bundle_identifier: "com.example.taptimer"
  macos_bundle_identifier: "com.example.taptimer"
```

### Developer Information
```yaml
app:
  developer:
    name: "BashTech"
    website: "https://www.bashtech.info/"
    email: "support@bashtech.info"
```

### App Icons
```yaml
app:
  icons:
    source: "assets/sounds/images/logo.png"  # Source icon file
    android_adaptive_icon: true              # Use adaptive icons on Android
    ios_icon_sizes: [20, 29, 40, 60, 76, 83.5, 1024]
```

### Theme Configuration
```yaml
app:
  theme:
    primary_color: "#00BCD4"
    secondary_color: "#009688"
    background_color: "#1E1E1E"
    surface_color: "#2D2D2D"
    text_color: "#FFFFFF"
```

### Default Settings
```yaml
app:
  defaults:
    work_duration: 25                    # minutes
    short_break_duration: 5              # minutes
    long_break_duration: 15              # minutes
    sessions_before_long_break: 4
    auto_start_breaks: true
    auto_start_work: true
    sound_enabled: true
    vibration_enabled: true
```

### URLs and Links
```yaml
app:
  urls:
    privacy_policy: "https://www.bashtech.info/privacy"
    terms_of_service: "https://www.bashtech.info/terms"
    support: "https://www.bashtech.info/support"
    buy_coffee: "https://www.bashtech.info/buy-coffee"
```

## 🔧 Using Configuration in Code

### Accessing Config Values
Import and use the generated config class:

```dart
import 'package:your_app/config/app_config.dart';

// Use configuration values
Text(AppConfig.appName)
Text('Version ${AppConfig.appVersion}')
```

### Available Config Properties
```dart
// App Information
AppConfig.appName
AppConfig.appVersion
AppConfig.buildNumber
AppConfig.description

// Developer Information
AppConfig.developerName
AppConfig.developerWebsite
AppConfig.developerEmail

// URLs
AppConfig.privacyPolicy
AppConfig.termsOfService
AppConfig.support
AppConfig.buyCoffee

// Default Settings
AppConfig.defaultWorkDuration
AppConfig.defaultShortBreakDuration
AppConfig.defaultLongBreakDuration
AppConfig.defaultSessionsBeforeLongBreak
AppConfig.defaultAutoStartBreaks
AppConfig.defaultAutoStartWork
AppConfig.defaultSoundEnabled
AppConfig.defaultVibrationEnabled

// Theme Colors
AppConfig.primaryColor
AppConfig.secondaryColor
AppConfig.backgroundColor
AppConfig.surfaceColor
AppConfig.textColor
```

## 📱 Platform-Specific Updates

The configuration system updates these files:

### Android
- `android/app/src/main/AndroidManifest.xml` - Package name, app label, permissions
- `android/app/build.gradle.kts` - Version code, version name, namespace
- `android/app/src/main/res/mipmap-*/ic_launcher.png` - App icons

### iOS
- `ios/Runner/Info.plist` - Bundle identifier, app name, version
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` - App icons

### macOS
- `macos/Runner/Info.plist` - Bundle identifier, app name, version
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png` - App icons

### Web
- `web/manifest.json` - App name, description
- `web/favicon.png` - Favicon
- `web/icons/*.png` - Web app icons

### Flutter
- `pubspec.yaml` - Version, description
- `lib/main.dart` - App title
- `lib/config/app_config.dart` - Generated config class

## 🔄 Workflow

### For New Releases
1. Update version and build number in `app_config.yaml`
2. Run `./update_config.sh`
3. Test the app
4. Build and deploy

### For App Store Updates
1. Update version, build number, and any other changes
2. Run `./update_config.sh`
3. Build release versions
4. Submit to app stores

### For Development
1. Make changes to `app_config.yaml` as needed
2. Run `./update_config.sh` to apply changes
3. Continue development

## 🛠️ Troubleshooting

### Common Issues

**Script fails to run:**
- Ensure Python 3 is installed
- The script will create a virtual environment automatically
- Check that `app_config.yaml` exists

**Icons not updating:**
- Ensure the source icon file exists at the specified path
- Check that the icon file is a valid PNG image
- Verify file permissions

**Version not updating:**
- Check that the version format is correct (e.g., "1.0.0")
- Ensure build number is an integer
- Run `./update_config.sh` again

### Manual Updates
If the script fails, you can manually update files:

1. **pubspec.yaml**: Update version and description
2. **Android**: Update AndroidManifest.xml and build.gradle.kts
3. **iOS**: Update Info.plist
4. **macOS**: Update Info.plist
5. **Web**: Update manifest.json

## 📝 Best Practices

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Increment build number for each release
- Keep version and build number in sync across platforms

### Package Names
- Use reverse domain notation (com.company.appname)
- Keep package names consistent across platforms
- Avoid using reserved words or special characters

### Icons
- Use a high-resolution source image (1024x1024 or larger)
- Ensure the image has good contrast and is recognizable at small sizes
- Test icons on actual devices

### Configuration Values
- Use meaningful default values
- Document any special requirements or constraints
- Test configuration changes thoroughly

## 🔗 Related Files

- `app_config.yaml` - Main configuration file
- `scripts/update_app_config.py` - Update script
- `update_config.sh` - Shell wrapper
- `lib/config/app_config.dart` - Generated Dart config
- `CONFIGURATION.md` - This documentation

## 📞 Support

If you encounter issues with the configuration system:

1. Check this documentation
2. Review the error messages from the update script
3. Verify the YAML syntax in `app_config.yaml`
4. Ensure all required files exist

For additional help, contact the development team.
