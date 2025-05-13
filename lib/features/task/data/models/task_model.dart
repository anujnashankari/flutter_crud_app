import 'dart:convert';

import '../../domain/entities/task.dart';

class TaskModel extends Task {
  final String syncStatus;
  
  const TaskModel({
    required String id,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.syncStatus,
  }) : super(
          id: id,
          title: title,
          description: description,
          status: status,
          priority: priority,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
  
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: _mapStringToTaskStatus(json['status']),
      priority: _mapStringToTaskPriority(json['priority']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      syncStatus: json['syncStatus'] ?? 'synced',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }
  
  factory TaskModel.fromEntity(Task task, {String syncStatus = 'synced'}) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      syncStatus: syncStatus,
    );
  }
  
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
  
  static TaskStatus _mapStringToTaskStatus(String status) {
    switch (status) {
      case 'todo':
        return TaskStatus.todo;
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
  
  static TaskPriority _mapStringToTaskPriority(String priority) {
    switch (priority) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }
  
  @override
  List<Object?> get props => [...super.props, syncStatus];
}
