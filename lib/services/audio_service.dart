import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io' show Platform;

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;
  static const MethodChannel _channel = MethodChannel('com.bashtech.focustimer/audio');
  
  // Stop any currently playing sound
  static Future<void> stopSound() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('stopSound');
        debugPrint('Stopped current sound');
      }
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Set audio mode for Android
      if (Platform.isAndroid) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
        
        // Set volume to ensure it's not muted
        await _audioPlayer.setVolume(1.0);
      }
      
      _isInitialized = true;
      debugPrint('AudioService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }

  static Future<void> playWorkCompleteSound() async {
    try {
      await initialize();
      debugPrint('Playing work completion sound');
      
      // Stop any currently playing sound first
      await stopSound();
      
      if (Platform.isAndroid) {
        await _channel.invokeMethod('playSystemSound', {'type': 'notification'});
      } else {
        await _playBeepSound(volume: 0.9);
      }
      
      // Vibration is handled by TimerModel based on user settings
    } catch (e) {
      debugPrint('Error playing work completion sound: $e');
      // Fallback to haptic feedback
      try {
        await HapticFeedback.lightImpact();
        debugPrint('Fallback to haptic feedback for work completion');
      } catch (fallbackError) {
        debugPrint('Fallback also failed: $fallbackError');
      }
    }
  }

  static Future<void> playBreakCompleteSound() async {
    try {
      await initialize();
      debugPrint('Playing break completion sound');
      
      // Stop any currently playing sound first
      await stopSound();
      
      if (Platform.isAndroid) {
        await _channel.invokeMethod('playSystemSound', {'type': 'notification'});
      } else {
        await _playBeepSound(volume: 0.8);
      }
      
      // Vibration is handled by TimerModel based on user settings
    } catch (e) {
      debugPrint('Error playing break completion sound: $e');
      try {
        await HapticFeedback.lightImpact();
        debugPrint('Fallback to haptic feedback for break completion');
      } catch (fallbackError) {
        debugPrint('Fallback also failed: $fallbackError');
      }
    }
  }

  static Future<void> playLongBreakCompleteSound() async {
    try {
      await initialize();
      debugPrint('Playing long break completion sound');
      
      // Stop any currently playing sound first
      await stopSound();
      
      if (Platform.isAndroid) {
        await _channel.invokeMethod('playSystemSound', {'type': 'notification'});
      } else {
        await _playBeepSound(volume: 0.8);
      }
      
      // Vibration is handled by TimerModel based on user settings
    } catch (e) {
      debugPrint('Error playing long break completion sound: $e');
      try {
        await HapticFeedback.lightImpact();
        debugPrint('Fallback to haptic feedback for long break completion');
      } catch (fallbackError) {
        debugPrint('Fallback also failed: $fallbackError');
      }
    }
  }

  static Future<void> playSystemSound(SystemSoundType soundType) async {
    try {
      await SystemSound.play(soundType);
    } catch (e) {
      debugPrint('Error playing system sound: $e');
    }
  }

  static Future<void> playCustomSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      // Fallback to system click
      await SystemSound.play(SystemSoundType.click);
      debugPrint('Playing custom sound: $soundFile');
    }
  }



  // Play a simple beep sound using native Android RingtoneManager
  static Future<void> _playBeepSound({double volume = 1.0}) async {
    try {
      debugPrint('Playing beep sound with volume: $volume');
      
      // Stop any currently playing sound first
      await stopSound();
      
      // Try native Android RingtoneManager first
      bool soundPlayed = false;
      
      if (Platform.isAndroid) {
        try {
          await _channel.invokeMethod('playSystemSound', {'type': 'notification'});
          soundPlayed = true;
          debugPrint('Native Android notification sound played successfully');
        } catch (e) {
          debugPrint('Native Android sound failed: $e');
        }
      }
      
      // Fallback to Flutter SystemSound
      if (!soundPlayed) {
        try {
          await SystemSound.play(SystemSoundType.click);
          soundPlayed = true;
          debugPrint('Flutter system sound played successfully');
        } catch (e) {
          debugPrint('Flutter system sound failed: $e');
        }
      }
      
      // Final fallback to haptic feedback
      if (!soundPlayed) {
        try {
          await HapticFeedback.mediumImpact();
          debugPrint('Haptic feedback as final fallback');
        } catch (e) {
          debugPrint('All audio methods failed: $e');
        }
      }
      
    } catch (e) {
      debugPrint('Error playing beep sound: $e');
      // Final fallback to haptic feedback
      try {
        await HapticFeedback.lightImpact();
      } catch (fallbackError) {
        debugPrint('Final fallback also failed: $fallbackError');
      }
    }
  }



  static void dispose() {
    _audioPlayer.dispose();
  }
}
