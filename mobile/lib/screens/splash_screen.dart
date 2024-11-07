import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import '../widgets/login_form.dart';
import '../styles.dart'; // Import styles

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _showLoginForm = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Call the function to check if the user is logged in
    _checkLoginStatus();
  }

  // Check if the user is already logged in by checking the stored token
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Token found, print the console message
      print('zalogowano cie debilku'); // Add your message here
      
      // If token exists, automatically navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // If no token is found, continue with the splash screen animation and show login form
      _controller.forward().then((_) {
        setState(() {
          _showLoginForm = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          // Semi-transparent filter
          Container(
            color: AppStyles.filterColor.withOpacity(0.7),
          ),
          // Logo in the center
          Center(
            child: SlideTransition(
              position: _animation,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset('assets/logo_small.png'),
              ),
            ),
          ),
          // Show the login form after animation is done, if the user is not logged in
          if (_showLoginForm)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LoginForm(onLogin: _login),
              ),
            ),
        ],
      ),
    );
  }
}
