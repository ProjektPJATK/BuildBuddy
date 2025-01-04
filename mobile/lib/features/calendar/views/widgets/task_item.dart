import 'package:flutter/material.dart';
import '../../../tasks/views/task_details_screen.dart';

class TaskItem extends StatelessWidget {
  final String title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? taskDate;

  const TaskItem({
    super.key,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.taskDate,
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
              description: description ?? 'Brak opisu',
              startTime: startTime ?? 'Nieznana',
              endTime: endTime ?? 'Nieznana',
              taskDate: taskDate ?? 'Nieznana',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.event_note, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (description != null && description!.isNotEmpty)
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  if (startTime != null && endTime != null)
                    Text(
                      'Godziny: $startTime - $endTime',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  if (taskDate != null)
                    Text(
                      'Data: $taskDate',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
