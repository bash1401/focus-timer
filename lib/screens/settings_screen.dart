import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;
  
  // Timer durations (in minutes)
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _sessionsBeforeLongBreak = 4;
  
  // Sound settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // Auto-start settings
  bool _autoStartBreaks = true;
  bool _autoStartWork = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _workDuration = _prefs.getInt('workDuration') ?? 25;
      _shortBreakDuration = _prefs.getInt('shortBreakDuration') ?? 5;
      _longBreakDuration = _prefs.getInt('longBreakDuration') ?? 15;
      _sessionsBeforeLongBreak = _prefs.getInt('sessionsBeforeLongBreak') ?? 4;
      _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = _prefs.getBool('vibrationEnabled') ?? true;
      _autoStartBreaks = _prefs.getBool('autoStartBreaks') ?? true;
      _autoStartWork = _prefs.getBool('autoStartWork') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setInt('workDuration', _workDuration);
    await _prefs.setInt('shortBreakDuration', _shortBreakDuration);
    await _prefs.setInt('longBreakDuration', _longBreakDuration);
    await _prefs.setInt('sessionsBeforeLongBreak', _sessionsBeforeLongBreak);
    await _prefs.setBool('soundEnabled', _soundEnabled);
    await _prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await _prefs.setBool('autoStartBreaks', _autoStartBreaks);
    await _prefs.setBool('autoStartWork', _autoStartWork);
  }

  void _setRecommendedTimer() {
    setState(() {
      // Set to recommended Pomodoro technique values
      _workDuration = 25; // 25 minutes
      _shortBreakDuration = 5; // 5 minutes
      _longBreakDuration = 15; // 15 minutes
      _sessionsBeforeLongBreak = 4; // Long break after 4 work sessions
    });
    _saveSettings();
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Timer set to recommended Pomodoro technique!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Duration Settings
            _buildSectionHeader('Timer Durations'),
            _buildDurationSetting(
              'Work Session',
              _workDuration,
              (value) {
                setState(() => _workDuration = value);
                _saveSettings();
              },
              Icons.work,
            ),
            _buildDurationSetting(
              'Short Break',
              _shortBreakDuration,
              (value) {
                setState(() => _shortBreakDuration = value);
                _saveSettings();
              },
              Icons.coffee,
            ),
            _buildDurationSetting(
              'Long Break',
              _longBreakDuration,
              (value) {
                setState(() => _longBreakDuration = value);
                _saveSettings();
              },
              Icons.bedtime,
            ),
            _buildDurationSetting(
              'Sessions before Long Break',
              _sessionsBeforeLongBreak,
              (value) {
                setState(() => _sessionsBeforeLongBreak = value);
                _saveSettings();
              },
              Icons.repeat,
            ),
            
            const SizedBox(height: 16),
            
            // Recommended Timer Button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _setRecommendedTimer,
                icon: const Icon(Icons.recommend),
                label: const Text('Set Recommended Timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sound & Vibration Settings
            _buildSectionHeader('Notifications'),
            _buildSwitchSetting(
              'Sound',
              _soundEnabled,
              (value) {
                setState(() => _soundEnabled = value);
                _saveSettings();
              },
              Icons.volume_up,
            ),
            _buildSwitchSetting(
              'Vibration',
              _vibrationEnabled,
              (value) {
                setState(() => _vibrationEnabled = value);
                _saveSettings();
              },
              Icons.vibration,
            ),
            
            const SizedBox(height: 24),
            
            // Auto-start Settings
            _buildSectionHeader('Auto-start'),
            _buildSwitchSetting(
              'Auto-start Breaks',
              _autoStartBreaks,
              (value) {
                setState(() => _autoStartBreaks = value);
                _saveSettings();
              },
              Icons.play_circle_outline,
            ),
            _buildSwitchSetting(
              'Auto-start Work Sessions',
              _autoStartWork,
              (value) {
                setState(() => _autoStartWork = value);
                _saveSettings();
              },
              Icons.play_circle_filled,
            ),
            
            const SizedBox(height: 40),
            
            // Support Section
            _buildSectionHeader('Support'),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    final url = Uri.parse('https://www.bashtech.info/');
                    debugPrint('Attempting to launch: $url');
                    
                    final canLaunch = await canLaunchUrl(url);
                    debugPrint('Can launch URL: $canLaunch');
                    
                    if (canLaunch) {
                      final launched = await launchUrl(
                        url, 
                        mode: LaunchMode.externalApplication,
                      );
                      debugPrint('URL launched successfully: $launched');
                    } else {
                      debugPrint('Could not launch URL: $url');
                      // Try alternative approach
                      await launchUrl(url);
                    }
                  } catch (e) {
                    debugPrint('Error launching URL: $e');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.apps,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Apps by BashTech',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Discover productivity & privacy apps',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    final url = Uri.parse('https://buymeacoffee.com/bash14');
                    debugPrint('Attempting to launch: $url');
                    
                    final canLaunch = await canLaunchUrl(url);
                    debugPrint('Can launch URL: $canLaunch');
                    
                    if (canLaunch) {
                      final launched = await launchUrl(
                        url, 
                        mode: LaunchMode.externalApplication,
                      );
                      debugPrint('URL launched successfully: $launched');
                    } else {
                      debugPrint('Could not launch URL: $url');
                      // Try alternative approach
                      await launchUrl(url);
                    }
                  } catch (e) {
                    debugPrint('Error launching URL: $e');
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.coffee,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buy Me a Coffee',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Support the development',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App Version at the bottom
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus Timer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }



  Widget _buildDurationSetting(
    String title,
    int value,
    Function(int) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$value minutes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _showNumberPicker(context, title, value, onChanged);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNumberPicker(BuildContext context, String title, int currentValue, Function(int) onChanged) {
    int selectedValue = currentValue;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1 * value),
                      blurRadius: 20,
                      offset: Offset(0, -5 * value),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated handle
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, handleValue, child) {
                        return Container(
                          margin: EdgeInsets.only(top: 8 * handleValue),
                          width: 40 * handleValue,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3 * handleValue),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Animated header
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, headerValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - headerValue)),
                                child: Opacity(
                                  opacity: headerValue,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Set $title Duration',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        icon: Icon(
                                          Icons.close,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          // Animated picker container
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, pickerValue, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * pickerValue),
                                child: Opacity(
                                  opacity: pickerValue,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2 * pickerValue),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1 * pickerValue),
                                          blurRadius: 10 * pickerValue,
                                          offset: Offset(0, 2 * pickerValue),
                                        ),
                                      ],
                                    ),
                                    child: ListWheelScrollView.useDelegate(
                                      itemExtent: 50,
                                      diameterRatio: 1.5,
                                      physics: const FixedExtentScrollPhysics(),
                                      controller: FixedExtentScrollController(initialItem: currentValue - 1),
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          selectedValue = index + 1; // Start from 1 minute
                                        });
                                      },
                                      childDelegate: ListWheelChildBuilderDelegate(
                                        builder: (context, index) {
                                          final value = index + 1;
                                          final isSelected = value == selectedValue;
                                          
                                          return TweenAnimationBuilder<double>(
                                            duration: Duration(milliseconds: 200 + (index * 10)),
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            builder: (context, itemValue, child) {
                                              return Transform.translate(
                                                offset: Offset(0, 20 * (1 - itemValue)),
                                                child: Opacity(
                                                  opacity: itemValue,
                                                  child: Center(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                                      child: AnimatedDefaultTextStyle(
                                                        duration: const Duration(milliseconds: 200),
                                                        style: TextStyle(
                                                          fontSize: isSelected ? 24 : 18,
                                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                          color: isSelected 
                                                              ? Theme.of(context).colorScheme.primary
                                                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                                        ),
                                                        child: Text('$value min'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        childCount: 60, // 1 to 60 minutes
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          // Animated buttons
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, buttonValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - buttonValue)),
                                child: Opacity(
                                  opacity: buttonValue,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          child: TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              onChanged(selectedValue);
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              elevation: 4 * buttonValue,
                                            ),
                                            child: const Text('Save'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }


}
