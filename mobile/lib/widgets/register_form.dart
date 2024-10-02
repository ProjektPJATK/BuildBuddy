import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final VoidCallback onRegister;

  RegisterForm({super.key, required this.onRegister});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Adjust padding when keyboard is visible
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username TextField
              _buildStyledTextField(
                controller: _usernameController,
                labelText: 'Nazwa użytkownika',
              ),
              const SizedBox(height: 16),

              // Email TextField
              _buildStyledTextField(
                controller: _emailController,
                labelText: 'Adres e-mail',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password TextField
              _buildStyledTextField(
                controller: _passwordController,
                labelText: 'Hasło',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Confirm Password TextField
              _buildStyledTextField(
                controller: _confirmPasswordController,
                labelText: 'Powtórz hasło',
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Register Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  foregroundColor: Colors.white, // White text color
                  side: const BorderSide(color: Colors.white), // White border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // More rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  // Perform register logic and call onRegister if successful
                  onRegister();
                },
                child: const Text('ZAREJESTRUJ'),
              ),
              const SizedBox(height: 16),

              // Already have an account? Log in
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'Masz już konto? Zaloguj się',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'To pole nie może być puste';
        }
        return null;
      },
    );
  }
}
