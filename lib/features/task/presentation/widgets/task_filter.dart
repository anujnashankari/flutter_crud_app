import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../bloc/task/task_bloc.dart';

class TaskFilter extends StatefulWidget {
  const TaskFilter({Key? key}) : super(key: key);

  @override
  State<TaskFilter> createState() => _TaskFilterState();
}

class _TaskFilterState extends State<TaskFilter> {
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'All',
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
              ),
              ...TaskStatus.values.map((status) {
                return _buildFilterChip(
                  label: _getStatusText(status),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'All',
                selected: _selectedPriority == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = null;
                  });
                },
              ),
              ...TaskPriority.values.map((priority) {
                return _buildFilterChip(
                  label: _getPriorityText(priority),
                  selected: _selectedPriority == priority,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? priority : null;
                    });
                  },
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedPriority = null;
                  });
                },
                child: const Text('Clear All'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                    FilterTasksEvent(
                      status: _selectedStatus,
                      priority: _selectedPriority,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
  
  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      default:
        return 'Unknown';
    }
  }
  
  String _getPriorityText(TaskPriority priority) {
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
}
