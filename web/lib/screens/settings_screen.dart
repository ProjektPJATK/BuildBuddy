import 'package:flutter/material.dart';
import 'dart:html' as html;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final token = html.window.localStorage['token'];
    final userId = html.window.localStorage['userId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: $userId', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Token:', style: TextStyle(fontSize: 18)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(token ?? 'No token found', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                html.window.localStorage.clear(); // Usuń dane logowania
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
