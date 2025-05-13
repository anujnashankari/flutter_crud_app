import 'package:sqflite/sqflite.dart';

import '../../../../../core/error/exceptions.dart';
import '../../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTaskById(String id);
  Future<void> saveTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> clearTasks();
  Future<List<TaskModel>> getUnsyncedTasks();
  Future<void> markTaskAsSynced(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Database database;
  
  TaskLocalDataSourceImpl({required this.database});
  
  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('tasks');
      return List.generate(maps.length, (i) {
        return TaskModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to get tasks from local database: ${e.toString()}');
    }
  }
  
  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw CacheException(message: 'Task not found in local database');
      }
      
      return TaskModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException(message: 'Failed to get task from local database: ${e.toString()}');
    }
  }
  
  @override
  Future<void> saveTask(TaskModel task) async {
    try {
      await database.insert(
        'tasks',
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save task to local database: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await database.update(
        'tasks',
        task.toJson(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to update task in local database: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteTask(String id) async {
    try {
      await database.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to delete task from local database: ${e.toString()}');
    }
  }
  
  @override
  Future<void> clearTasks() async {
    try {
      await database.delete('tasks');
    } catch (e) {
      throw CacheException(message: 'Failed to clear tasks from local database: ${e.toString()}');
    }
  }
  
  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'tasks',
        where: 'syncStatus != ?',
        whereArgs: ['synced'],
      );
      
      return List.generate(maps.length, (i) {
        return TaskModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to get unsynced tasks from local database: ${e.toString()}');
    }
  }
  
  @override
  Future<void> markTaskAsSynced(String id) async {
    try {
      await database.update(
        'tasks',
        {'syncStatus': 'synced'},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to mark task as synced in local database: ${e.toString()}');
    }
  }
}
