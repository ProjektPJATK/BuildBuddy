import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_app/services/teams_service.dart';
import 'package:web_app/themes/styles.dart';

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
          title: Text('Error', style: AppStyles.headerStyle),
          content: Text(message, style: AppStyles.textStyle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Black text color
              ),
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
        _showErrorDialog('All fields must be filled.');
        return false;
      }
      return true;
    }

    return AlertDialog(
      backgroundColor: AppStyles.transparentWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Add Project',
        style: AppStyles.headerStyle.copyWith(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: teamNameController,
              decoration: InputDecoration(
                hintText: 'Team Name',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: 'City',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                hintText: 'Country',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: streetController,
              decoration: InputDecoration(
                hintText: 'Street',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: houseNumberController,
              decoration: InputDecoration(
                hintText: 'House Number',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: localNumberController,
              decoration: InputDecoration(
                hintText: 'Apartment Number',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: postalCodeController,
              decoration: InputDecoration(
                hintText: 'Postal Code',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              cursorColor: AppStyles.cursorColor,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              maxLines: 3,
              cursorColor: AppStyles.cursorColor,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Black text color for Cancel
          ),
          child: const Text('Cancel'),
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
                    roleId: 2, // Default role
                  );
                }

                onSuccess({
                  'teamId': teamId.toString(),
                  'teamName': teamName,
                  'addressId': addressId.toString(),
                });

                Navigator.pop(context);
              } catch (e) {
                _showErrorDialog('Failed to add project: $e');
              }
            }
          },
          style: AppStyles.buttonStyle(),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
