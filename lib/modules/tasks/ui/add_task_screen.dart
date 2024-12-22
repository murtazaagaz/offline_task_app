import 'package:flutter/material.dart';
import 'package:offline_task_app/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final bool isUpDate;
  final TaskModel? taskModel;
  const AddTaskScreen({super.key, this.isUpDate = false, this.taskModel});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.taskModel?.title ?? '';
    descriptionController.text = widget.taskModel?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUpDate ? 'Update Task' : 'Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                if (title.isNotEmpty && description.isNotEmpty) {
                  Navigator.pop(
                    context,
                    TaskModel(
                        title: title,
                        description: description,
                        id: widget.taskModel?.id ??
                            DateTime.now().millisecondsSinceEpoch.toDouble()),
                  );
                }
              },
              child: Text(widget.isUpDate ? 'Update Task' : 'Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
