import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart'; // Import the country_picker package
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
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedCountryCode = '+48'; // Default country code

  String getBackendUrl() {
    const backendIP = "10.0.2.2";
    const backendPort = "5007";
    return "http://$backendIP:$backendPort/api/User/register";
  }

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      } else {
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Zarejestruj się',
                      style: AppStyles.formTitleStyle,
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildStyledTextField(
                            controller: _nameController,
                            labelText: 'Imię',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'To pole jest wymagane';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildStyledTextField(
                            controller: _surnameController,
                            labelText: 'Nazwisko',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'To pole jest wymagane';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildStyledTextField(
                            controller: _emailController,
                            labelText: 'Adres e-mail',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'To pole jest wymagane';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Wpisz poprawny adres e-mail';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildPhoneNumberField(),
                          const SizedBox(height: 12),
                          _buildStyledTextField(
                            controller: _passwordController,
                            labelText: 'Hasło',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'To pole jest wymagane';
                              } else if (value.length < 8) {
                                return 'Hasło musi mieć co najmniej 8 znaków';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildStyledTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Powtórz hasło',
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'To pole jest wymagane';
                              } else if (value != _passwordController.text) {
                                return 'Hasła muszą być takie same';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: AppStyles.buttonStyle(),
                            onPressed: () => _register(context),
                            child: const Text('ZAREJESTRUJ'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: AppStyles.textButtonStyle(),
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

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: AppStyles.inputFieldStyle(hintText: labelText),
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Padding(
      
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountryCode = '+${country.phoneCode}';
                  });
                },
              );
            },
            child: Container(
              
              height: 56, // Match the height of the TextFormField
              width: 70, // Width to match the design proportionally
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                
                color: Colors.transparent, // Ensures it matches the background
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20), // Same corner radius as TextFormField
              ),
              child: Center(
                child: Text(
                  _selectedCountryCode,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _telephoneNrController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: AppStyles.inputFieldStyle(hintText: 'Numer telefonu'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'To pole jest wymagane';
                } else if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value)) {
                  return 'Wpisz poprawny numer telefonu';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
