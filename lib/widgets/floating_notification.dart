import 'package:flutter/material.dart';

class FloatingNotificationHelper {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing notification
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    _currentEntry = OverlayEntry(
      builder: (context) => _FloatingNotification(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    IconData icon = Icons.check_circle,
  }) {
    show(
      context: context,
      message: message,
      icon: icon,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    IconData icon = Icons.info,
  }) {
    show(
      context: context,
      message: message,
      icon: icon,
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
    );
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _FloatingNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback onDismiss;

  const _FloatingNotification({
    required this.message,
    required this.icon,
    this.backgroundColor,
    required this.onDismiss,
  });

  @override
  State<_FloatingNotification> createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<_FloatingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.backgroundColor != null
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: widget.backgroundColor != null
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onDismiss,
                          icon: Icon(
                            Icons.close,
                            color: widget.backgroundColor != null
                                ? Colors.white.withValues(alpha: 0.8)
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
