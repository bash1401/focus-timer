package com.bashtech.focustimer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bashtech.focustimer/audio"
    private var currentRingtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playSystemSound" -> {
                    val soundType = call.argument<String>("type")
                    playSystemSound(soundType, result)
                }
                "stopSound" -> {
                    stopCurrentSound()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun playSystemSound(soundType: String?, result: MethodChannel.Result) {
        try {
            // Stop any currently playing sound first
            stopCurrentSound()
            
            val ringtoneType = when (soundType) {
                "notification" -> RingtoneManager.TYPE_NOTIFICATION
                "alarm" -> RingtoneManager.TYPE_ALARM
                "ringtone" -> RingtoneManager.TYPE_RINGTONE
                else -> RingtoneManager.TYPE_NOTIFICATION
            }
            
            val soundUri = RingtoneManager.getDefaultUri(ringtoneType)
            if (soundUri != null) {
                val ringtone = RingtoneManager.getRingtone(this, soundUri)
                if (ringtone != null) {
                    // Store reference to current ringtone
                    currentRingtone = ringtone
                    ringtone.play()
                    result.success(true)
                } else {
                    result.error("RINGTONE_NULL", "Could not create ringtone", null)
                }
            } else {
                result.error("URI_NULL", "Could not get sound URI", null)
            }
        } catch (e: Exception) {
            result.error("PLAYBACK_ERROR", "Error playing sound: ${e.message}", null)
        }
    }
    
    private fun stopCurrentSound() {
        try {
            currentRingtone?.let { ringtone ->
                if (ringtone.isPlaying) {
                    ringtone.stop()
                }
                currentRingtone = null
            }
        } catch (e: Exception) {
            // Ignore errors when stopping sound
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopCurrentSound()
    }
}
