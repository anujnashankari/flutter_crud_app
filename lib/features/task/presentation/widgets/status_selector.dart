import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class StatusSelector extends StatelessWidget {
  final TaskStatus selectedStatus;
  final Function(TaskStatus) onStatusChanged;
  
  const StatusSelector({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatusOption(
          context,
          TaskStatus.todo,
          'To Do',
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildStatusOption(
          context,
          TaskStatus.inProgress,
          'In Progress',
          Colors.amber,
        ),
        const SizedBox(width: 12),
        _buildStatusOption(
          context,
          TaskStatus.done,
          'Done',
          Colors.green,
        ),
      ],
    );
  }
  
  Widget _buildStatusOption(
    BuildContext context,
    TaskStatus status,
    String label,
    Color color,
  ) {
    final isSelected = selectedStatus == status;
    
    return Expanded(
      child: InkWell(
        onTap: () => onStatusChanged(status),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.5),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
