import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../features/task/data/datasources/local/task_local_data_source.dart';
import '../../features/task/data/datasources/remote/task_remote_data_source.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/usecases/create_task.dart';
import '../../features/task/domain/usecases/delete_task.dart';
import '../../features/task/domain/usecases/get_tasks.dart';
import '../../features/task/domain/usecases/update_task.dart';
import '../../features/task/presentation/bloc/task/task_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  
  // Database
  final database = await openDatabase(
    join(await getDatabasesPath(), 'task_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, description TEXT, status TEXT, priority TEXT, createdAt TEXT, updatedAt TEXT, syncStatus TEXT)',
      );
    },
    version: 1,
  );
  getIt.registerSingleton<Database>(database);
  
  // Dio client
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com', // Replace with your API URL
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  // Add interceptors for logging, auth, etc.
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  
  getIt.registerSingleton<Dio>(dio);
  
  // Data sources
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(database: getIt<Database>()),
  );
  
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  
  // Repositories
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: getIt<TaskLocalDataSource>(),
      remoteDataSource: getIt<TaskRemoteDataSource>(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton(() => GetTasks(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => CreateTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => UpdateTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => DeleteTask(getIt<TaskRepository>()));
  
  // BLoCs
  getIt.registerFactory(
    () => TaskBloc(
      getTasks: getIt<GetTasks>(),
      createTask: getIt<CreateTask>(),
      updateTask: getIt<UpdateTask>(),
      deleteTask: getIt<DeleteTask>(),
    ),
  );
}
