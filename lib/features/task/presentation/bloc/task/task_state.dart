part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> allTasks;
  final String searchQuery;
  
  const TaskLoaded({
    required this.tasks,
    List<Task>? allTasks,
    this.searchQuery = '',
  }) : allTasks = allTasks ?? tasks;
  
  @override
  List<Object?> get props => [tasks, allTasks, searchQuery];
}

class TaskError extends TaskState {
  final String message;
  
  const TaskError({required this.message});
  
  @override
  List<Object> get props => [message];
}
