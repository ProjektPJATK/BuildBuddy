import 'package:flutter/material.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/features/profile/models/user_model.dart';

class EditProfileDialog extends StatelessWidget {
  final User user;
  final Function(User) onSave;

  const EditProfileDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: user.name);
    final surnameController = TextEditingController(text: user.surname);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.telephoneNr);

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
            final updatedUser = User(
              id: user.id,
              name: nameController.text,
              surname: surnameController.text,
              email: emailController.text,
              telephoneNr: phoneController.text,
              password: user.password,
              userImageUrl: user.userImageUrl,
              preferredLanguage: user.preferredLanguage,
            );
            onSave(updatedUser);
            Navigator.pop(context);
          },
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
