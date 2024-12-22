import 'dart:convert';

class TaskModel {
  final String title;
  final String description;
  bool isSynced;
  final double id;
  TaskModel({
    required this.title,
    required this.description,
    required this.id,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'description': description});
    result.addAll({'isSynced': isSynced});
    result.addAll({'id': id});

    return result;
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isSynced: map['isSynced'] ?? false,
      id: map['id']?.toDouble() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source));
}
