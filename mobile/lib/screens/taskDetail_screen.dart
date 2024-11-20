import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../styles.dart'; // Import the AppStyles


class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String createdBy;
  final String taskDate;
  final bool isDone;
  final String komentarz;
  final String imageUrl;

  const TaskDetailScreen({
    super.key,
    required this.title,
    this.description = '',
    this.startTime = '',
    this.endTime = '',
    this.createdBy = '',
    this.taskDate = '',
    this.isDone = false,
    this.komentarz = '',
    this.imageUrl = '',
  });

  // Function to show the "Dodaj Aktualizację" popup dialog
  void _showAddUpdateDialog(BuildContext context) {
    final TextEditingController komentarzController = TextEditingController();
    XFile? selectedImage; // Store the selected image

    void _selectImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
      );
      selectedImage = pickedImage;
    }

    void _takePhoto() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.camera,
      );
      selectedImage = pickedImage;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Dodaj Aktualizację',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: komentarzController,
                  style: const TextStyle(color: Colors.white),
                  decoration: AppStyles.inputFieldStyle(hintText: 'Dodaj komentarz'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectImage,
                  style: AppStyles.buttonStyle(),
                  child: const Text(
                    'Dodaj Zdjęcie',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10), // Space between buttons
                ElevatedButton(
                  onPressed: _takePhoto,
                  style: AppStyles.buttonStyle(),
                  child: const Text(
                    'Zrób Zdjęcie',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: AppStyles.textButtonStyle(),
              child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                if (komentarzController.text.isNotEmpty || selectedImage != null) {
                  // Add your logic to handle komentarz and image upload
                  print('Komentarz: ${komentarzController.text}');
                  if (selectedImage != null) {
                    print('Image Path: ${selectedImage!.path}');
                  }
                  Navigator.of(context).pop(); // Close the dialog after saving
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dodaj komentarz lub zdjęcie'),
                    ),
                  );
                }
              },
              style: AppStyles.buttonStyle().copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
              ),
              child: const Text('Zapisz', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

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
          SingleChildScrollView(
            child: Column(
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
                    child: Stack(
                      children: [
                        Column(
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
                            if (komentarz.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Komentarz:',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                komentarz,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ],
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => _showAddUpdateDialog(context),
                              style: AppStyles.buttonStyle(),
                              child: const Text(
                                'Dodaj aktualizację',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(
                            isDone ? Icons.check_circle : Icons.cancel,
                            color: isDone ? Colors.green : Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
