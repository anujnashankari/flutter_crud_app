import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/task/task_bloc.dart';
import '../widgets/connectivity_banner.dart';
import '../widgets/empty_task_list.dart';
import '../widgets/task_filter.dart';
import '../widgets/task_list_item.dart';
import '../widgets/task_search_bar.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const TaskFilter(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, state) {
              if (state is ConnectivityDisconnected) {
                return const ConnectivityBanner(
                  message: 'You are offline. Changes will be synced when you reconnect.',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const TaskSearchBar(),
          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TaskInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded) {
                  if (state.tasks.isEmpty) {
                    return const EmptyTaskList();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TaskBloc>().add(FetchTasksEvent());
                    },
                    child: ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return TaskListItem(
                          task: task,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(task: task),
                              ),
                            );
                          },
                          onStatusChanged: (newStatus) {
                            final updatedTask = task.copyWith(
                              status: newStatus,
                              updatedAt: DateTime.now(),
                            );
                            context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
                          },
                          onDelete: () {
                            context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                          },
                        );
                      },
                    ),
                  );
                } else if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TaskBloc>().add(FetchTasksEvent());
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskDetailScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
