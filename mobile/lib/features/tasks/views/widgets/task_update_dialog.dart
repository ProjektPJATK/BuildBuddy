import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/shared/services/task_service.dart';
import 'image_carousel.dart';

class TaskUpdateDialog extends StatefulWidget {
  final Function(String, List<File>) onSave;
  final int jobId;

  const TaskUpdateDialog({super.key, required this.onSave, required this.jobId});

  @override
  _TaskUpdateDialogState createState() => _TaskUpdateDialogState();
}

class _TaskUpdateDialogState extends State<TaskUpdateDialog> {
  final TextEditingController _commentController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveUpdate() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentarz nie może być pusty.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create Task Actualization
      int actualizationId = await TaskService.createTaskActualization(
          widget.jobId, _commentController.text);

      // Step 2: Upload Images
      if (_selectedImages.isNotEmpty) {
        for (File image in _selectedImages) {
          await TaskService.uploadImage(actualizationId, image);
        }
      }

      // Success callback
      widget.onSave(_commentController.text, _selectedImages);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktualizacja zapisana pomyślnie.')),
      );
    } catch (e) {
      print('Failed to save update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd zapisu aktualizacji.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);  // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Dodaj Aktualizację', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Dodaj komentarz',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedImages.isNotEmpty)
              ImageCarousel(images: _selectedImages, onRemoveImage: _removeImage),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _selectImage,
                  child: const Text('Dodaj Zdjęcia'),
                ),
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: const Text('Zrób Zdjęcie'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUpdate,
          child: Text(_isLoading ? 'Zapisywanie...' : 'Zapisz'),
        ),
      ],
    );
  }
}
