import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final Function(TaskPriority) onPriorityChanged;
  
  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityOption(
          context,
          TaskPriority.low,
          'Low',
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildPriorityOption(
          context,
          TaskPriority.medium,
          'Medium',
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildPriorityOption(
          context,
          TaskPriority.high,
          'High',
          Colors.red,
        ),
      ],
    );
  }
  
  Widget _buildPriorityOption(
    BuildContext context,
    TaskPriority priority,
    String label,
    Color color,
  ) {
    final isSelected = selectedPriority == priority;
    
    return Expanded(
      child: InkWell(
        onTap: () => onPriorityChanged(priority),
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
