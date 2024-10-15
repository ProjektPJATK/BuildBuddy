import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginForm({super.key, required this.onLogin});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Determine the correct backend URL based on the platform
  String getBackendUrl() {
    const backendIP = "10.0.2.2"; // For Android emulator, replace with machine IP for physical devices
    const backendPort = "5007"; // Port of your backend

    return "http://$backendIP:$backendPort/api/User/login"; // Adjusted endpoint
  }

  // Perform login and save token to SharedPreferences
  Future<void> _login(BuildContext context) async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show a loading indicator while the request is in progress
    });

    try {
      final url = getBackendUrl();

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(<String, String>{
          'email': login,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Check if token is valid (basic validation)
        if (token.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token); // Save the token in SharedPreferences

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );

          widget.onLogin(); // Call onLogin callback after successful login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid token received.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Remove loading indicator after the request is completed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Login TextField
        _buildStyledTextField(
          controller: _loginController,
          labelText: 'Login',
        ),
        const SizedBox(height: 16),

        // Password TextField
        _buildStyledTextField(
          controller: _passwordController,
          labelText: 'Hasło',
          obscureText: true,
        ),
        const SizedBox(height: 32),

        // Login Button or Loading Indicator
        _isLoading
            ? const CircularProgressIndicator() // Show loading indicator if request is ongoing
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  foregroundColor: Colors.white, // White text color
                  side: const BorderSide(color: Colors.white), // White border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // More rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () => _login(context), // Trigger login logic
                child: const Text('ZALOGUJ SIĘ'),
              ),
        const SizedBox(height: 16),

        // Don't have an account? Register
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            'Nie masz konta? Zarejestruj się',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Reusable method for styled text field creation
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white), // White text color
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white54), // Label text style
        fillColor: Colors.transparent, // Fully transparent background
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54), // Light white border when enabled
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white), // Solid white border when focused
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
        ),
      ),
    );
  }
}
