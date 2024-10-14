
import 'package:flutter/material.dart';
import '../screens/taskDetail_screen.dart'; // Import TaskDetailScreen

class TaskItem extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String createdBy;
  final String taskDate;

  TaskItem({
    required this.title,
    this.description = '',
    this.startTime = '',
    this.endTime = '',
    this.createdBy = '',
    required this.taskDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(
              title: title,
              description: description,
              startTime: startTime,
              endTime: endTime,
              createdBy: createdBy,
              taskDate: taskDate,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.task, color: Colors.black),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}