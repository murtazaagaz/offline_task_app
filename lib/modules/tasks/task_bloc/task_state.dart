import 'package:offline_task_app/models/task_model.dart';

abstract class TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  TaskLoaded(this.tasks);
}

class TaskDetailLoaded extends TaskState {
  final TaskModel task;
  TaskDetailLoaded(this.task);
}

class TaskAdding extends TaskState {}

class TaskAdded extends TaskState {}

class TaskSyncing extends TaskState {}

class TaskSynced extends TaskState {}
