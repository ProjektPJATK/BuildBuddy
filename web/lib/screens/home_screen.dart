import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web/screens/teams_screen.dart';
import 'projects_screens.dart';
import 'reports_screens.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

int? getLoggedInUserId() {
  final userId = html.window.localStorage['userId'];
  return userId != null ? int.tryParse(userId) : null;
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    html.window.onPopState.listen((event) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        html.window.history.pushState(null, '', '/home');
        print('Cofanie do logowania zablokowane.');
      }
    });
  }

  void _logout(BuildContext context) {
    print('Logging out user.');
    html.document.cookie = 'userToken=; path=/; max-age=0';
    html.window.localStorage.remove('userToken');
    html.window.localStorage.remove('userId');
    html.window.localStorage.remove('powerLevel');
    Navigator.pushReplacementNamed(context, '/');
  }

  void checkLoginState(BuildContext context) {
    final cookies = html.document.cookie?.split('; ') ?? [];
    final isLoggedIn = cookies.any((cookie) => cookie.startsWith('userToken='));

    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLoginState(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        print('Cofanie do logowania zablokowane przez WillPopScope.');
        return false;
      },
      child: Scaffold(
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
                        'lib/assets/logo.png',
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
                            icon: Icon(Icons.settings, color: Colors.white, size: 32),
                            onPressed: () {
                              // Navigation to settings screen if required
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: Colors.white, size: 32),
                            onPressed: () => _logout(context),
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
                              onTap: () {
                                final loggedInUserId = getLoggedInUserId();
                                if (loggedInUserId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeamsScreen(loggedInUserId: loggedInUserId),
                                    ),
                                  );
                                } else {
                                  print('Error: Logged in user ID not found: $loggedInUserId');
                                }
                              },
                              child: _buildButton(
                                context,
                                'Teams and Projects',
                                Icons.people, // Ikonka ludzi
                                Icons.apartment, // Ikonka budynku
                                const Color.fromARGB(87, 61, 70, 192),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TasksScreen()),
                              ),
                              child: _buildButton(
                                context,
                                'Tasks',
                                Icons.task,
                                null,
                                const Color.fromARGB(36, 38, 132, 209),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProjectsScreen()),
                              ),
                              child: _buildButton(
                                context,
                                'Inventory',
                                Icons.inventory,
                                null,
                                const Color.fromARGB(106, 33, 149, 243),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReportsScreen()),
                              ),
                              child: _buildButton(
                                context,
                                'Reports',
                                Icons.report,
                                null,
                                const Color.fromARGB(255, 76, 135, 175),
                              ),
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
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/assets/homeback.png'),
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
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData mainIcon,
    IconData? secondaryIcon,
    Color color,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mainIcon, size: 32, color: Colors.white),
              if (secondaryIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(secondaryIcon, size: 32, color: Colors.white),
                ),
            ],
          ),
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
