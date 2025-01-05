import 'package:flutter/material.dart';
import 'widgets/task_update_dialog.dart';

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String taskDate;
  final int taskId;

  const TaskDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.taskDate,
    required this.taskId,
  });

  void _showTaskUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => TaskUpdateDialog(
        jobId: taskId,
        onSave: (comment, images) {
          print('Task Updated - ID: $taskId');
          print('Komentarz: $comment');
          print('Zdjęcia: ${images.map((img) => img.path).toList()}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Opening Task Details - Task ID: $taskId');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opis: $description'),
            Text('Godzina rozpoczęcia: $startTime'),
            Text('Godzina zakończenia: $endTime'),
            Text('Data: $taskDate'),
            Text('Task ID: $taskId'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _showTaskUpdateDialog(context),
                child: const Text('Aktualizuj'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
