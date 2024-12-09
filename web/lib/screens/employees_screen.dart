import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html; // Użycie localStorage w przeglądarce
import 'package:universal_io/io.dart';
import 'employeedetails_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Map<String, dynamic>> employees = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

Future<void> _fetchEmployees() async {
  final client = HttpClient();
  try {
    final userId = html.window.localStorage['userId'];
    final teamId = html.window.localStorage['teamId']; // Pobierz teamId
    final token = html.window.localStorage['token'];

    if (userId == null || teamId == null || token == null) {
      throw Exception("User data not found in localStorage");
    }

    final request = await client.getUrl(Uri.parse('http://localhost:5007/api/User'));
    request.headers.set('Accept', 'application/json');
    request.headers.set('Authorization', 'Bearer $token');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final List<dynamic> data = jsonDecode(responseBody);

      if (mounted) {
        setState(() {
          employees = data
              .where((item) =>
                  item['teamId'].toString() == teamId && // Porównanie teamId
                  item['id'].toString() != userId) // Wyklucz zalogowanego użytkownika
              .map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'surname': item['surname'],
              'email': item['mail'],
              'telephoneNr': item['telephoneNr'],
              'userImageUrl': item['userImageUrl'],
              'teamId': item['teamId'],
            };
          }).toList();
          employees.sort((a, b) => a['name'].compareTo(b['name']));
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _isError = true;
      _isLoading = false;
    });
    print('Error fetching employees: $e');
  } finally {
    client.close();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employees'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: const Text(
                    'Failed to load employees.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(employee['userImageUrl'] ?? ''),
                        backgroundColor: Colors.grey,
                      ),
                      title: Text('${employee['name']} ${employee['surname']}'),
                      subtitle: Text('Team ID: ${employee['teamId']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EmployeeDetailsScreen(employee: employee),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
