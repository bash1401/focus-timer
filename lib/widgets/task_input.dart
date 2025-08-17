import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final String currentTask;
  final Function(String) onTaskChanged;

  const TaskInput({
    super.key,
    required this.currentTask,
    required this.onTaskChanged,
  });

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTask);
  }

  @override
  void didUpdateWidget(TaskInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTask != widget.currentTask) {
      _controller.text = widget.currentTask;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 1), // Minimal margin
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Task input field - ultra compact
          Container(
            height: 36, // Fixed height for input field
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Minimal padding
            child: Row(
              children: [
                Icon(
                  Icons.task_alt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 14, // Increased icon size
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'What are you working on?',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4), // Minimal padding
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 14, // Increased text size
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14, // Increased text size
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        widget.onTaskChanged(value.trim());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
