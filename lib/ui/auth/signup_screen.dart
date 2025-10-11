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
//                   Navigator.pushReplacement(context,
//                       MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()));
//                 },
//                 child: const Text("Sign Up"),
//               ),
//               const SizedBox(height: 20),
//               _googleButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _googleButton() {
//     return OutlinedButton.icon(
//       style: OutlinedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 48),
//         side: const BorderSide(color: Colors.grey),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: () {
//         // later add Google sign-in backend logic here
//       },
//       icon: Image.asset('assets/google icon.png', height: 24),
//       label: const Text("Sign up with Google",
//           style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'radius_selection_screen.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_auth_service.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool isLoading = false;

//   void _signUp() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("All fields required")));
//       return;
//     }
//     setState(() => isLoading = true);

//     try {
//       await SupabaseAuthService.signUp(
//         emailController.text,
//         passwordController.text,
//         nameController.text,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Signup successful! Verify your email.")));

//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()));
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Text("Create Account", style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 24),
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Name"),
//               ),
//               const SizedBox(height: 12),
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
//                 onPressed: isLoading ? null : _signUp,
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Sign Up"),
//               ),
//               const SizedBox(height: 20),
//               OutlinedButton.icon(
//                 onPressed: () async {
//                    await SupabaseAuthService.signInWithGoogle(context);
//                 },
//                 icon: Image.asset('assets/google icon.png', height: 24),
//                 label: const Text("Sign up with Google"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'radius_selection_screen.dart';
// import '../../services/supabase_auth_service.dart';
// import '../../utils/app_theme.dart';

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final nameController = TextEditingController();
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 40),
//               Text(
//                 "Create Account",
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 24),

//               // Name Field
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Full Name"),
//               ),
//               const SizedBox(height: 12),

//               // Email Field
//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//               ),
//               const SizedBox(height: 12),

//               // Password Field
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password"),
//               ),
//               const SizedBox(height: 24),

//               // Sign Up Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   minimumSize: const Size(double.infinity, 48),
//                 ),
//                 onPressed: () async {
//                   try {
//                     final response = await SupabaseAuthService.signUp(
//                       emailController.text.trim(),
//                       passwordController.text.trim(),
//                       nameController.text.trim(),
//                     );

//                     if (response?.user != null && context.mounted) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const RadiusSelectionScreen(),
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(e.toString())),
//                     );
//                   }
//                 },
//                 child: const Text("Sign Up"),
//               ),

//               const SizedBox(height: 20),

//               // Google Sign-Up Button
//               OutlinedButton.icon(
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 48),
//                   side: const BorderSide(color: Colors.grey),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () async {
//                   await SupabaseAuthService.signInWithGoogle(context);
//                 },
//                 icon: Image.asset('assets/google icon.png', height: 24),
//                 label: const Text(
//                   "Sign up with Google",
//                   style: TextStyle(
//                     color: kTextDark,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'radius_selection_screen.dart';
// import '../../services/supabase_auth_service.dart';
// import '../../utils/app_theme.dart';
// import 'login_screen.dart';

// class SignupScreen extends StatelessWidget {
//   const SignupScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final nameController = TextEditingController();
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();

//     return Scaffold(
//       backgroundColor: kGreen,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top Green Header Section
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
//               color: kGreen,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Sign up now to access\nyour personal account",
//                   style: Theme.of(context)
//                       .textTheme
//                       .headlineSmall
//                       ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600,fontSize: 22),
//                 ),
//               ),
//             ),

//             // White Bottom Section (Full Card)
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(28),
//                     topRight: Radius.circular(28),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Tabs (Login / Sign Up)
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => const LoginScreen(),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   "Login",
//                                   style: TextStyle(
//                                     color: Colors.black54,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: kGreen.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 "Sign Up",
//                                 style: TextStyle(
//                                   color: kGreen,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // Full Name Field
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           labelText: "Full Name",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Email Field
//                       TextField(
//                         controller: emailController,
//                         decoration: const InputDecoration(
//                           labelText: "Email",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Password Field
//                       TextField(
//                         controller: passwordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: "Password",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Sign Up Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () async {
//                           try {
//                             final response = await SupabaseAuthService.signUp(
//                               emailController.text.trim(),
//                               passwordController.text.trim(),
//                               nameController.text.trim(),
//                             );

//                             if (response?.user != null && context.mounted) {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => const RadiusSelectionScreen(),
//                                 ),
//                               );
//                             }
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(e.toString())),
//                             );
//                           }
//                         },
//                         child: const Text(
//                           "Sign Up",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                             color: Colors.white
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Google Sign-Up Button
//                       OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 52),
//                           side: const BorderSide(color: Colors.grey),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () async {
//                           await SupabaseAuthService.signInWithGoogle(context);
//                         },
//                         icon: Image.asset('assets/google icon.png', height: 24),
//                         label: const Text(
//                           "Sign up with Google",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Navigate to Login
//                       Center(
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const LoginScreen(),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Already have an account? Login",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'radius_selection_screen.dart';
import '../../services/supabase_auth_service.dart';
import '../../utils/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              color: kGreen,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sign up now to access\nyour personal account",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
                ),
              ),
            ),

            // Bottom Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen())),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: kGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text("Sign Up",
                                  style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Full Name Field
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          try {
                            final response = await SupabaseAuthService.signUp(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              nameController.text.trim(),
                            );

                            if (response?.user != null && context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Google Sign-Up
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          await SupabaseAuthService.signInWithGoogle(context);
                        },
                        icon: Image.asset('assets/google icon.png', height: 24),
                        label: const Text(
                          "Sign up with Google",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: const Text("Already have an account? Login",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
