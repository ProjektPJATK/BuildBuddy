import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web/config/config.dart';
import 'package:web/services/teams_service.dart';
import 'package:web/themes/styles.dart';

class EditTeamDialog extends StatelessWidget {
  final int teamId; // Dodano teamId
  final String teamName;
  final Map<String, String> addressData;
  final Function(String, Map<String, String>) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onTeamDeleted;

  EditTeamDialog({
    required this.teamId, // Oczekiwany parametr
    required this.teamName,
    required this.addressData,
    required this.onSubmit,
    required this.onCancel,
    required this.onTeamDeleted,
  });

  void _showDeleteConfirmation(BuildContext context) async {
    final TeamsService teamsService = TeamsService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Usuń Team'),
        content: Text('Czy na pewno chcesz usunąć ten team?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await teamsService.deleteTeam(teamId);
                Navigator.pop(context); // Zamknięcie dialogu potwierdzenia
                Navigator.pop(context); // Zamknięcie dialogu edycji

                // Wywołanie callbacka po udanym usunięciu zespołu
                onTeamDeleted();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Team został pomyślnie usunięty.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nie udało się usunąć teamu: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Usuń'),
          ),
        ],
      ),
    );
  }

  bool _validateFields(BuildContext context, List<TextEditingController> controllers) {
    for (var controller in controllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wszystkie pola muszą być wypełnione!'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

 @override
Widget build(BuildContext context) {
  final TextEditingController nameController = TextEditingController(text: teamName);
  final TextEditingController cityController = TextEditingController(text: addressData['city']);
  final TextEditingController countryController = TextEditingController(text: addressData['country']);
  final TextEditingController streetController = TextEditingController(text: addressData['street']);
  final TextEditingController houseNumberController = TextEditingController(text: addressData['houseNumber']);
  final TextEditingController localNumberController = TextEditingController(text: addressData['localNumber']);
  final TextEditingController postalCodeController = TextEditingController(text: addressData['postalCode']);
  final TextEditingController descriptionController = TextEditingController(text: addressData['description']);

  final controllers = [
    nameController,
    cityController,
    countryController,
    streetController,
    houseNumberController,
    localNumberController,
    postalCodeController,
    descriptionController,
  ];

  return AlertDialog(
    backgroundColor: AppStyles.transparentWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Edytuj Team',
          style: AppStyles.headerStyle,
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 2, 2, 2)),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Nazwa Teamu'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cityController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Miasto'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: countryController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Kraj'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: streetController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Ulica'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: houseNumberController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Numer Domu'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: localNumberController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Numer Lokalu'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: postalCodeController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Kod Pocztowy'),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            decoration: AppStyles.inputFieldStyle(hintText: 'Opis'),
            maxLines: 3,
            cursorColor: AppStyles.cursorColor,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: onCancel,
        style: AppStyles.textButtonStyle(),
        child: const Text('Anuluj'),
      ),
      ElevatedButton(
        onPressed: () {
          if (_validateFields(context, controllers)) {
            onSubmit(
              nameController.text,
              {
                'city': cityController.text,
                'country': countryController.text,
                'street': streetController.text,
                'houseNumber': houseNumberController.text,
                'localNumber': localNumberController.text,
                'postalCode': postalCodeController.text,
                'description': descriptionController.text,
              },
            );
            Navigator.pop(context);
          }
        },
        style: AppStyles.buttonStyle(),
        child: const Text('Zapisz'),
      ),
    ],
  );
}

}
