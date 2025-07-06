import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/notes');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 120,
                height: 120,
                child: FlutterLogo(
                  size: 120,
                  style: isDark ? FlutterLogoStyle.markOnly : FlutterLogoStyle.horizontal,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
              backgroundColor: isDark
                  ? theme.colorScheme.onSurface.withAlpha(51) // ~0.2 opacity
                  : theme.colorScheme.primary.withAlpha(77),  // ~0.3 opacity
            ),
          ],
        ),
      ),
    );
  }
}
