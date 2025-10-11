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
// import 'package:flutter/material.dart';
// // import 'signup_screen.dart';
// import 'location_permission_screen.dart';
// import 'forgot_password_screen.dart';
// import '../../utils/app_theme.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
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
//               const SizedBox(height: 0),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
//                   },
//                   child: const Text("Forgot Password?"),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: kGreen,
//                     minimumSize: const Size(double.infinity, 48)),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const LocationPermissionScreen()));
//                 },
//                 child: const Text("Login"),
//               ),
//               const SizedBox(height: 20),
//               _googleButton(),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   // Navigator.push(context,
//                   //     MaterialPageRoute(builder: (_) => const SignupScreen()));
//                 },
//                 child: const Text("Don’t have an account? Sign up"),
//               ),
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
//         // later you’ll add Google sign-in logic here
//       },
//       icon: Image.asset('assets/google icon.png', height: 24),
//       label: const Text("Continue with Google",
//           style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_auth_service.dart';
// import 'location_permission_screen.dart';
// import 'signup_screen.dart';
// import 'forgot_password_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool isLoading = false;

//   void _login() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("All fields required")));
//       return;
//     }

//     setState(() => isLoading = true);
//     try {
//       await SupabaseAuthService.login(
//           emailController.text, passwordController.text);
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (_) => const LocationPermissionScreen()));
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Login failed: $e")));
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
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 40),
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
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const ForgotPasswordScreen()));
//                   },
//                   child: const Text("Forgot Password?"),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: kGreen,
//                     minimumSize: const Size(double.infinity, 48)),
//                 onPressed: isLoading ? null : _login,
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Login"),
//               ),
//               const SizedBox(height: 20),
//               OutlinedButton.icon(
//                 onPressed: () async {
//                    await SupabaseAuthService.signInWithGoogle(context);
//                 },
//                 icon: Image.asset('assets/google icon.png', height: 24),
//                 label: const Text("Continue with Google"),
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (_) => const SignupScreen()));
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
// import 'package:flutter/material.dart';
// import 'signup_screen.dart';
// import 'location_permission_screen.dart';
// import 'forgot_password_screen.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_auth_service.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
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
//                 "Welcome Back",
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 20),

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
//               const SizedBox(height: 8),

//               // Forgot Password
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const ForgotPasswordScreen(),
//                       ),
//                     );
//                   },
//                   child: const Text("Forgot Password?"),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // Login Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   minimumSize: const Size(double.infinity, 48),
//                 ),
//                 onPressed: () async {
//                   try {
//                     final response = await SupabaseAuthService.login(
//                       emailController.text.trim(),
//                       passwordController.text.trim(),
//                     );

//                     if (response?.user != null && context.mounted) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const LocationPermissionScreen(),
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text(e.toString())),
//                     );
//                   }
//                 },
//                 child: const Text("Login"),
//               ),

//               const SizedBox(height: 20),

//               // Google Sign-In Button
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
//                   "Continue with Google",
//                   style: TextStyle(
//                     color: kTextDark,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Navigate to Signup
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const SignupScreen(),
//                     ),
//                   );
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
// import 'package:flutter/material.dart';
// import 'signup_screen.dart';
// import 'location_permission_screen.dart';
// import 'forgot_password_screen.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_auth_service.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
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
//                   "Go ahead and complete\nyour account and setup",
//                   style: Theme.of(context)
//                       .textTheme
//                       .headlineSmall
//                       ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600,fontSize: 22),
//                 ),
//               ),
//             ),

//             // White Card Section (full bottom part)
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
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                 color: kGreen.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 "Login",
//                                 style: TextStyle(
//                                   color: kGreen,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => const SignupScreen(),
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
//                                   "Sign Up",
//                                   style: TextStyle(
//                                     color: Colors.black54,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

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

//                       const SizedBox(height: 8),

//                       // Forgot Password
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const ForgotPasswordScreen(),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Forgot Password?",
//                             style: TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Login Button
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
//                             final response = await SupabaseAuthService.login(
//                               emailController.text.trim(),
//                               passwordController.text.trim(),
//                             );

//                             if (response?.user != null && context.mounted) {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       const LocationPermissionScreen(),
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
//                           "Login",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                             color: Colors.white
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Google Sign-In Button
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
//                           "Continue with Google",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Navigate to Signup
//                       Center(
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const SignupScreen(),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Don’t have an account? Sign up",
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
import 'signup_screen.dart';
import 'location_permission_screen.dart';
import 'forgot_password_screen.dart';
import '../../utils/app_theme.dart';
import '../../services/supabase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  "Go ahead and complete\nyour account and setup",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
                ),
              ),
            ),

            // White Bottom Section
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: kGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Login",
                                style: TextStyle(color: kGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SignupScreen())),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text("Forgot Password?",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Login Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          try {
                            final response = await SupabaseAuthService.login(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                            if (response?.user != null && context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LocationPermissionScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Google Sign In
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
                          "Continue with Google",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: const Text("Don’t have an account? Sign up",
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
