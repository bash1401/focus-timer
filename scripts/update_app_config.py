#!/usr/bin/env python3
"""
App Configuration Update Script
This script reads app_config.yaml and updates all platform-specific configuration files
"""

import yaml
import os
import re
import shutil
from pathlib import Path

def load_config():
    """Load the app configuration from YAML file"""
    with open('app_config.yaml', 'r') as file:
        return yaml.safe_load(file)

def update_pubspec_yaml(config):
    """Update pubspec.yaml with app information"""
    pubspec_path = 'pubspec.yaml'
    
    with open(pubspec_path, 'r') as file:
        content = file.read()
    
    # Update version
    content = re.sub(
        r'version:\s*[\d.]+',
        f'version: {config["app"]["version"]}',
        content
    )
    
    # Update description
    content = re.sub(
        r'description:\s*.*',
        f'description: {config["app"]["description"]}',
        content
    )
    
    with open(pubspec_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {pubspec_path}")

def update_android_manifest(config):
    """Update Android manifest with package name and permissions"""
    manifest_path = 'android/app/src/main/AndroidManifest.xml'
    
    with open(manifest_path, 'r') as file:
        content = file.read()
    
    # Update package name
    content = re.sub(
        r'package="[^"]*"',
        f'package="{config["app"]["android_package_name"]}"',
        content
    )
    
    # Update app label
    content = re.sub(
        r'android:label="[^"]*"',
        f'android:label="{config["app"]["name"]}"',
        content
    )
    
    with open(manifest_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {manifest_path}")

def update_android_build_gradle(config):
    """Update Android build.gradle with version and package name"""
    build_gradle_path = 'android/app/build.gradle.kts'
    
    with open(build_gradle_path, 'r') as file:
        content = file.read()
    
    # Update namespace
    content = re.sub(
        r'namespace\s*=\s*"[^"]*"',
        f'namespace = "{config["app"]["android_package_name"]}"',
        content
    )
    
    # Update version code and name
    version_parts = config["app"]["version"].split('.')
    version_code = int(version_parts[0]) * 10000 + int(version_parts[1]) * 100 + int(version_parts[2])
    
    content = re.sub(
        r'versionCode\s*=\s*\d+',
        f'versionCode = {config["app"]["build_number"]}',
        content
    )
    
    content = re.sub(
        r'versionName\s*=\s*"[^"]*"',
        f'versionName = "{config["app"]["version"]}"',
        content
    )
    
    with open(build_gradle_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {build_gradle_path}")

def update_ios_info_plist(config):
    """Update iOS Info.plist with bundle identifier and app information"""
    info_plist_path = 'ios/Runner/Info.plist'
    
    with open(info_plist_path, 'r') as file:
        content = file.read()
    
    # Update bundle identifier
    content = re.sub(
        r'<key>CFBundleIdentifier</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleIdentifier</key>\n\t<string>{config["app"]["ios_bundle_identifier"]}</string>',
        content
    )
    
    # Update app name
    content = re.sub(
        r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleDisplayName</key>\n\t<string>{config["app"]["name"]}</string>',
        content
    )
    
    # Update version
    content = re.sub(
        r'<key>CFBundleShortVersionString</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleShortVersionString</key>\n\t<string>{config["app"]["version"]}</string>',
        content
    )
    
    # Update build number
    content = re.sub(
        r'<key>CFBundleVersion</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleVersion</key>\n\t<string>{config["app"]["build_number"]}</string>',
        content
    )
    
    with open(info_plist_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {info_plist_path}")

def update_macos_info_plist(config):
    """Update macOS Info.plist with bundle identifier and app information"""
    info_plist_path = 'macos/Runner/Info.plist'
    
    with open(info_plist_path, 'r') as file:
        content = file.read()
    
    # Update bundle identifier
    content = re.sub(
        r'<key>CFBundleIdentifier</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleIdentifier</key>\n\t<string>{config["app"]["macos_bundle_identifier"]}</string>',
        content
    )
    
    # Update app name
    content = re.sub(
        r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleDisplayName</key>\n\t<string>{config["app"]["name"]}</string>',
        content
    )
    
    # Update version
    content = re.sub(
        r'<key>CFBundleShortVersionString</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleShortVersionString</key>\n\t<string>{config["app"]["version"]}</string>',
        content
    )
    
    # Update build number
    content = re.sub(
        r'<key>CFBundleVersion</key>\s*<string>[^<]*</string>',
        f'<key>CFBundleVersion</key>\n\t<string>{config["app"]["build_number"]}</string>',
        content
    )
    
    with open(info_plist_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {info_plist_path}")

def update_web_manifest(config):
    """Update web manifest with app information"""
    manifest_path = 'web/manifest.json'
    
    with open(manifest_path, 'r') as file:
        content = file.read()
    
    # Update app name
    content = re.sub(
        r'"name":\s*"[^"]*"',
        f'"name": "{config["app"]["name"]}"',
        content
    )
    
    # Update short name
    content = re.sub(
        r'"short_name":\s*"[^"]*"',
        f'"short_name": "{config["app"]["name"]}"',
        content
    )
    
    # Update description
    content = re.sub(
        r'"description":\s*"[^"]*"',
        f'"description": "{config["app"]["description"]}"',
        content
    )
    
    with open(manifest_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {manifest_path}")

def update_main_dart(config):
    """Update main.dart with app title"""
    main_dart_path = 'lib/main.dart'
    
    with open(main_dart_path, 'r') as file:
        content = file.read()
    
    # Update app title
    content = re.sub(
        r'title:\s*"[^"]*"',
        f'title: "{config["app"]["name"]}"',
        content
    )
    
    with open(main_dart_path, 'w') as file:
        file.write(content)
    
    print(f"✅ Updated {main_dart_path}")

def copy_app_icons(config):
    """Copy app icons to all platform directories"""
    source_icon = config["app"]["icons"]["source"]
    
    if not os.path.exists(source_icon):
        print(f"⚠️  Warning: Source icon {source_icon} not found")
        return
    
    # Android icons
    android_icon_dirs = [
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
    ]
    
    for icon_path in android_icon_dirs:
        shutil.copy2(source_icon, icon_path)
        print(f"✅ Copied icon to {icon_path}")
    
    # iOS icons
    ios_icon_files = [
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png',
    ]
    
    for icon_path in ios_icon_files:
        if os.path.exists(os.path.dirname(icon_path)):
            shutil.copy2(source_icon, icon_path)
            print(f"✅ Copied icon to {icon_path}")
    
    # macOS icons
    macos_icon_files = [
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png',
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png',
    ]
    
    for icon_path in macos_icon_files:
        if os.path.exists(os.path.dirname(icon_path)):
            shutil.copy2(source_icon, icon_path)
            print(f"✅ Copied icon to {icon_path}")
    
    # Web icons
    web_icon_files = [
        'web/favicon.png',
        'web/icons/Icon-192.png',
        'web/icons/Icon-512.png',
        'web/icons/Icon-maskable-192.png',
        'web/icons/Icon-maskable-512.png',
    ]
    
    for icon_path in web_icon_files:
        if os.path.exists(os.path.dirname(icon_path)):
            shutil.copy2(source_icon, icon_path)
            print(f"✅ Copied icon to {icon_path}")

def create_config_reader():
    """Create a Dart file to read the configuration in the app"""
    config_reader_content = '''
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = "Focus Timer";
  static const String appVersion = "1.0.0";
  static const int buildNumber = 1;
  static const String description = "A simple and effective Pomodoro timer for focused work sessions";
  
  // Developer Information
  static const String developerName = "BashTech";
  static const String developerWebsite = "https://www.bashtech.info/";
  static const String developerEmail = "support@bashtech.info";
  
  // URLs
  static const String privacyPolicy = "https://www.bashtech.info/privacy";
  static const String termsOfService = "https://www.bashtech.info/terms";
  static const String support = "https://www.bashtech.info/support";
  static const String buyCoffee = "https://www.bashtech.info/buy-coffee";
  
  // Default Settings
  static const int defaultWorkDuration = 25;
  static const int defaultShortBreakDuration = 5;
  static const int defaultLongBreakDuration = 15;
  static const int defaultSessionsBeforeLongBreak = 4;
  static const bool defaultAutoStartBreaks = true;
  static const bool defaultAutoStartWork = true;
  static const bool defaultSoundEnabled = true;
  static const bool defaultVibrationEnabled = true;
  
  // Theme Colors
  static const String primaryColor = "#00BCD4";
  static const String secondaryColor = "#009688";
  static const String backgroundColor = "#1E1E1E";
  static const String surfaceColor = "#2D2D2D";
  static const String textColor = "#FFFFFF";
}
'''
    
    # Create config directory if it doesn't exist
    os.makedirs('lib/config', exist_ok=True)
    
    with open('lib/config/app_config.dart', 'w') as file:
        file.write(config_reader_content)
    
    print("✅ Created lib/config/app_config.dart")

def main():
    """Main function to update all configuration files"""
    print("🚀 Starting app configuration update...")
    
    try:
        # Load configuration
        config = load_config()
        print(f"📋 Loaded configuration for {config['app']['name']} v{config['app']['version']}")
        
        # Update all files
        update_pubspec_yaml(config)
        update_android_manifest(config)
        update_android_build_gradle(config)
        update_ios_info_plist(config)
        update_macos_info_plist(config)
        update_web_manifest(config)
        update_main_dart(config)
        copy_app_icons(config)
        create_config_reader()
        
        print("\n🎉 App configuration update completed successfully!")
        print(f"📱 App: {config['app']['name']}")
        print(f"📦 Version: {config['app']['version']} (Build {config['app']['build_number']})")
        print(f"🤖 Android Package: {config['app']['android_package_name']}")
        print(f"🍎 iOS Bundle: {config['app']['ios_bundle_identifier']}")
        print(f"🖥️  macOS Bundle: {config['app']['macos_bundle_identifier']}")
        
    except Exception as e:
        print(f"❌ Error updating configuration: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
