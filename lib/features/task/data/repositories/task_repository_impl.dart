import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_data_source.dart';
import '../datasources/remote/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  
  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      // Try to get tasks from remote
      try {
        final remoteTasks = await remoteDataSource.getTasks();
        
        // Update local cache
        for (var task in remoteTasks) {
          await localDataSource.saveTask(task);
        }
        
        return Right(remoteTasks);
      } on ServerException {
        // If remote fails, get from local
        final localTasks = await localDataSource.getTasks();
        return Right(localTasks);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      // Try to get task from remote
      try {
        final remoteTask = await remoteDataSource.getTaskById(id);
        
        // Update local cache
        await localDataSource.saveTask(remoteTask);
        
        return Right(remoteTask);
      } on ServerException {
        // If remote fails, get from local
        final localTask = await localDataSource.getTaskById(id);
        return Right(localTask);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task, syncStatus: 'pending_create');
      
      // Save to local first (optimistic update)
      await localDataSource.saveTask(taskModel);
      
      // Try to create on remote
      try {
        final remoteTask = await remoteDataSource.createTask(taskModel);
        
        // Update local with synced status
        await localDataSource.saveTask(remoteTask);
        
        return Right(remoteTask);
      } on ServerException catch (e) {
        // Keep local version with pending status
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task, syncStatus: 'pending_update');
      
      // Update local first (optimistic update)
      await localDataSource.updateTask(taskModel);
      
      // Try to update on remote
      try {
        final remoteTask = await remoteDataSource.updateTask(taskModel);
        
        // Update local with synced status
        await localDataSource.saveTask(remoteTask);
        
        return Right(remoteTask);
      } on ServerException catch (e) {
        // Keep local version with pending status
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      // Get the task first to mark it as pending delete
      final taskResult = await getTaskById(id);
      
      return taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          final taskModel = TaskModel.fromEntity(task, syncStatus: 'pending_delete');
          
          // Update local first (optimistic update)
          await localDataSource.updateTask(taskModel);
          
          // Try to delete on remote
          try {
            await remoteDataSource.deleteTask(id);
            
            // Delete from local if successful
            await localDataSource.deleteTask(id);
            
            return const Right(null);
          } on ServerException catch (e) {
            // Keep local version with pending status
            return Left(ServerFailure(message: e.message));
          }
        },
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> syncTasks() async {
    try {
      final unsyncedTasks = await localDataSource.getUnsyncedTasks();
      
      for (var task in unsyncedTasks) {
        if (task.syncStatus == 'pending_create') {
          try {
            final remoteTask = await remoteDataSource.createTask(task);
            await localDataSource.saveTask(remoteTask);
          } catch (_) {
            // Keep trying other tasks
            continue;
          }
        } else if (task.syncStatus == 'pending_update') {
          try {
            final remoteTask = await remoteDataSource.updateTask(task);
            await localDataSource.saveTask(remoteTask);
          } catch (_) {
            // Keep trying other tasks
            continue;
          }
        } else if (task.syncStatus == 'pending_delete') {
          try {
            await remoteDataSource.deleteTask(task.id);
            await localDataSource.deleteTask(task.id);
          } catch (_) {
            // Keep trying other tasks
            continue;
          }
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
