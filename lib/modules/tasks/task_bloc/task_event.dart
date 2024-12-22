import 'package:offline_task_app/models/task_model.dart';

abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class LoadDetailEvent extends TaskEvent {
  final double id;
  LoadDetailEvent(this.id);
}

class AddNewTaskEvent extends TaskEvent {
  final TaskModel task;
  AddNewTaskEvent(this.task);
}

class UpdateTaskEvent extends TaskEvent {
  final TaskModel task;
  UpdateTaskEvent(this.task);
}

class DeleteTaskEvent extends TaskEvent {
  final double id;
  DeleteTaskEvent(this.id);
}

class SyncTasksEvent extends TaskEvent {}
