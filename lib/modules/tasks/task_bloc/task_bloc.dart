import 'package:bloc/bloc.dart';
import 'package:offline_task_app/models/task_model.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_event.dart';
import 'package:offline_task_app/modules/tasks/task_bloc/task_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskLoading()) {
    on<LoadTasksEvent>(loadTask);

    on<AddNewTaskEvent>(addNewTask);

    on<UpdateTaskEvent>(updateTask);
    on<DeleteTaskEvent>(deleteTask);

    on<SyncTasksEvent>(syncTask);
    on<LoadDetailEvent>(loadDetailTask);
  }

  loadTask(event, emit) async {
    emit(TaskLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? taskList = prefs.getStringList('tasks');
      if (taskList != null) {
        final tasks = taskList.map((task) => TaskModel.fromJson(task)).toList();
        emit(TaskLoaded(tasks));
      } else {
        emit(TaskLoaded([]));
      }
    } catch (e) {
      print('error: $e');
    }
  }

  loadDetailTask(LoadDetailEvent event, Emitter emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? taskList = prefs.getStringList('tasks');
      if (taskList != null) {
        final tasks = taskList.map((task) {
          return TaskModel.fromJson(task);
        }).toList();
        final TaskModel? queryTask =
            tasks.firstWhere((task) => task.id == event.id);
        if (queryTask != null) {
          emit(TaskDetailLoaded(queryTask));
        }
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      print('error: $e');
    }
  }

  addNewTask(AddNewTaskEvent event, emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? taskList = prefs.getStringList('tasks') ?? [];
      final updatedTask = event.task.toJson();
      taskList.add(updatedTask);
      await prefs.setStringList('tasks', taskList);
      emit(TaskAdded());
      add(LoadTasksEvent());
    } catch (e) {
      print('error: $e');
    }
  }

  updateTask(UpdateTaskEvent event, Emitter emit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? taskList = prefs.getStringList('tasks');
      if (taskList != null) {
        final tasks = taskList.map((task) => TaskModel.fromJson(task)).toList();

        final index = tasks.indexWhere((task) => task.id == event.task.id);
        tasks.removeAt(index);
        tasks.insert(index, event.task);

        final taskAsJson = tasks.map((task) => task.toJson()).toList();

        await prefs.setStringList('tasks', taskAsJson);
        add(LoadTasksEvent());
      }
    } catch (e) {
      print('error $e');
    }
  }

  deleteTask(DeleteTaskEvent event, Emitter emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      final tasks = taskList.map((task) => TaskModel.fromJson(task)).toList();

      tasks.removeWhere((task) {
        return task.id == event.id;
      });

      final taskAsJson = tasks.map((task) => task.toJson()).toList();

      await prefs.setStringList('tasks', taskAsJson);
      add(LoadTasksEvent());
    }
  }

  syncTask(event, emit) async {
    emit(TaskSyncing());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<TaskModel> taskList = prefs
            .getStringList('tasks')
            ?.map((task) => TaskModel.fromJson(task))
            .toList() ??
        [];
    if (taskList.isNotEmpty) {
      for (int i = 0; i < taskList.length; i++) {
        if (!taskList[i].isSynced) {
          print("Synced task: ${taskList[i]}");
          taskList[i].isSynced = true;
        }
      }

      List<String> syncedTask = taskList.map((task) => task.toJson()).toList();
      await prefs.setStringList('tasks', syncedTask);

      await Future.delayed(
          const Duration(seconds: 2)); // Simulate network latency
    }
    emit(TaskSynced());
    add(LoadTasksEvent());
  }
}
