import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final VoidCallback onLogin;

  LoginForm({super.key, required this.onLogin});

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _loginController,
          decoration: const InputDecoration(
            hintText: 'Login',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Hasło',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Perform login logic and call onLogin if successful
            onLogin();
          },
          child: const Text('Zaloguj się'),
        ),
        const SizedBox(height: 16),
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
}
