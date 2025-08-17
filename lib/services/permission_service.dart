import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class PermissionService {
  static Future<bool> checkAudioPermissions() async {
    try {
      // Test if we can play a system sound
      await SystemSound.play(SystemSoundType.click);
      return true;
    } catch (e) {
      debugPrint('Audio permission check failed: $e');
      return false;
    }
  }
  
  static Future<bool> requestAudioPermissions(BuildContext context) async {
    try {
      // For Android, we need to request notification permission for audio
      if (Platform.isAndroid) {
        // Show a dialog explaining why we need audio permissions
        bool? shouldRequest = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Audio Permissions'),
            content: const Text(
              'This app needs audio permissions to play timer completion sounds. '
              'Please ensure your device\'s media volume is turned on and '
              'notifications are enabled for the best experience.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        if (shouldRequest == true) {
          // Test audio playback
          await SystemSound.play(SystemSoundType.click);
          return true;
        }
        return false;
      }
      
      // For iOS, no special permissions needed
      return true;
    } catch (e) {
      debugPrint('Error requesting audio permissions: $e');
      return false;
    }
  }
  
  static Future<void> showAudioPermissionHelp(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Not Working?'),
        content: const Text(
          'If you\'re not hearing timer sounds:\n\n'
          '1. Check your device\'s media volume\n'
          '2. Ensure notifications are enabled\n'
          '3. Try restarting the app\n'
          '4. Check if your device is in silent mode\n\n'
          'The app will still provide haptic feedback even if audio doesn\'t work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
