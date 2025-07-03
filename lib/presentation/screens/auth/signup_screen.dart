import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String _passwordStrength = '';

  void _updatePasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
      } else if (password.length < 6) {
        _passwordStrength = 'Too short';
      } else if (password.length < 8) {
        _passwordStrength = 'Weak';
      } else if (!RegExp(r'[A-Z]').hasMatch(password) ||
          !RegExp(r'[0-9]').hasMatch(password)) {
        _passwordStrength = 'Medium';
      } else {
        _passwordStrength = 'Strong';
      }
    });
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
      case 'Too short':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  void _signup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignUpRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Signup Successful"), backgroundColor: Colors.green),
            );
            Navigator.pushReplacementNamed(context, '/notes');
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: _updatePasswordStrength,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        if (_passwordStrength.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Strength: ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  _passwordStrength,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStrengthColor(_passwordStrength),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        state is AuthLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _signup(context),
                                  child: const Text("Sign Up"),
                                ),
                              ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text("Already have an account? Login"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
