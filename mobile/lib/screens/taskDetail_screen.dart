import 'dart:io';

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

  void _showAddUpdateDialog(BuildContext context) {
    final TextEditingController komentarzController = TextEditingController();
    XFile? selectedImage; // Store the selected image

    void _selectImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        selectedImage = pickedImage;
        (context as Element).markNeedsBuild(); // Refresh the widget
      }
    }

    void _takePhoto() async {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedImage != null) {
        selectedImage = pickedImage;
        (context as Element).markNeedsBuild(); // Refresh the widget
      }
    }

    void _showImageDialog(BuildContext context, String imagePath) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                    const SizedBox(height: 10),
                    // Display selected image miniature
                    if (selectedImage != null)
                      GestureDetector(
                        onTap: () => _showImageDialog(context, selectedImage!.path),
                        child: Image.file(
                          File(selectedImage!.path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final XFile? image =
                                await picker.pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              setState(() {
                                selectedImage = image;
                              });
                            }
                          },
                          style: AppStyles.buttonStyle().copyWith(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                          ),
                          child: const Text(
                            'Dodaj Zdjęcie',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final XFile? photo =
                                await picker.pickImage(source: ImageSource.camera);
                            if (photo != null) {
                              setState(() {
                                selectedImage = photo;
                              });
                            }
                          },
                          style: AppStyles.buttonStyle().copyWith(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                          ),
                          child: const Text(
                            'Zrób Zdjęcie',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
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
