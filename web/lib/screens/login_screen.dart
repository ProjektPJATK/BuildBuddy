import 'package:flutter/material.dart';
import 'package:web/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final email = _emailController.text;
    final password = _passwordController.text;
    final response = await _loginService.login(email, password);
    print("Pomyślnie zalogowano");

    if (_loginService.isLoggedIn()) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Login failed: unable to verify session.';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

void _unfocus(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.unfocus();
  }
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
    },
    
    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 800,
                minHeight: 700,
                maxWidth: screenWidth < 800 ? 800 : screenWidth,
                maxHeight: screenHeight < 700 ? 700 : screenHeight,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.25),
                  child: _buildLoginCard(context),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildLoginCard(BuildContext context) {
  return Container(
    width: 400,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Build Buddy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 20),
        if (_isLoading)
          CircularProgressIndicator()
        else
          _buildLoginButton(),
        const SizedBox(height: 10),
        _buildRegistrationButton(),
      ],
    ),
  );
}

Widget _buildEmailField() {
  return TextField(
    key: ValueKey('emailField'), 
    controller: _emailController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Login',
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
    ),
  );
}

Widget _buildPasswordField() {
  return TextField(
    key: ValueKey('passwordField'),
    controller: _passwordController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: 'Hasło',
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
    ),
    obscureText: true,
  );
}

Widget _buildLoginButton() {
  return ElevatedButton(
    onPressed: _handleLogin,
    child: const Text('Zaloguj się'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    ),
  );
}

Widget _buildRegistrationButton() {
  return TextButton(
    onPressed: () {
      // Dodaj logikę dla rejestracji
    },
    child: const Text('Rejestracja'),
    style: TextButton.styleFrom(
      foregroundColor: Colors.blueAccent,
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
}