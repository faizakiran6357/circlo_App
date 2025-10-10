import 'package:circlo_app/ui/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'ui/auth/onboarding_screen.dart';

// later you'll import supabase and other services, but not yet for frontend-only phase

void main() {
  runApp(const CircloApp());
}

class CircloApp extends StatelessWidget {
  const CircloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circlo',
      debugShowCheckedModeBanner: false,
      theme: circloTheme,
      home: const OnboardingScreen(),
    );
  }
}
