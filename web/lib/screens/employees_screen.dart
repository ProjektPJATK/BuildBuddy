import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

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
    final client = HttpClient(); // Tworzenie klienta HTTP
    try {
      // Tworzenie żądania
      final request = await client.getUrl(Uri.parse('http://10.0.2.2:5007/api/User'));
      request.headers.set('Accept', 'application/json');
      request.headers.set('Authorization', 'Bearer YOUR_TOKEN_HERE'); // Zastąp YOUR_TOKEN_HERE właściwym tokenem

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

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
      client.close(); // Zamknięcie klienta
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Employees'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
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

class EmployeeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailsScreen({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${employee['name']} ${employee['surname']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(employee['userImageUrl']),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${employee['name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Surname: ${employee['surname']}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${employee['email']}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Telephone: ${employee['telephoneNr']}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Team ID: ${employee['teamId']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
