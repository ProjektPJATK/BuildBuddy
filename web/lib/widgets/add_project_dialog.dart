import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_app/services/teams_service.dart';

class AddProjectDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final Function(Map<String, String>) onSuccess;

  AddProjectDialog({required this.onCancel, required this.onSuccess});

  @override
Widget build(BuildContext context) {
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController localNumberController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController teamNameController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppStyles.transparentWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text('Błąd', style: AppStyles.headerStyle),
        content: Text(message, style: AppStyles.textStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppStyles.textButtonStyle(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _validateFields() {
    if (teamNameController.text.isEmpty ||
        cityController.text.isEmpty ||
        countryController.text.isEmpty ||
        streetController.text.isEmpty ||
        houseNumberController.text.isEmpty ||
        localNumberController.text.isEmpty ||
        postalCodeController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      _showErrorDialog('Wszystkie pola muszą być wypełnione.');
      return false;
    }
    return true;
  }

  return AlertDialog(
    backgroundColor: const Color.fromARGB(132, 8, 8, 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    title: Text(
      'Dodaj Projekt',
       style: AppStyles.headerStyle.copyWith(color: Colors.white),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: teamNameController,
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
        onPressed: () async {
          if (_validateFields()) {
            final teamsService = TeamsService();
            try {
              final addressData = {
                'city': cityController.text,
                'country': countryController.text,
                'street': streetController.text,
                'houseNumber': houseNumberController.text,
                'localNumber': localNumberController.text,
                'postalCode': postalCodeController.text,
                'description': descriptionController.text,
              };
              final addressId = await teamsService.createAddress(addressData);

              final teamName = teamNameController.text;
              final teamId = await teamsService.createTeam(teamName, addressId);

              final userId = int.tryParse(html.window.localStorage['userId'] ?? '0') ?? 0;
              if (userId > 0) {
                await teamsService.addUserToTeam(teamId, userId);
                await teamsService.addRoleToUserInTeam(
                  userId: userId,
                  teamId: teamId,
                  roleId: 2, // Domyślna rola
                );
              }

              onSuccess({
                'teamId': teamId.toString(),
                'teamName': teamName,
                'addressId': addressId.toString(),
              });

              Navigator.pop(context);
            } catch (e) {
              _showErrorDialog('Nie udało się dodać projektu: $e');
            }
          }
        },
        style: AppStyles.buttonStyle(),
        child: const Text('Dodaj'),
      ),
    ],
  );
}

}
