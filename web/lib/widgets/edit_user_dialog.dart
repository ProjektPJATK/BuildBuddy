import 'package:flutter/material.dart';
import 'package:web_app/services/teams_service.dart';
import 'package:web_app/themes/styles.dart';

class EditUserDialog extends StatefulWidget {
  final int userId;
  final int teamId;
  final VoidCallback onCancel;
  final Function(int, String) onSubmit;
  final VoidCallback onDelete;

  EditUserDialog({
    required this.userId,
    required this.teamId,
    required this.onCancel,
    required this.onSubmit,
    required this.onDelete,
  });

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final TeamsService _teamsService = TeamsService();
  String roleName = '';
  int powerLevel = 0;
  bool isLoading = true;
  bool isError = false;

  final TextEditingController _roleNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserRoleData();
    _roleNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRoleData() async {
    try {
      print('Fetching user role data for userId: ${widget.userId}, teamId: ${widget.teamId}');
      final userData = await _teamsService.getUserData(widget.userId);
      print('User data fetched: $userData');

      final rolesInTeams = userData['rolesInTeams'] as List<dynamic>;
      print('Roles in teams: $rolesInTeams');

      final roleData = rolesInTeams.firstWhere(
        (role) => role['teamId'] == widget.teamId,
        orElse: () => null,
      );

      if (roleData != null) {
        final roleId = roleData['roleId'];
        final roleDetails = await _teamsService.getRoleDetails(roleId);

        setState(() {
          roleName = roleDetails['name'];
          powerLevel = roleDetails['powerLevel'];
          _roleNameController.text = roleName;
          isLoading = false;
        });
      } else {
        setState(() {
          roleName = '';
          powerLevel = 0;
          _roleNameController.text = roleName;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print('Error fetching user role data: $e');
    }
  }

  bool get _isFormValid =>
      _roleNameController.text.trim().isNotEmpty && powerLevel > 0;

  void _validateForm() {
    setState(() {});
  }

  void _confirmDeleteUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept deletion'),
        content: Text('Do you want to delete from this team this worker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Zamknij dialog potwierdzenia
              await _deleteUser(); // Usuń użytkownika
            },
            child: Text('Delet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser() async {
  try {
    print('Deleting user ${widget.userId} from team ${widget.teamId}');
    await _teamsService.deleteUserFromTeam(widget.teamId, widget.userId);
    print('User ${widget.userId} successfully deleted from team ${widget.teamId}');
    widget.onDelete(); // Wywołanie funkcji odświeżenia widoku
    Navigator.pop(context); // Zamknięcie dialogu
  } catch (e) {
    print('Błąd podczas usuwania użytkownika: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not delet user.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (isError) {
    return AlertDialog(
      backgroundColor: AppStyles.transparentWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        'Error',
        style: AppStyles.headerStyle,
      ),
      content: Text(
        'Could not load data.',
        style: AppStyles.textStyle,
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          style: AppStyles.textButtonStyle(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  return AlertDialog(
    backgroundColor: AppStyles.transparentWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    title: Text(
      'Edit user rank',
      style: AppStyles.headerStyle,
    ),
    content: SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _roleNameController,
            decoration: AppStyles.inputFieldStyle(
              hintText: 'Rank',
            ).copyWith(
              errorText: _roleNameController.text.trim().isEmpty
                  ? 'Rank name can not be empty'
                  : null,
            ),
            cursorColor: AppStyles.cursorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Access level:',
            style: AppStyles.textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          RadioListTile<int>(
            title: Text(
              'only mobile app',
              style: AppStyles.textStyle,
            ),
            value: 1,
            groupValue: powerLevel,
            activeColor: AppStyles.primaryBlue,
            onChanged: (value) {
              setState(() {
                powerLevel = value!;
              });
            },
          ),
          RadioListTile<int>(
            title: Text(
              'Access to mobile app and web app without teams access',
              style: AppStyles.textStyle,
            ),
            value: 2,
            groupValue: powerLevel,
            activeColor: AppStyles.primaryBlue,
            onChanged: (value) {
              setState(() {
                powerLevel = value!;
              });
            },
          ),
          RadioListTile<int>(
            title: Text(
              'Access to all',
              style: AppStyles.textStyle,
            ),
            value: 3,
            groupValue: powerLevel,
            activeColor: AppStyles.primaryBlue,
            onChanged: (value) {
              setState(() {
                powerLevel = value!;
              });
            },
          ),
          if (powerLevel == 0)
            Text(
              'Must choose access level',
              style: AppStyles.textStyle.copyWith(color: Colors.red),
            ),
        ],
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.delete, color: Color.fromARGB(255, 2, 2, 2)),
        onPressed: _confirmDeleteUser,
      ),
      TextButton(
        onPressed: widget.onCancel,
        style: AppStyles.textButtonStyle(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _isFormValid
            ? () {
                widget.onSubmit(
                    powerLevel, _roleNameController.text.trim());
                Navigator.pop(context);
              }
            : null,
        style: AppStyles.buttonStyle(),
        child: const Text('Save'),
      ),
    ],
  );
}

 
}
