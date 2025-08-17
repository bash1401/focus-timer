import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_model.dart';
import '../widgets/timer_button.dart';
import '../widgets/preset_buttons.dart';
import '../widgets/task_input.dart';
import '../widgets/productivity_stats.dart';
import '../widgets/current_task_display.dart';
import '../widgets/floating_notification.dart';
import '../widgets/app_banner.dart';

import 'settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late TimerModel _timerModel;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _timerModel = TimerModel();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load settings
    _timerModel.loadSettings();
    
    // Listen for timer state changes to show completion notifications
    _timerModel.addListener(_onTimerStateChanged);
  }



  void _onTimerStateChanged() {
    // Show completion notification when timer completes
    if (_timerModel.state == TimerState.completed) {
      String message;
      IconData icon;
      
      switch (_timerModel.sessionType) {
        case SessionType.work:
          message = 'Focus session completed! 🎯';
          icon = Icons.work;
          break;
        case SessionType.shortBreak:
          message = 'Short break completed! ☕';
          icon = Icons.coffee;
          break;
        case SessionType.longBreak:
          message = 'Long break completed! 🌟';
          icon = Icons.star;
          break;
      }
      
      FloatingNotificationHelper.showSuccess(
        context: context,
        message: message,
        icon: icon,
      );
    }
  }

  void _onTimerTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    _timerModel.toggle();
  }

  void _onSwipeReset() {
    HapticFeedback.lightImpact();
    _timerModel.reset();
  }

  void _onSessionTypeSelected(SessionType sessionType) {
    _timerModel.reset();
    switch (sessionType) {
      case SessionType.work:
        _timerModel.startWorkSession();
        break;
      case SessionType.shortBreak:
        _timerModel.startShortBreak();
        break;
      case SessionType.longBreak:
        _timerModel.startLongBreak();
        break;
    }
    HapticFeedback.selectionClick();
  }

  void _onTaskChanged(String task) {
    _timerModel.setCurrentTask(task);
  }



  void _showProductivityStatsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Close when tapped outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 700,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Productivity Stats',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildProductivityStats(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            
            // Task Input
            ListenableBuilder(
              listenable: _timerModel,
              builder: (context, child) {
                return TaskInput(
                  currentTask: _timerModel.currentTask,
                  onTaskChanged: _onTaskChanged,
                );
              },
            ),
            
            // Current Task Display
            ListenableBuilder(
              listenable: _timerModel,
              builder: (context, child) {
                return CurrentTaskDisplay(
                  currentTask: _timerModel.currentTask,
                  isWorkSession: _timerModel.isWorkSession,
                );
              },
            ),
            
            // Main Timer Area - Reduced space to accommodate banner
            Expanded(
              flex: 2,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    _onSwipeReset();
                  }
                },
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ListenableBuilder(
                          listenable: _timerModel,
                          builder: (context, child) {
                            return TimerButton(
                              timerModel: _timerModel,
                              onTap: _onTimerTap,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // App Banner
            const AppBanner(),
            
            // Session Type Buttons
            ListenableBuilder(
              listenable: _timerModel,
              builder: (context, child) {
                return PresetButtons(
                  onSessionTypeSelected: _onSessionTypeSelected,
                  selectedSessionType: _timerModel.sessionType,
                  isTimerRunning: _timerModel.isRunning,
                );
              },
            ),
            

            

            
            const SizedBox(height: 10), // Reduced bottom spacing
          ],
        ),
      ),
    );
  }



  Widget _buildProductivityStats() {
    return ListenableBuilder(
      listenable: _timerModel,
      builder: (context, child) {
        return ProductivityStats(
          completedSessions: _timerModel.completedSessions,
          completedWorkSessions: _timerModel.completedWorkSessions,
          completedBreaks: _timerModel.completedBreaks,
          taskStats: _timerModel.taskStats,
          dailyStats: _timerModel.dailyStats,
          availableDates: _timerModel.getAvailableDates(),
          onResetStats: () {
            _timerModel.resetStats();
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings button
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              // Reload settings when returning from settings screen
              await _timerModel.reloadSettings();
            },
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // Title
          Text(
            'Focus Timer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // Stats button
          IconButton(
            onPressed: () {
              _showProductivityStatsDialog();
            },
            icon: Icon(
              Icons.bar_chart_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timerModel.removeListener(_onTimerStateChanged);
    _timerModel.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
