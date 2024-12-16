import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'employeedetails_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

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
      final request = await client.getUrl(Uri.parse('http://localhost:5007/api/User'));
      request.headers.set('Accept', 'application/json');
      request.headers.set('Authorization', 'lSkdJ3kdLs72FjiwlSkdLf93kdDfLsmK'); // Wstaw token

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        if (mounted) { // Sprawdzanie, czy widżet jest nadal zamontowany
          setState(() {
            employees = data.map((item) {
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
            employees.sort((a, b) => a['teamId'].compareTo(b['teamId'])); // Sortowanie po teamId
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
      print('Error fetching employees: $e');
    } finally {
      client.close();
    }
  }

  @override
  void dispose() {
    super.dispose();
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
              ? const Center(
                  child: Text(
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
                        backgroundImage: NetworkImage(employee['userImageUrl']),
                      ),
                      title: Text('${employee['name']} ${employee['surname']}'),
                      subtitle: Text('Team ID: ${employee['teamId']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeDetailsScreen(employee: employee),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
