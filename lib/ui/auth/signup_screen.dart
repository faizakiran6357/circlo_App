// import 'package:flutter/material.dart';
// import 'radius_selection_screen.dart';
// import '../../utils/app_theme.dart';

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final name = TextEditingController();
//     final email = TextEditingController();
//     final password = TextEditingController();

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Text("Create Account", style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 24),
//               TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
//               const SizedBox(height: 12),
//               TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: password,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password"),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: kGreen,
//                     minimumSize: const Size(double.infinity, 48)),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()));
//                 },
//                 child: const Text("Sign Up"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'radius_selection_screen.dart';
import '../../utils/app_theme.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text("Create Account", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 12),
              TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    minimumSize: const Size(double.infinity, 48)),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()));
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 20),
              _googleButton(),
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
        // later add Google sign-in backend logic here
      },
      icon: Image.asset('assets/google icon.png', height: 24),
      label: const Text("Sign up with Google",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
    );
  }
}
