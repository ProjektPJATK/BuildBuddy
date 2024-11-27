import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'taskdetails_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final client = HttpClient(); // Tworzenie klienta HTTP
    try {
      // Tworzenie żądania
      final request = await client.getUrl(Uri.parse('http://10.0.2.2:5007/api/Task'));
      request.headers.set('Accept', 'application/json');
      request.headers.set('Authorization', 'Bearer YOUR_TOKEN_HERE'); // Wstaw token tutaj

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        setState(() {
          tasks = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'message': item['message'],
              'startTime': item['startTime'],
              'endTime': item['endTime'],
              'allDay': item['allDay'],
              'placeId': item['placeId'],
            };
          }).toList();
          tasks.sort((a, b) => a['id'].compareTo(b['id'])); // Sortowanie po id
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
      print('Error fetching tasks: $e');
    } finally {
      client.close(); // Zamknięcie klienta
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tasks'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isError
              ? Center(
                  child: Text(
                    'Failed to load tasks.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${task['id']}'),
                      ),
                      title: Text(task['name']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailsScreen(task: task),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
