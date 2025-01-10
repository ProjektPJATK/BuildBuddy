import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/profile/models/user_model.dart';
import 'package:mobile/features/register/views/widgets/phone_number_field.dart';
import 'package:mobile/features/register/views/widgets/styled_text_field.dart';
import 'package:mobile/shared/themes/styles.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rejestracja zakończona pomyślnie!')),
            );
            Navigator.pop(context);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneNrController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedCountryCode = '+48';

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  const Text('Zarejestruj się', style: AppStyles.formTitleStyle),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        StyledTextField(
                          controller: _nameController,
                          labelText: 'Imię',
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _surnameController,
                          labelText: 'Nazwisko',
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _emailController,
                          labelText: 'Adres e-mail',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        PhoneNumberField(
                          controller: _telephoneNrController,
                          selectedCountryCode: _selectedCountryCode,
                          onCountryCodeChanged: (code) {
                            setState(() {
                              _selectedCountryCode = code;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _passwordController,
                          labelText: 'Hasło',
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Powtórz hasło',
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                          style: AppStyles.buttonStyle(),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final user = User(
                                id: 0,  // Domyślne id, bo serwer je nadaje automatycznie
                                name: _nameController.text,
                                surname: _surnameController.text,
                                email: _emailController.text,
                                telephoneNr: '$_selectedCountryCode${_telephoneNrController.text}',
                                password: _passwordController.text,
                                userImageUrl: "string",  // Opcjonalne
                                preferredLanguage: "pl",    // Opcjonalne
                              );

                              context.read<RegisterBloc>().add(RegisterSubmitted(user));
                            }
                          },
                          child: const Text('ZAREJESTRUJ'),
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
