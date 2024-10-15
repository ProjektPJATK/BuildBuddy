// lib/screens/task_detail_screen.dart

import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String createdBy;
  final String taskDate;

  TaskDetailScreen({
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Czarny filtr z przezroczystością 0.75
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
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nazwa: $title',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (taskDate.isNotEmpty)
                        Text(
                          'Data: $taskDate',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      if (description.isNotEmpty)
                        Text(
                          'Opis: $description',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      if (startTime.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Czas rozpoczęcia: $startTime',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                      if (endTime.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Czas zakończenia: $endTime',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                      if (createdBy.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Wystawione przez: $createdBy',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Action for adding an update
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
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
