import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../bloc/task/task_bloc.dart';
import '../widgets/priority_selector.dart';
import '../widgets/status_selector.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  
  const TaskDetailScreen({Key? key, this.task}) : super(key: key);
  
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskStatus _status;
  late TaskPriority _priority;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? TaskStatus.todo;
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          status: _status,
          priority: _priority,
          updatedAt: DateTime.now(),
        );
        
        context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
      } else {
        final newTask = Task.create(
          title: _titleController.text,
          description: _descriptionController.text,
          status: _status,
          priority: _priority,
        );
        
        context.read<TaskBloc>().add(CreateTaskEvent(newTask));
      }
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Create Task'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTaskEvent(widget.task!.id));
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Close detail screen
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              StatusSelector(
                selectedStatus: _status,
                onStatusChanged: (status) {
                  setState(() {
                    _status = status;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              PrioritySelector(
                selectedPriority: _priority,
                onPriorityChanged: (priority) {
                  setState(() {
                    _priority = priority;
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(_isEditing ? 'Update Task' : 'Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
