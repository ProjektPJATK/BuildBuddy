import 'package:flutter/material.dart';
import 'employees_screen.dart';
import 'projects_screens.dart';
import 'reports_screens.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 800,
              minHeight: 700,
              maxWidth: screenWidth < 800 ? 800 : screenWidth,
              maxHeight: screenHeight < 700 ? 700 : screenHeight,
            ),
            child: Container(
              color: Colors.grey[800],
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Image.asset(
                      'assets/logo.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 80,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                          onPressed: () {
                            // Navigation to settings screen if required
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white, size: 32),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 120.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EmployeesScreen()),
                            ),
                            child: _buildButton(context, 'Employees', Icons.people, Colors.blue),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TasksScreen()),
                            ),
                            child: _buildButton(context, 'Tasks', Icons.task, Colors.green),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProjectsScreen()),
                            ),
                            child: _buildButton(context, 'Projects', Icons.apartment, Colors.orange),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportsScreen()),
                            ),
                            child: _buildButton(context, 'Reports', Icons.report, Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * 0.6,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/homeback.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
