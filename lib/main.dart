import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/task/presentation/bloc/connectivity/connectivity_bloc.dart';
import 'features/task/presentation/bloc/task/task_bloc.dart';
import 'features/task/presentation/screens/task_list_screen.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service locator
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => getIt<TaskBloc>()..add(FetchTasksEvent()),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc(getIt<Connectivity>())..add(InitializeConnectivity()),
        ),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const TaskListScreen(),
      ),
    );
  }
}
