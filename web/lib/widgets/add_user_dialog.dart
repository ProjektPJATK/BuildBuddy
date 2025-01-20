import 'package:flutter/material.dart';
import 'package:web_app/services/teams_service.dart';
import 'package:universal_html/html.dart' as html;
class AddUserDialog extends StatefulWidget {
  final int teamId;
  final List<int> existingUserIds; // Lista użytkowników w drużynie
  final VoidCallback onCancel;
  final Function(List<int>) onSuccess;

  AddUserDialog({
    required this.teamId,
    required this.existingUserIds, // Przekazanie listy użytkowników w drużynie
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TeamsService _teamsService = TeamsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> selectedUsers = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

int _getLoggedInUserId() {
  final loggedInUserId = int.tryParse(html.window.localStorage['userId'] ?? '0') ?? 0;
  print('Zalogowany użytkownik ma ID: $loggedInUserId');
  return loggedInUserId;
}


  Future<void> _fetchUsers() async {
  try {
    final fetchedUsers = await _teamsService.fetchAllUsers();

    // Filtruj użytkowników, którzy nie należą do zespołu i nie są zalogowanym użytkownikiem
    final availableUsers = fetchedUsers
        .where((user) =>
            !widget.existingUserIds.contains(user['id']) && user['id'] != _getLoggedInUserId())
        .toList();

    setState(() {
      users = availableUsers;
      filteredUsers = availableUsers;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isError = true;
      _isLoading = false;
    });
    print('Błąd podczas pobierania użytkowników: $e');
  }
}


  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final fullName = '${user['name']} ${user['surname']}'.toLowerCase();
        final email = user['email'].toLowerCase();
        final id = user['id'].toString();

        return fullName.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase()) ||
            id == query;
      }).toList();
    });
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: AlertDialog(
        title: Text('Dodaj użytkowników do zespołu'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _isError
                  ? Center(child: Text('Nie udało się załadować użytkowników.'))
                  : Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Szukaj użytkownika',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: _filterUsers,
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            interactive: true,
                            child: ListView(
                              controller: _scrollController,
                              children: [
                                ...selectedUsers.map((user) =>
                                    _buildUserTile(user, true)),
                                ...filteredUsers
                                    .where((user) => !selectedUsers.contains(user))
                                    .map((user) => _buildUserTile(user, false)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onCancel();
            },
            child: Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: selectedUsers.isNotEmpty
                ? () {
                    final userIds =
                        selectedUsers.map((user) => user['id'] as int).toList();
                    widget.onSuccess(userIds);
                    Navigator.pop(context);
                  }
                : null,
            child: Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, bool isSelected) {
    return ListTile(
      leading: Checkbox(
        value: isSelected,
        onChanged: (_) {
          _toggleUserSelection(user);
        },
      ),
      title: Text('${user['name']} ${user['surname']}'),
      subtitle: Text(
        user['email'],
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        _toggleUserSelection(user);
      },
    );
  }
}
