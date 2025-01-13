import 'package:flutter/material.dart';

class EditTeamDialog extends StatelessWidget {
  final String teamName;
  final Map<String, String> addressData;
  final Function(String, Map<String, String>) onSubmit;
  final VoidCallback onCancel;

  EditTeamDialog({
    required this.teamName,
    required this.addressData,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: teamName);
    final TextEditingController cityController = TextEditingController(text: addressData['city']);
    final TextEditingController countryController = TextEditingController(text: addressData['country']);
    final TextEditingController streetController = TextEditingController(text: addressData['street']);
    final TextEditingController houseNumberController = TextEditingController(text: addressData['houseNumber']);
    final TextEditingController localNumberController = TextEditingController(text: addressData['localNumber']);
    final TextEditingController postalCodeController = TextEditingController(text: addressData['postalCode']);

    return AlertDialog(
      title: Text('Edytuj Team'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nazwa Teamu'),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'Miasto'),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: 'Kraj'),
            ),
            TextField(
              controller: streetController,
              decoration: InputDecoration(labelText: 'Ulica'),
            ),
            TextField(
              controller: houseNumberController,
              decoration: InputDecoration(labelText: 'Numer Domu'),
            ),
            TextField(
              controller: localNumberController,
              decoration: InputDecoration(labelText: 'Numer Lokalu'),
            ),
            TextField(
              controller: postalCodeController,
              decoration: InputDecoration(labelText: 'Kod Pocztowy'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Anuluj'),
        ),
        TextButton(
          onPressed: () {
            onSubmit(
              nameController.text,
              {
                'city': cityController.text,
                'country': countryController.text,
                'street': streetController.text,
                'houseNumber': houseNumberController.text,
                'localNumber': localNumberController.text,
                'postalCode': postalCodeController.text,
              },
            );
            Navigator.pop(context);
          },
          child: Text('Zapisz'),
        ),
      ],
    );
  }
}
