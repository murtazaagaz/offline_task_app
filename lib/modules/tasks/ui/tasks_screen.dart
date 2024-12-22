import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_task_app/models/task_model.dart';
import 'package:offline_task_app/modules/tasks/ui/add_task_screen.dart';
import 'package:offline_task_app/modules/tasks/network_bloc/network_bloc.dart';
import 'package:offline_task_app/modules/tasks/network_bloc/network_state.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_bloc.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_event.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_state.dart';
import 'package:offline_task_app/modules/tasks/ui/task_detail_screen.dart';

class TaskManagementApp extends StatefulWidget {
  const TaskManagementApp({super.key});

  @override
  State<TaskManagementApp> createState() => _TaskManagementAppState();
}

class _TaskManagementAppState extends State<TaskManagementApp> {
  final TaskBloc _taskBloc = TaskBloc();
  late final StreamSubscription<Uri> sub;
  @override
  void initState() {
    super.initState();
    final appLinks = AppLinks(); // AppLinks is singleton

// Subscribe to all events (initial link and further)
    sub = appLinks.uriLinkStream.listen((uri) {
      final double id = double.tryParse(uri.queryParameters['id'] ?? '0') ?? 0;
      _taskBloc.add(LoadDetailEvent(id));
    });
  }

  @override
  void dispose() {
    sub.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _taskBloc..add(LoadTasksEvent())),
        BlocProvider(create: (context) => NetworkBloc()),
      ],
      child: MaterialApp(
        title: 'Offline Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TaskListScreen(),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  Widget _taskListWidget(List<TaskModel> tasks) => ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => TaskDetailScreen(task)));
            },
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: SizedBox(
              height: 120,
              width: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: const Icon(Icons.edit),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddTaskScreen(
                                      isUpDate: true,
                                      taskModel: task,
                                    )),
                          );
                          if (result != null) {
                            // ignore: use_build_context_synchronously
                            context
                                .read<TaskBloc>()
                                .add(UpdateTaskEvent(result));
                          }
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        child: const Icon(Icons.delete),
                        onTap: () {
                          context
                              .read<TaskBloc>()
                              .add(DeleteTaskEvent(task.id));
                        },
                      ),
                    ],
                  ),
                  if (!task.isSynced) ...[
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Not Synced',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      );

  Widget _buildUi(TaskState state) {
    if (state is TaskLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TaskLoaded) {
      final tasks = state.tasks;
      return tasks.isEmpty
          ? const Center(child: Text('No tasks available'))
          : Expanded(child: _taskListWidget(tasks));
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkBloc, NetworkState>(
        listener: (context, state) {
          if (state is NetworkOnline) {
            context.read<TaskBloc>().add(SyncTasksEvent());
          }
        },
        child: BlocConsumer<TaskBloc, TaskState>(listener: (context, state) {
          if (state is TaskDetailLoaded) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(state.task)));
          }
        }, builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tasks'),
              actions: [
                IconButton(
                    onPressed: state is TaskSyncing
                        ? null
                        : () {
                            context.read<TaskBloc>().add(SyncTasksEvent());
                          },
                    icon: const Icon(Icons.sync))
              ],
            ),
            body: Column(
              children: [
                if (state is TaskSyncing)
                  Container(
                    height: 20,
                    alignment: Alignment.center,
                    width: double.infinity,
                    color: Colors.green,
                    child: const Text(
                      'Syncing',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                _buildUi(state)
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
                );
                if (result != null) {
                  // ignore: use_build_context_synchronously
                  context.read<TaskBloc>().add(AddNewTaskEvent(result));
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        }));
  }
  // Always call super.dispose() to clean up other resources
}
