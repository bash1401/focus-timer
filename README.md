# Focus Timer - The One-Tap Timer App

A super-minimalist timer app designed for maximum productivity with minimal distractions.

## Features

### Core Functionality
- **One-Tap Timer**: Single tap to start a 25-minute Pomodoro timer
- **Tap to Pause/Resume**: Tap again to pause or resume the timer
- **Swipe to Reset**: Swipe horizontally to reset the timer
- **Quick Presets**: 5, 10, 15, 25, and 30-minute presets
- **Notification Support**: Timer runs in notification bar with progress
- **Auto "Do Not Disturb"**: Optional feature to enable DND during timer

### Additional Features
- **Custom Timer Sounds**: Choose from various completion sounds
- **Advanced Statistics**: Track your productivity sessions
- **Task Management**: Keep track of what you're working on

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd focus_timer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Configuration

#### App Setup
1. Configure your app in Google Play Console or App Store Connect
2. Set up app signing and distribution
3. Configure app permissions as needed

#### Android Configuration
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
```

#### iOS Configuration
Add the following to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for audio feedback.</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-processing</string>
</array>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── timer_model.dart      # Timer logic and state management
├── screens/
│   └── timer_screen.dart     # Main timer screen
├── services/
│   └── notification_service.dart  # Local notifications
└── widgets/
    ├── timer_button.dart     # Main timer button
    ├── preset_buttons.dart   # Duration preset buttons
    └── banner_ad_widget.dart # Banner ad widget
```

## Dependencies

- `flutter_local_notifications`: Local notifications
- `permission_handler`: Permission management

- `shared_preferences`: Local storage
- `audioplayers`: Audio playback
- `vibration`: Haptic feedback
- `provider`: State management

## Design Philosophy

TapTimer follows a minimalist design philosophy:

1. **One Action**: Everything should be achievable with one tap
2. **No Distractions**: Clean UI with no unnecessary elements
3. **Intuitive Gestures**: Swipe to reset, tap to toggle
4. **Visual Feedback**: Clear progress indicators and animations
5. **Accessibility**: Large touch targets and clear typography

## App Philosophy

Focus Timer is completely free and open-source, designed to help users improve their productivity without any distractions or monetization barriers.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, create an issue in the repository.

## Roadmap

- [ ] Custom timer sounds
- [ ] Advanced statistics dashboard
- [ ] Multiple timer sessions
- [ ] Apple Watch integration
- [ ] Widget support
- [ ] Dark mode improvements
- [ ] Accessibility enhancements
