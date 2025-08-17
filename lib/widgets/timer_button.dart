import 'package:flutter/material.dart';
import '../models/timer_model.dart';

class TimerButton extends StatelessWidget {
  final TimerModel timerModel;
  final VoidCallback onTap;

  const TimerButton({
    super.key,
    required this.timerModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors().first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Progress indicator
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: timerModel.progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            
            // Timer display
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Session type
                  Text(
                    timerModel.sessionTypeText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontFamily: 'Inter',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Time text
                  Text(
                    timerModel.formattedTime,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status text
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            // Play/Pause icon overlay
            if (timerModel.isRunning || timerModel.isPaused)
              Positioned(
                bottom: 40,
                right: 40,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    timerModel.isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (timerModel.sessionType) {
      case SessionType.work:
        return [
          const Color(0xFF6750A4), // Purple for work
          const Color(0xFF8B5CF6),
        ];
      case SessionType.shortBreak:
        return [
          const Color(0xFF10B981), // Green for short break
          const Color(0xFF34D399),
        ];
      case SessionType.longBreak:
        return [
          const Color(0xFF3B82F6), // Blue for long break
          const Color(0xFF60A5FA),
        ];
    }
  }

  String _getStatusText() {
    switch (timerModel.state) {
      case TimerState.idle:
        return 'Tap to start ${timerModel.sessionTypeText.toLowerCase()}';
      case TimerState.running:
        return '${timerModel.nextSessionText}';
      case TimerState.paused:
        return 'Paused';
      case TimerState.completed:
        return '${timerModel.sessionTypeText} Complete!';
    }
  }
}
