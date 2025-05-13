import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task.dart';
import 'priority_badge.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(TaskStatus) onStatusChanged;
  final VoidCallback onDelete;
  
  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onStatusChanged,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    PriorityBadge(priority: task.priority),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Updated ${DateFormatter.timeAgo(task.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    DropdownButton<TaskStatus>(
                      value: task.status,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (TaskStatus? newValue) {
                        if (newValue != null) {
                          onStatusChanged(newValue);
                        }
                      },
                      items: TaskStatus.values.map((TaskStatus status) {
                        return DropdownMenuItem<TaskStatus>(
                          value: status,
                          child: Text(_getStatusText(status)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
}
