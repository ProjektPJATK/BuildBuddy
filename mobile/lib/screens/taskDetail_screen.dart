import 'package:flutter/material.dart';
import '../styles.dart'; // Import the AppStyles

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String createdBy;
  final String taskDate;

  const TaskDetailScreen({
    super.key, 
    required this.title,
    this.description = '',
    this.startTime = '',
    this.endTime = '',
    this.createdBy = '',
    this.taskDate = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent black filter
          Container(
            color: Colors.black.withOpacity(0.75),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 16),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nazwa: $title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (taskDate.isNotEmpty)
                        Text(
                          'Data: $taskDate',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      if (description.isNotEmpty)
                        Text(
                          'Opis: $description',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      if (startTime.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Czas rozpoczęcia: $startTime',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                      if (endTime.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Czas zakończenia: $endTime',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                      if (createdBy.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Wystawione przez: $createdBy',
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Updated Button to use AppStyles.buttonStyle()
                      ElevatedButton(
                        onPressed: () {
                          // Action for adding an update
                        },
                        style: AppStyles.buttonStyle(), // Using buttonStyle from AppStyles
                        child: const Text(
                          'Dodaj aktualizację',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
