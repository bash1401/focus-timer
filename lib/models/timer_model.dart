import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';

enum TimerState { idle, running, paused, completed }
enum SessionType { work, shortBreak, longBreak }

class TimerModel extends ChangeNotifier {
  Timer? _timer;
  TimerState _state = TimerState.idle;
  SessionType _sessionType = SessionType.work;
  
  // Pomodoro settings
  int _workDuration = 25 * 60; // 25 minutes
  int _shortBreakDuration = 5 * 60; // 5 minutes
  int _longBreakDuration = 15 * 60; // 15 minutes
  int _sessionsUntilLongBreak = 4; // Long break after 4 work sessions
  
  // Current session tracking
  int _remainingTime = 25 * 60;
  int _totalTime = 25 * 60;
  int _completedSessions = 0;
  int _completedWorkSessions = 0;
  int _completedBreaks = 0;
  
  // Auto-start settings
  bool _autoStartBreaks = false;
  bool _autoStartWork = false;
  bool _autoStartInProgress = false;
  
  // Audio settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Habit tracking
  String _currentTask = '';
  Map<String, int> _taskStats = {}; // task name -> minutes spent
  
  // Daily statistics tracking
  Map<String, Map<String, dynamic>> _dailyStats = {}; // date -> stats
  


  // Getters
  TimerState get state => _state;
  SessionType get sessionType => _sessionType;
  int get remainingTime => _remainingTime;
  int get totalTime => _totalTime;
  int get completedSessions => _completedSessions;
  int get completedWorkSessions => _completedWorkSessions;
  int get completedBreaks => _completedBreaks;
  String get currentTask => _currentTask;
  Map<String, int> get taskStats => _taskStats;
  Map<String, Map<String, dynamic>> get dailyStats => _dailyStats;
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartWork => _autoStartWork;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  double get progress => _totalTime > 0 ? (_totalTime - _remainingTime) / _totalTime : 0.0;

  String get formattedTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionTypeText {
    switch (_sessionType) {
      case SessionType.work:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  String get nextSessionText {
    switch (_sessionType) {
      case SessionType.work:
        return _completedWorkSessions % _sessionsUntilLongBreak == _sessionsUntilLongBreak - 1
            ? 'Long Break Next'
            : 'Short Break Next';
      case SessionType.shortBreak:
      case SessionType.longBreak:
        return 'Work Session Next';
    }
  }

  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isCompleted => _state == TimerState.completed;
  bool get isIdle => _state == TimerState.idle;
  bool get isWorkSession => _sessionType == SessionType.work;

  // Setters
  void setWorkDuration(int minutes) {
    _workDuration = minutes * 60;
    if (_sessionType == SessionType.work) {
      _totalTime = _workDuration;
      _remainingTime = _workDuration;
    }
    notifyListeners();
  }

  void setShortBreakDuration(int minutes) {
    _shortBreakDuration = minutes * 60;
    if (_sessionType == SessionType.shortBreak) {
      _totalTime = _shortBreakDuration;
      _remainingTime = _shortBreakDuration;
    }
    notifyListeners();
  }

  void setLongBreakDuration(int minutes) {
    _longBreakDuration = minutes * 60;
    if (_sessionType == SessionType.longBreak) {
      _totalTime = _longBreakDuration;
      _remainingTime = _longBreakDuration;
    }
    notifyListeners();
  }

  void setSessionsUntilLongBreak(int sessions) {
    _sessionsUntilLongBreak = sessions;
    notifyListeners();
  }

  void setAutoStartBreaks(bool enabled) {
    _autoStartBreaks = enabled;
    notifyListeners();
  }

  void setAutoStartWork(bool enabled) {
    _autoStartWork = enabled;
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
  }

  void setCurrentTask(String task) {
    _currentTask = task;
    notifyListeners();
  }

  // Session management
  void startWorkSession() {
    _sessionType = SessionType.work;
    _totalTime = _workDuration;
    _remainingTime = _workDuration;
    _state = TimerState.idle;
    notifyListeners();
  }

  void startShortBreak() {
    _sessionType = SessionType.shortBreak;
    _totalTime = _shortBreakDuration;
    _remainingTime = _shortBreakDuration;
    _state = TimerState.idle;
    notifyListeners();
  }

  void startLongBreak() {
    _sessionType = SessionType.longBreak;
    _totalTime = _longBreakDuration;
    _remainingTime = _longBreakDuration;
    _state = TimerState.idle;
    notifyListeners();
  }

  void startNextSession() {
    debugPrint('startNextSession called - Current session type: $_sessionType');
    
    // Cancel any running timer first
    _timer?.cancel();
    
    switch (_sessionType) {
      case SessionType.work:
        if (_completedWorkSessions % _sessionsUntilLongBreak == _sessionsUntilLongBreak - 1) {
          debugPrint('Starting long break');
          startLongBreak();
        } else {
          debugPrint('Starting short break');
          startShortBreak();
        }
        break;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        debugPrint('Starting work session');
        startWorkSession();
        break;
    }
  }

  void skip() {
    debugPrint('Skip called - Current state: $_state, SessionType: $_sessionType');
    
    // Cancel any running timer
    _timer?.cancel();
    
    // Mark as completed without triggering auto-start or sound
    _state = TimerState.completed;
    _completedSessions++;
    
    // Get current date
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Initialize daily stats if not exists
    if (!_dailyStats.containsKey(dateKey)) {
      _dailyStats[dateKey] = {
        'completedSessions': 0,
        'completedWorkSessions': 0,
        'completedBreaks': 0,
        'taskStats': <String, dynamic>{},
      };
    }
    
    // Track session type statistics
    switch (_sessionType) {
      case SessionType.work:
        _completedWorkSessions++;
        _dailyStats[dateKey]!['completedWorkSessions'] = 
            (_dailyStats[dateKey]!['completedWorkSessions'] as int) + 1;
        
        // Track task statistics - use generated name if current task is empty
        String taskName = _currentTask.isNotEmpty ? _currentTask : _generateTaskName(now);
        _taskStats[taskName] = (_taskStats[taskName] ?? 0) + _totalTime ~/ 60;
        
        // Track daily task stats
        final dailyTaskStats = _dailyStats[dateKey]!['taskStats'] as Map<String, dynamic>;
        dailyTaskStats[taskName] = (dailyTaskStats[taskName] ?? 0) + _totalTime ~/ 60;
        break;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        _completedBreaks++;
        _dailyStats[dateKey]!['completedBreaks'] = 
            (_dailyStats[dateKey]!['completedBreaks'] as int) + 1;
        break;
    }
    
    _dailyStats[dateKey]!['completedSessions'] = 
        (_dailyStats[dateKey]!['completedSessions'] as int) + 1;
    
    // Save daily stats
    saveDailyStats();
    
    // Don't play sound or trigger auto-start for skipped sessions
    debugPrint('Session skipped - no sound or auto-start triggered');
    
    notifyListeners();
  }

  // Timer controls
  void start() {
    if (_state == TimerState.idle || _state == TimerState.paused) {
      _state = TimerState.running;
      _startTimer();
      notifyListeners();
    }
  }

  void pause() {
    if (_state == TimerState.running) {
      _state = TimerState.paused;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resume() {
    if (_state == TimerState.paused) {
      _state = TimerState.running;
      _startTimer();
      notifyListeners();
    }
  }

  void reset() {
    _timer?.cancel();
    _state = TimerState.idle;
    _remainingTime = _totalTime;
    notifyListeners();
  }

  void toggle() {
    if (_state == TimerState.idle) {
      start();
    } else if (_state == TimerState.running) {
      pause();
    } else if (_state == TimerState.paused) {
      resume();
    }
  }

  void _startTimer() {
    // Cancel any existing timer first to prevent multiple timers
    _timer?.cancel();
    
    debugPrint('Starting timer - Remaining time: $_remainingTime seconds');
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        debugPrint('Timer completed naturally');
        _complete();
      }
    });
  }

  void _complete() {
    _timer?.cancel();
    _state = TimerState.completed;
    _completedSessions++;
    
    // Get current date
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Initialize daily stats if not exists
    if (!_dailyStats.containsKey(dateKey)) {
      _dailyStats[dateKey] = {
        'completedSessions': 0,
        'completedWorkSessions': 0,
        'completedBreaks': 0,
        'taskStats': <String, int>{},
      };
    }
    
    // Track session type statistics
    switch (_sessionType) {
      case SessionType.work:
        _completedWorkSessions++;
        _dailyStats[dateKey]!['completedWorkSessions'] = 
            (_dailyStats[dateKey]!['completedWorkSessions'] as int) + 1;
        
        // Track task statistics - use generated name if current task is empty
        String taskName = _currentTask.isNotEmpty ? _currentTask : _generateTaskName(now);
        _taskStats[taskName] = (_taskStats[taskName] ?? 0) + _totalTime ~/ 60;
        
        // Track daily task stats
        final dailyTaskStats = _dailyStats[dateKey]!['taskStats'] as Map<String, dynamic>;
        dailyTaskStats[taskName] = (dailyTaskStats[taskName] ?? 0) + _totalTime ~/ 60;
        break;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        _completedBreaks++;
        _dailyStats[dateKey]!['completedBreaks'] = 
            (_dailyStats[dateKey]!['completedBreaks'] as int) + 1;
        break;
    }
    
    _dailyStats[dateKey]!['completedSessions'] = 
        (_dailyStats[dateKey]!['completedSessions'] as int) + 1;
    
    // Save daily stats
    saveDailyStats();
    
    _playCompletionSound();
    notifyListeners();
    
    // Auto-start next session if enabled
    _handleAutoStart();
  }

  void _handleAutoStart() {
    debugPrint('_handleAutoStart called - State: $_state, SessionType: $_sessionType');
    debugPrint('Auto-start settings - Breaks: $_autoStartBreaks, Work: $_autoStartWork');
    
    // Prevent multiple auto-start attempts
    if (_state != TimerState.completed) {
      debugPrint('Timer not in completed state, skipping auto-start');
      return;
    }
    
    // Add a flag to prevent multiple auto-start calls
    if (_autoStartInProgress) {
      debugPrint('Auto-start already in progress, skipping');
      return;
    }
    
    _autoStartInProgress = true;
    
    switch (_sessionType) {
      case SessionType.work:
        if (_autoStartBreaks) {
          debugPrint('Auto-starting break session');
          Future.delayed(const Duration(seconds: 2), () {
            debugPrint('Starting next session (break)');
            startNextSession();
            debugPrint('Auto-starting break timer');
            start();
            _autoStartInProgress = false;
          });
        } else {
          debugPrint('Auto-start breaks is disabled');
          _autoStartInProgress = false;
        }
        break;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        if (_autoStartWork) {
          debugPrint('Auto-starting work session');
          Future.delayed(const Duration(seconds: 2), () {
            debugPrint('Starting next session (work)');
            startNextSession();
            debugPrint('Auto-starting work timer');
            start();
            _autoStartInProgress = false;
          });
        } else {
          debugPrint('Auto-start work is disabled');
          _autoStartInProgress = false;
        }
        break;
    }
  }

  String _generateTaskName(DateTime dateTime) {
    // Format: "Work Session - Dec 15, 2:30 PM"
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    // Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    
    return 'Work Session - $month $day, $displayHour:$displayMinute $period';
  }

  Future<void> _playCompletionSound() async {
    // Play sound if enabled
    if (_soundEnabled) {
      try {
        switch (_sessionType) {
          case SessionType.work:
            await AudioService.playWorkCompleteSound();
            break;
          case SessionType.shortBreak:
            await AudioService.playBreakCompleteSound();
            break;
          case SessionType.longBreak:
            await AudioService.playLongBreakCompleteSound();
            break;
        }
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }
    
    // Trigger vibration if enabled
    debugPrint('Vibration setting: $_vibrationEnabled');
    if (_vibrationEnabled) {
      try {
        debugPrint('Attempting to trigger vibration...');
        await HapticFeedback.mediumImpact();
        debugPrint('Vibration triggered successfully for timer completion');
      } catch (e) {
        debugPrint('Error triggering vibration: $e');
        // Fallback to light impact if medium fails
        try {
          debugPrint('Trying fallback to light vibration...');
          await HapticFeedback.lightImpact();
          debugPrint('Fallback to light vibration successful');
        } catch (fallbackError) {
          debugPrint('Vibration fallback also failed: $fallbackError');
        }
      }
    } else {
      debugPrint('Vibration is disabled, skipping');
    }
  }

  // Statistics methods
  int getTotalWorkMinutes() {
    return _taskStats.values.fold(0, (sum, minutes) => sum + minutes);
  }

  String getMostProductiveTask() {
    if (_taskStats.isEmpty) return 'No tasks yet';
    return _taskStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  void resetStats() {
    _completedSessions = 0;
    _completedWorkSessions = 0;
    _completedBreaks = 0;
    _taskStats.clear();
    _dailyStats.clear();
    notifyListeners();
  }

  // Get stats for a specific date
  Map<String, dynamic> getStatsForDate(String dateKey) {
    return _dailyStats[dateKey] ?? {
      'completedSessions': 0,
      'completedWorkSessions': 0,
      'completedBreaks': 0,
      'taskStats': <String, int>{},
    };
  }

  // Get today's stats
  Map<String, dynamic> getTodayStats() {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return getStatsForDate(dateKey);
  }

  // Get available dates
  List<String> getAvailableDates() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final dates = _dailyStats.keys.toList();
    
    // Always include today's date
    if (!dates.contains(todayKey)) {
      dates.add(todayKey);
    }
    
    // Sort newest first
    dates.sort((a, b) => b.compareTo(a));
    
    return dates;
  }

  // Settings persistence
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = (prefs.getInt('workDuration') ?? 25) * 60;
    _shortBreakDuration = (prefs.getInt('shortBreakDuration') ?? 5) * 60;
    _longBreakDuration = (prefs.getInt('longBreakDuration') ?? 15) * 60;
    _sessionsUntilLongBreak = prefs.getInt('sessionsBeforeLongBreak') ?? 4;
    _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
    _autoStartWork = prefs.getBool('autoStartWork') ?? false;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    
    // Load daily statistics
    final dailyStatsJson = prefs.getString('dailyStats');
    if (dailyStatsJson != null) {
      try {
        final Map<String, dynamic> loadedStats = Map<String, dynamic>.from(
          jsonDecode(dailyStatsJson) as Map,
        );
        _dailyStats = Map<String, Map<String, dynamic>>.from(
          loadedStats.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map))),
        );
      } catch (e) {
        debugPrint('Error loading daily stats: $e');
      }
    }
    
    // Add sample data for demonstration if no stats exist
    if (_dailyStats.isEmpty) {
      _addSampleData();
    }
    
    // Update current session if needed
    if (_sessionType == SessionType.work) {
      _totalTime = _workDuration;
      _remainingTime = _workDuration;
    } else if (_sessionType == SessionType.shortBreak) {
      _totalTime = _shortBreakDuration;
      _remainingTime = _shortBreakDuration;
    } else if (_sessionType == SessionType.longBreak) {
      _totalTime = _longBreakDuration;
      _remainingTime = _longBreakDuration;
    }
    
    notifyListeners();
  }

  // Reload settings and update current session if needed
  Future<void> reloadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final oldWorkDuration = _workDuration;
    final oldShortBreakDuration = _shortBreakDuration;
    final oldLongBreakDuration = _longBreakDuration;
    
    _workDuration = (prefs.getInt('workDuration') ?? 25) * 60;
    _shortBreakDuration = (prefs.getInt('shortBreakDuration') ?? 5) * 60;
    _longBreakDuration = (prefs.getInt('longBreakDuration') ?? 15) * 60;
    _sessionsUntilLongBreak = prefs.getInt('sessionsBeforeLongBreak') ?? 4;
    _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
    _autoStartWork = prefs.getBool('autoStartWork') ?? false;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    
    // Update current session times if the session type duration changed
    if (_sessionType == SessionType.work && _workDuration != oldWorkDuration) {
      if (_state == TimerState.idle) {
        _totalTime = _workDuration;
        _remainingTime = _workDuration;
      }
    } else if (_sessionType == SessionType.shortBreak && _shortBreakDuration != oldShortBreakDuration) {
      if (_state == TimerState.idle) {
        _totalTime = _shortBreakDuration;
        _remainingTime = _shortBreakDuration;
      }
    } else if (_sessionType == SessionType.longBreak && _longBreakDuration != oldLongBreakDuration) {
      if (_state == TimerState.idle) {
        _totalTime = _longBreakDuration;
        _remainingTime = _longBreakDuration;
      }
    }
    
    notifyListeners();
  }

  // Add sample data for demonstration
  void _addSampleData() {
    final now = DateTime.now();
    
    // Add data for yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    _dailyStats[yesterdayKey] = {
      'completedSessions': 8,
      'completedWorkSessions': 6,
      'completedBreaks': 2,
      'taskStats': {
        'Coding': 180,
        'Reading': 60,
        'Exercise': 30,
      },
    };
    
    // Add data for 2 days ago
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final twoDaysAgoKey = '${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}';
    _dailyStats[twoDaysAgoKey] = {
      'completedSessions': 6,
      'completedWorkSessions': 4,
      'completedBreaks': 2,
      'taskStats': {
        'Writing': 120,
        'Planning': 60,
      },
    };
    
    // Add data for 3 days ago
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final threeDaysAgoKey = '${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}';
    _dailyStats[threeDaysAgoKey] = {
      'completedSessions': 10,
      'completedWorkSessions': 8,
      'completedBreaks': 2,
      'taskStats': {
        'Design': 240,
        'Research': 90,
        'Meetings': 60,
      },
    };
    
    debugPrint('Added sample data for calendar demonstration');
  }

  // Save daily statistics
  Future<void> saveDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final dailyStatsJson = jsonEncode(_dailyStats);
      await prefs.setString('dailyStats', dailyStatsJson);
    } catch (e) {
      debugPrint('Error saving daily stats: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
