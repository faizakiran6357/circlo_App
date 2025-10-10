// import 'package:flutter/material.dart';
// // import 'signup_screen.dart';
// import 'location_permission_screen.dart';
// import '../../utils/app_theme.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Welcome Back", style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password"),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: kGreen,
//                     minimumSize: const Size(double.infinity, 48)),
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (_) => const LocationPermissionScreen()));
//                 },
//                 child: const Text("Login"),
//               ),
//               const SizedBox(height: 12),
//               TextButton(
//                 onPressed: () {
//                   // Navigator.push(context,
//                   //     MaterialPageRoute(builder: (_) => const SignupScreen()
//                   //     ));
//                 },
//                 child: const Text("Don’t have an account? Sign up"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
// import 'signup_screen.dart';
import 'location_permission_screen.dart';
import 'forgot_password_screen.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text("Welcome Back", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    minimumSize: const Size(double.infinity, 48)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LocationPermissionScreen()));
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 20),
              _googleButton(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_) => const SignupScreen()));
                },
                child: const Text("Don’t have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        // later you’ll add Google sign-in logic here
      },
      icon: Image.asset('assets/google icon.png', height: 24),
      label: const Text("Continue with Google",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
    );
  }
}
