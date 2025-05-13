import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum TaskStatus { todo, inProgress, done }
enum TaskPriority { low, medium, high }

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Task.create({
    required String title,
    required String description,
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
  }) {
    final now = DateTime.now();
    return Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: status,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    createdAt,
    updatedAt,
  ];
}
