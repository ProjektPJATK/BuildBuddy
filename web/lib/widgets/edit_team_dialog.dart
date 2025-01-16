import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web/config/config.dart';
import 'package:web/services/teams_service.dart';

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
    final TextEditingController descriptionController = TextEditingController(text: addressData['description']); // Dodano kontroler

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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Edytuj Team'),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
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
              decoration: InputDecoration(labelText: 'Opis'),
              maxLines: 3, // Większe pole tekstowe dla opisu
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
                  'description': descriptionController.text, // Dodano opis
                },
              );
              Navigator.pop(context);
            }
          },
          child: Text('Zapisz'),
        ),
      ],
    );
  }
}

extension TeamsServiceExtensions on TeamsService {
  Future<void> deleteTeam(int teamId) async {
    final client = HttpClient();
    try {
      final url = '${AppConfig.getBaseUrl()}/api/Team/$teamId';
      final request = await client.deleteUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 204) {
        print('Team deleted successfully.');
      } else {
        throw Exception('Failed to delete team: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting team: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
