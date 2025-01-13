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
    final TextEditingController teamNameController = TextEditingController();

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
            final teamsService = TeamsService();
            try {
              // Krok 1: Tworzenie adresu
              final addressData = {
                'city': cityController.text,
                'country': countryController.text,
                'street': streetController.text,
                'houseNumber': houseNumberController.text,
                'localNumber': localNumberController.text,
                'postalCode': postalCodeController.text,
              };
              final addressId = await teamsService.createAddress(addressData);
              print('Address created with ID: $addressId');

              // Krok 2: Tworzenie zespołu
              final teamName = teamNameController.text;
              final teamId = await teamsService.createTeam(teamName, addressId);
              print('Team created with ID: $teamId');

              // Krok 3: Dodanie użytkownika do zespołu
              final userId = int.tryParse(html.window.localStorage['userId'] ?? '0') ?? 0;
              if (userId > 0) {
                await teamsService.addUserToTeam(teamId, userId);
                print('User $userId added to team $teamId');
              } else {
                print('Error: User ID not found in localStorage');
              }

              // Wywołanie onSuccess
              onSuccess({
                'teamId': teamId.toString(),
                'teamName': teamName,
                'addressId': addressId.toString(),
              });

              Navigator.pop(context);
            } catch (e) {
              print('Error adding project: $e');
              _showErrorDialog(context, 'Błąd', 'Nie udało się dodać projektu.');
            }
          },
          child: Text('Dodaj'),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
