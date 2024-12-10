import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_carousel.dart';

class TaskUpdateDialog extends StatefulWidget {
  final Function(String, List<File>) onSave;

  const TaskUpdateDialog({super.key, required this.onSave});

  @override
  _TaskUpdateDialogState createState() => _TaskUpdateDialogState();
}

class _TaskUpdateDialogState extends State<TaskUpdateDialog> {
  final TextEditingController _commentController = TextEditingController();
  List<File> _selectedImages = [];

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
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
                  child: const Text('Dodaj Zdjęcia', style: TextStyle(fontSize: 12)),
                ),
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: const Text('Zrób Zdjęcie', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_commentController.text, _selectedImages);
            Navigator.pop(context);
          },
          child: const Text('Zapisz', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
