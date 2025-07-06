import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'package:note_app/utils/local_auth_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthHelper _authHelper = LocalAuthHelper();
  final _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await _authHelper.canCheckBiometrics();
    if (!mounted) return;
    setState(() {
      _canUseBiometrics = available;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final success = await _authHelper.authenticate();
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric authentication failed.")),
      );
      return;
    }

    final email = await _secureStorage.read(key: 'email');
    final password = await _secureStorage.read(key: 'password');

    if (!mounted) return;

    if (email == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No saved credentials. Log in manually first.")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/notes');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase login failed: ${e.toString()}")),
      );
    }
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await _secureStorage.write(key: 'email', value: email);
      await _secureStorage.write(key: 'password', value: password);

      if (!context.mounted) return;
      context.read<AuthBloc>().add(SignInRequested(email, password));
    }
  }

  void _showForgotPasswordModal() {
    final resetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: resetController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Enter your email",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isEmpty || !email.contains("@")) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid email.")),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Reset link sent to $email")),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: const Text("Send Link"),
          ),
        ],
      ),
    );
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
              const SnackBar(content: Text("Login Successful"), backgroundColor: Colors.green),
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
                        const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                            if (value == null || value.isEmpty) return "Email is required";
                            final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            return regex.hasMatch(value) ? null : "Enter a valid email";
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordModal,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerRight,
                            ),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (state is AuthLoading)
                          const CircularProgressIndicator()
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _login(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: const Text("Log In"),
                            ),
                          ),

                          if (_canUseBiometrics) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                Expanded(child: Divider(thickness: 1)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text("or"),
                                ),
                                Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _authenticateWithBiometrics,
                                icon: const Icon(Icons.fingerprint),
                                label: const Text("Use Fingerprint"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ],

                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: const Text("Don't have an account? Sign up"),
                        ),
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
