import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import '../widgets/login_form.dart';

class SplashScreen extends StatefulWidget {
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
      end: Offset(0, -1.8),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      setState(() {
        _showLoginForm = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() {
    // Replace with actual login logic
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Tło
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Filtr
          Container(
            color: Colors.black.withOpacity(0.9),
          ),
          // Logo na środku
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
          // Formularz logowania
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
