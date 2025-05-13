import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  
  const PriorityBadge({
    Key? key,
    required this.priority,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getPriorityText(),
        style: TextStyle(
          color: _getPriorityColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  String _getPriorityText() {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      default:
        return 'Unknown';
    }
  }
  
  Color _getPriorityColor() {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
