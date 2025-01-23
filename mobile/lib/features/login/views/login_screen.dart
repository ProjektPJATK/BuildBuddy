import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/login/bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import 'widgets/login_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/themes/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
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
          // Content with scrollable behavior
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 20),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/logo_small.png'),
                    ),
                  ),
                  // Login Form
                  BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (state is LoginFailure) {
                        // Handle specific error messages
                        String errorMessage = 'Login Failed';
                        if (state.error.contains('incorrect password')) {
                          errorMessage = 'Incorrect password. Please try again.';
                        } else if (state.error.contains('email not found')) {
                          errorMessage = 'No account found for this email.';
                        } else if (state.error.contains('invalid email')) {
                          errorMessage = 'Invalid email format.';
                        } else {
                          errorMessage = state.error;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: const Color.fromARGB(255, 43, 42, 42),
                          ),
                          
                        );
                      }
                    },
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        return LoginForm(
                          isLoading: state is LoginLoading,
                          onLogin: (email, password) {
                            context.read<LoginBloc>().add(
                                  LoginSubmitted(email: email, password: password),
                                );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
