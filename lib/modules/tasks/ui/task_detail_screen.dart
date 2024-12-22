import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_task_app/models/task_model.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_bloc.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_event.dart';
import 'package:offline_task_app/modules/tasks/ui/add_task_screen.dart';
import 'package:share_plus/share_plus.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    final taskBloc = BlocProvider.of<TaskBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Title:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Sync Status:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  task.isSynced ? Icons.check_circle : Icons.error,
                  color: task.isSynced ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  task.isSynced ? "Synced" : "Not Synced",
                  style: TextStyle(
                    fontSize: 16,
                    color: task.isSynced ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
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
                      taskBloc.add(UpdateTaskEvent(result));
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(result)));
                    }
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Share.share('myapp://task?id=${task.id}');
                  },
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Share",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    taskBloc.add(DeleteTaskEvent(task.id));

                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
