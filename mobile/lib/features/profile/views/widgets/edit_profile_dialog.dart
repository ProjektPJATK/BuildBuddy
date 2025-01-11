import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/features/profile/models/user_model.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'dart:io';

import 'language_picker.dart';  // Import the picker

class EditProfileDialog extends StatefulWidget {
  final User user;
  final Function(User) onSave;

  const EditProfileDialog({super.key, required this.user, required this.onSave});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController languageController;
  File? _selectedImage;
  bool _isLoading = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    surnameController = TextEditingController(text: widget.user.surname);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.telephoneNr);
    languageController = TextEditingController(text: widget.user.preferredLanguage);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty || surnameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wszystkie pola muszą być wypełnione.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedUser = User(
      id: widget.user.id,
      name: nameController.text,
      surname: surnameController.text,
      email: emailController.text,
      telephoneNr: phoneController.text,
      password: widget.user.password,
      userImageUrl: _selectedImage?.path ?? widget.user.userImageUrl,
      preferredLanguage: languageController.text,
    );

    try {
      await _userService.editUserProfile(updatedUser);
      if (_selectedImage != null) {
        await _userService.uploadUserImage(updatedUser.id, _selectedImage!);
      }
      widget.onSave(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil został zapisany.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas zapisywania profilu: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  // Show Language Picker Modal
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LanguagePicker(
          onLanguageSelected: (String selectedLanguage) {
            setState(() {
              languageController.text = selectedLanguage;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edytuj Profil', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (widget.user.userImageUrl.isNotEmpty
                        ? NetworkImage(widget.user.userImageUrl)
                        : null) as ImageProvider?,
                child: _selectedImage == null && widget.user.userImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: AppStyles.inputFieldStyle(hintText: 'Imię'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: surnameController,
              style: const TextStyle(color: Colors.white),
              decoration: AppStyles.inputFieldStyle(hintText: 'Nazwisko'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: AppStyles.inputFieldStyle(hintText: 'E-mail'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: AppStyles.inputFieldStyle(hintText: 'Telefon'),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showLanguagePicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: languageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: AppStyles.inputFieldStyle(
                    hintText: 'Preferowany język',
                  ),
                ),
              ),
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
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            _isLoading ? 'Zapisywanie...' : 'Zapisz',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
