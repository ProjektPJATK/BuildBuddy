import 'package:flutter/material.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String taskDate;

  const TaskItem({
    super.key,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.taskDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text('$description\n$startTime - $endTime'),
      ),
    );
  }
}
