import 'package:flutter/material.dart';

class EmployeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
      ),
      body: Center(
        child: Text('Manage Employees'),
      ),
    );
  }
}
