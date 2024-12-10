import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';

class EditProfileDialog extends StatelessWidget {
  final String? name;
  final String? surname;
  final String? email;
  final String? phone;
  final Function(Map<String, String>) onSave;

  const EditProfileDialog({
    super.key,
    this.name,
    this.surname,
    this.email,
    this.phone,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final surnameController = TextEditingController(text: surname);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phone);

    return AlertDialog(
      title: const Text('Edytuj Profil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, decoration: AppStyles.inputFieldStyle(hintText: 'Imię')),
          const SizedBox(height: 8),
          TextField(controller: surnameController, decoration: AppStyles.inputFieldStyle(hintText: 'Nazwisko')),
          const SizedBox(height: 8),
          TextField(controller: emailController, decoration: AppStyles.inputFieldStyle(hintText: 'E-mail')),
          const SizedBox(height: 8),
          TextField(controller: phoneController, decoration: AppStyles.inputFieldStyle(hintText: 'Telefon')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedProfile = {
              'name': nameController.text,
              'surname': surnameController.text,
              'mail': emailController.text,
              'telephoneNr': phoneController.text,
            };
            onSave(updatedProfile);
            Navigator.pop(context);
          },
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
