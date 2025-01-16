import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web/services/teams_service.dart';

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
    final TextEditingController descriptionController = TextEditingController(); // Dodano
    final TextEditingController teamNameController = TextEditingController();

    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Błąd'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
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
          descriptionController.text.isEmpty) { // Walidacja pola description
        _showErrorDialog('Wszystkie pola muszą być wypełnione.');
        return false;
      }
      return true;
    }

    return AlertDialog(
      title: Text('Dodaj Projekt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: teamNameController,
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
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Opis (description)'), // Dodano
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
          onPressed: () async {
            if (_validateFields()) {
              final teamsService = TeamsService();
              try {
                // Tworzenie projektu
                final addressData = {
                  'city': cityController.text,
                  'country': countryController.text,
                  'street': streetController.text,
                  'houseNumber': houseNumberController.text,
                  'localNumber': localNumberController.text,
                  'postalCode': postalCodeController.text,
                  'description': descriptionController.text, // Dodano
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
          child: Text('Dodaj'),
        ),
      ],
    );
  }
}
