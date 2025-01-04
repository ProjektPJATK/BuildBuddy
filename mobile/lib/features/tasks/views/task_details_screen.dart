import 'package:flutter/material.dart';
import 'widgets/task_update_dialog.dart';

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const TaskDetailScreen({super.key, required this.title, required this.description, required String startTime, required String endTime, required String taskDate});

  void _showTaskUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => TaskUpdateDialog(
        onSave: (comment, images) {
          print('Komentarz: $comment');
          print('Obrazy: ${images.map((img) => img.path).toList()}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opis: $description'),
            ElevatedButton(
              onPressed: () => _showTaskUpdateDialog(context),
              child: const Text('Dodaj Aktualizację'),
            ),
          ],
        ),
      ),
    );
  }
}
