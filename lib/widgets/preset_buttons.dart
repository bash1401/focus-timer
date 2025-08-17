import 'package:flutter/material.dart';
import '../models/timer_model.dart';

class PresetButtons extends StatelessWidget {
  final Function(SessionType) onSessionTypeSelected;
  final SessionType selectedSessionType;
  final bool isTimerRunning;

  const PresetButtons({
    super.key,
    required this.onSessionTypeSelected,
    required this.selectedSessionType,
    required this.isTimerRunning,
  });

  @override
  Widget build(BuildContext context) {
    final sessionTypes = [
      SessionType.work,
      SessionType.shortBreak,
      SessionType.longBreak,
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: sessionTypes.map((sessionType) {
          final isSelected = selectedSessionType == sessionType;
          final isDisabled = _isButtonDisabled(sessionType);
          return _SessionTypeButton(
            sessionType: sessionType,
            isSelected: isSelected,
            isDisabled: isDisabled,
            onTap: isDisabled ? null : () => onSessionTypeSelected(sessionType),
          );
        }).toList(),
      ),
    );
  }

  bool _isButtonDisabled(SessionType sessionType) {
    if (!isTimerRunning) return false;
    
    // When work session is running, disable break buttons
    if (selectedSessionType == SessionType.work) {
      return sessionType == SessionType.shortBreak || sessionType == SessionType.longBreak;
    }
    
    // When short break is running, disable work and long break buttons
    if (selectedSessionType == SessionType.shortBreak) {
      return sessionType == SessionType.work || sessionType == SessionType.longBreak;
    }
    
    // When long break is running, disable work and short break buttons
    if (selectedSessionType == SessionType.longBreak) {
      return sessionType == SessionType.work || sessionType == SessionType.shortBreak;
    }
    
    return false;
  }
}

class _SessionTypeButton extends StatelessWidget {
  final SessionType sessionType;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _SessionTypeButton({
    required this.sessionType,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled 
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
            : isSelected 
              ? _getSessionColor()
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDisabled
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)
              : isSelected 
                ? _getSessionColor()
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected && !isDisabled ? [
            BoxShadow(
              color: _getSessionColor().withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSessionIcon(),
              size: 16,
              color: isDisabled
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                : isSelected 
                  ? Colors.white
                  : _getSessionColor(),
            ),
            const SizedBox(width: 8),
            Text(
              _getSessionText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                  : isSelected 
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSessionColor() {
    switch (sessionType) {
      case SessionType.work:
        return const Color(0xFF6750A4);
      case SessionType.shortBreak:
        return const Color(0xFF10B981);
      case SessionType.longBreak:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getSessionIcon() {
    switch (sessionType) {
      case SessionType.work:
        return Icons.work;
      case SessionType.shortBreak:
        return Icons.coffee;
      case SessionType.longBreak:
        return Icons.beach_access;
    }
  }

  String _getSessionText() {
    switch (sessionType) {
      case SessionType.work:
        return 'Work';
      case SessionType.shortBreak:
        return 'Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }
}
