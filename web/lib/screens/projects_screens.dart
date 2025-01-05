import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'projectdetails_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> places = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('http://localhost:5007/api/place'));
      request.headers.set('Accept', 'application/json');
      request.headers.set('Authorization', 'Bearer YOUR_TOKEN_HERE'); // Podaj token

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);

        if (mounted) {
          setState(() {
            places = data.map((item) {
              return {
                'id': item['id'],
                'address': item['address'],
              };
            }).toList();
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
      print('Error fetching places: $e');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? const Center(
                  child: Text(
                    'Failed to load projects.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(place['id'].toString()),
                      ),
                      title: Text(place['address']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsScreen(project: place),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
