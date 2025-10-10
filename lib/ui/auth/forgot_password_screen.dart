import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: kGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset, size: 100, color: kTeal),
            const SizedBox(height: 24),
            Text(
              "Enter your registered email to reset your password.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Reset link sent to your email! (mock frontend only)"),
                  ),
                );
              },
              child: const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
