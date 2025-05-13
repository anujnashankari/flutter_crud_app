part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchTasksEvent extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final Task task;
  
  const CreateTaskEvent(this.task);
  
  @override
  List<Object> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  
  const UpdateTaskEvent(this.task);
  
  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String id;
  
  const DeleteTaskEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class FilterTasksEvent extends TaskEvent {
  final TaskStatus? status;
  final TaskPriority? priority;
  
  const FilterTasksEvent({this.status, this.priority});
  
  @override
  List<Object?> get props => [status, priority];
}

class SearchTasksEvent extends TaskEvent {
  final String query;
  
  const SearchTasksEvent(this.query);
  
  @override
  List<Object> get props => [query];
}
