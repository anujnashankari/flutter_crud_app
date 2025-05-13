import 'package:dio/dio.dart';

import '../../../../../core/error/exceptions.dart';
import '../../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTaskById(String id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  
  TaskRemoteDataSourceImpl({required this.dio});
  
  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await dio.get('/tasks');
      
      if (response.statusCode == 200) {
        final List<dynamic> taskList = response.data;
        return taskList.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to load tasks from server');
      }
    } on DioException catch (e) {
      throw ServerException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
  
  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await dio.get('/tasks/$id');
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to load task from server');
      }
    } on DioException catch (e) {
      throw ServerException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
  
  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await dio.post(
        '/tasks',
        data: task.toJson(),
      );
      
      if (response.statusCode == 201) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to create task on server');
      }
    } on DioException catch (e) {
      throw ServerException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
  
  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await dio.put(
        '/tasks/${task.id}',
        data: task.toJson(),
      );
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to update task on server');
      }
    } on DioException catch (e) {
      throw ServerException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteTask(String id) async {
    try {
      final response = await dio.delete('/tasks/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete task from server');
      }
    } on DioException catch (e) {
      throw ServerException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
