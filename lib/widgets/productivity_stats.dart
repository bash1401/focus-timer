import 'package:flutter/material.dart';
import 'date_picker_button.dart';

class ProductivityStats extends StatefulWidget {
  final int completedSessions;
  final int completedWorkSessions;
  final int completedBreaks;
  final Map<String, int> taskStats;
  final Map<String, Map<String, dynamic>> dailyStats;
  final List<String> availableDates;
  final VoidCallback onResetStats;
  final VoidCallback? onClose;

  const ProductivityStats({
    super.key,
    required this.completedSessions,
    required this.completedWorkSessions,
    required this.completedBreaks,
    required this.taskStats,
    required this.dailyStats,
    required this.availableDates,
    required this.onResetStats,
    this.onClose,
  });

  @override
  State<ProductivityStats> createState() => _ProductivityStatsState();
}

class _ProductivityStatsState extends State<ProductivityStats> {
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    // Default to today
    final now = DateTime.now();
    selectedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> get currentStats {
    return widget.dailyStats[selectedDate] ?? {
      'completedSessions': 0,
      'completedWorkSessions': 0,
      'completedBreaks': 0,
      'taskStats': <String, int>{},
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = currentStats;
    final dailyTaskStats = Map<String, int>.from(stats['taskStats'] ?? {});
    final totalWorkMinutes = dailyTaskStats.values.fold(0, (sum, minutes) => sum + minutes);
    final mostProductiveTask = dailyTaskStats.isNotEmpty 
        ? dailyTaskStats.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'No tasks yet';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Picker
          DatePickerButton(
            selectedDate: selectedDate,
            availableDates: widget.availableDates,
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Header with actions
          Row(
            children: [
              Expanded(
                child: Text(
                  'Productivity Stats',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onResetStats,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                tooltip: 'Reset Stats',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Session counts - Always in a row for better layout
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.work_rounded,
                  title: 'Work Sessions',
                  value: (stats['completedWorkSessions'] ?? 0).toString(),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.coffee_rounded,
                  title: 'Breaks',
                  value: (stats['completedBreaks'] ?? 0).toString(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer_rounded,
                  title: 'Total Time',
                  value: '${totalWorkMinutes}m',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Most productive task
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Productive Task',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mostProductiveTask,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (dailyTaskStats.isNotEmpty) ...[
            const SizedBox(height: 24),
            
            // Task breakdown header
            Text(
              'Task Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Task breakdown list
            ...dailyTaskStats.entries.map((entry) {
              final taskName = entry.key;
              final minutes = entry.value;
              final percentage = totalWorkMinutes > 0 ? (minutes / totalWorkMinutes * 100).round() : 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            taskName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$minutes minutes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
