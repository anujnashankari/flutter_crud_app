import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/usecases/create_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/get_tasks.dart';
import '../../../domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final CreateTask createTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  
  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<FilterTasksEvent>(_onFilterTasks);
    on<SearchTasksEvent>(_onSearchTasks);
  }
  
  Future<void> _onFetchTasks(
    FetchTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    
    final result = await getTasks();
    
    result.fold(
      (failure) => emit(TaskError(message: failure.message)),
      (tasks) => emit(TaskLoaded(tasks: tasks)),
    );
  }
  
  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is TaskLoaded) {
      // Optimistic update
      final updatedTasks = List<Task>.from(currentState.tasks)..add(event.task);
      emit(TaskLoaded(tasks: updatedTasks));
      
      final result = await createTask(event.task);
      
      result.fold(
        (failure) {
          // Revert optimistic update
          emit(TaskError(message: failure.message));
          emit(TaskLoaded(tasks: currentState.tasks));
        },
        (task) {
          // Update with server response if needed
          final tasks = List<Task>.from(currentState.tasks);
          final index = tasks.indexWhere((t) => t.id == task.id);
          
          if (index >= 0) {
            tasks[index] = task;
          } else {
            tasks.add(task);
          }
          
          emit(TaskLoaded(tasks: tasks));
        },
      );
    }
  }
  
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is TaskLoaded) {
      // Optimistic update
      final tasks = List<Task>.from(currentState.tasks);
      final index = tasks.indexWhere((task) => task.id == event.task.id);
      
      if (index >= 0) {
        tasks[index] = event.task;
        emit(TaskLoaded(tasks: tasks));
        
        final result = await updateTask(event.task);
        
        result.fold(
          (failure) {
            // Revert optimistic update
            emit(TaskError(message: failure.message));
            emit(TaskLoaded(tasks: currentState.tasks));
          },
          (task) {
            // Update with server response if needed
            final updatedTasks = List<Task>.from(currentState.tasks);
            final updatedIndex = updatedTasks.indexWhere((t) => t.id == task.id);
            
            if (updatedIndex >= 0) {
              updatedTasks[updatedIndex] = task;
            }
            
            emit(TaskLoaded(tasks: updatedTasks));
          },
        );
      }
    }
  }
  
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is TaskLoaded) {
      // Optimistic update
      final tasks = List<Task>.from(currentState.tasks);
      final deletedTask = tasks.firstWhere((task) => task.id == event.id);
      tasks.removeWhere((task) => task.id == event.id);
      
      emit(TaskLoaded(tasks: tasks));
      
      final result = await deleteTask(event.id);
      
      result.fold(
        (failure) {
          // Revert optimistic update
          emit(TaskError(message: failure.message));
          final revertedTasks = List<Task>.from(tasks)..add(deletedTask);
          emit(TaskLoaded(tasks: revertedTasks));
        },
        (_) {
          // Already updated optimistically
        },
      );
    }
  }
  
  void _onFilterTasks(
    FilterTasksEvent event,
    Emitter<TaskState> emit,
  ) {
    final currentState = state;
    
    if (currentState is TaskLoaded) {
      List<Task> filteredTasks = List<Task>.from(currentState.allTasks);
      
      if (event.status != null) {
        filteredTasks = filteredTasks.where((task) => task.status == event.status).toList();
      }
      
      if (event.priority != null) {
        filteredTasks = filteredTasks.where((task) => task.priority == event.priority).toList();
      }
      
      emit(TaskLoaded(
        tasks: filteredTasks,
        allTasks: currentState.allTasks,
        searchQuery: currentState.searchQuery,
      ));
    }
  }
  
  void _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TaskState> emit,
  ) {
    final currentState = state;
    
    if (currentState is TaskLoaded) {
      if (event.query.isEmpty) {
        emit(TaskLoaded(
          tasks: currentState.allTasks,
          allTasks: currentState.allTasks,
          searchQuery: '',
        ));
      } else {
        final searchResults = currentState.allTasks.where((task) {
          return task.title.toLowerCase().contains(event.query.toLowerCase()) ||
              task.description.toLowerCase().contains(event.query.toLowerCase());
        }).toList();
        
        emit(TaskLoaded(
          tasks: searchResults,
          allTasks: currentState.allTasks,
          searchQuery: event.query,
        ));
      }
    }
  }
}
