import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles.dart'; // Assuming you have AppStyles in a separate file

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegister;

  RegisterScreen({super.key, required this.onRegister});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneNrController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false;

  // URL for your backend registration
  String getBackendUrl() {
    const backendIP = "10.0.2.2"; // For Android emulator, replace with machine IP for physical devices
    const backendPort = "5007"; // Port of your backend
    return "http://$backendIP:$backendPort/api/User/register";
  }

  // Function to perform registration and connect to backend
  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final url = getBackendUrl();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({
          "id": 0,
          "name": _nameController.text,
          "surname": _surnameController.text,
          "mail": _emailController.text,
          "telephoneNr": int.tryParse(_telephoneNrController.text) ?? 0,
          "password": _passwordController.text,
          "userImageUrl": "string",
          "teamId": 0
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If registration is successful, navigate back to the previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        // Show error message if registration fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Remove loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: AppStyles.backgroundDecoration, // Apply background from AppStyles
          ),
          // Dark Filter on top of the background
          Container(
            color: AppStyles.filterColor.withOpacity(0.75), // Dark overlay
          ),
          // Form content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50), // Space at the top

                    // Form Title
                    const Text(
                      'Zarejestruj się',
                      style: AppStyles.formTitleStyle, // Form title style from AppStyles
                    ),
                    const SizedBox(height: 30),

                    // Form Fields inside a Form widget for validation
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name TextField
                          _buildStyledTextField(
                            controller: _nameController,
                            labelText: 'Imię',
                          ),
                          const SizedBox(height: 12),

                          // Surname TextField
                          _buildStyledTextField(
                            controller: _surnameController,
                            labelText: 'Nazwisko',
                          ),
                          const SizedBox(height: 12),

                          // Email TextField
                          _buildStyledTextField(
                            controller: _emailController,
                            labelText: 'Adres e-mail',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          // Telephone Number TextField
                          _buildStyledTextField(
                            controller: _telephoneNrController,
                            labelText: 'Numer telefonu',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),

                          // Password TextField
                          _buildStyledTextField(
                            controller: _passwordController,
                            labelText: 'Hasło',
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password TextField
                          _buildStyledTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Powtórz hasło',
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Button
                    _isLoading
                        ? const CircularProgressIndicator() // Show loading indicator if request is ongoing
                        : ElevatedButton(
                            style: AppStyles.buttonStyle(), // Use button style from AppStyles
                            onPressed: () => _register(context),
                            child: const Text('ZAREJESTRUJ'),
                          ),
                    const SizedBox(height: 16),

                    // Already have an account? Log in
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to the previous screen
                      },
                      style: AppStyles.textButtonStyle(), // TextButton style from AppStyles
                      child: const Text(
                        'Masz już konto? Zaloguj się',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable method for styled text field creation (using inputFieldStyle from AppStyles)
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white), // White text color
        decoration: AppStyles.inputFieldStyle(hintText: labelText),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'To pole jest wymagane'; // "This field is required"
          }
          return null;
        },
      ),
    );
  }
}
