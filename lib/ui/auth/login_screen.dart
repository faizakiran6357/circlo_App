
// import 'package:flutter/material.dart';
// import 'signup_screen.dart';
// import 'location_permission_screen.dart';
// import 'forgot_password_screen.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_auth_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool _isPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kGreen,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top Header
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
//                       ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
//                 ),
//               ),
//             ),

//             // White Bottom Section
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
//                       // Tabs
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
//                                 style: TextStyle(color: kGreen, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => Navigator.push(context,
//                                   MaterialPageRoute(builder: (_) => const SignupScreen())),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   "Sign Up",
//                                   style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
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
//                           prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Password Field
//                       TextField(
//                         controller: passwordController,
//                         obscureText: !_isPasswordVisible,
//                         decoration: InputDecoration(
//                           labelText: "Password",
//                           prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                               color: Colors.grey,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _isPasswordVisible = !_isPasswordVisible;
//                               });
//                             },
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
//                           ),
//                           child: const Text("Forgot Password?",
//                               style: TextStyle(fontWeight: FontWeight.w500)),
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // Login Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: () async {
//                           try {
//                             final response = await SupabaseAuthService.login(
//                               emailController.text.trim(),
//                               passwordController.text.trim(),
//                             );
//                             if (response?.user != null && context.mounted) {
//   await SupabaseAuthService.syncUserProfile(); // 👈 Add this line
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (_) => const LocationPermissionScreen(),
//     ),
//   );
// }

//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(e.toString())),
//                             );
//                           }
//                         },
//                         child: const Text(
//                           "Login",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Google Sign In
//                       OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 52),
//                           side: const BorderSide(color: Colors.grey),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: () async {
//                           await SupabaseAuthService.signInWithGoogle(context);
//                         },
//                         icon: Image.asset('assets/google icon.png', height: 24),
//                         label: const Text(
//                           "Continue with Google",
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Center(
//                         child: TextButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => const SignupScreen()),
//                           ),
//                           child: const Text("Don’t have an account? Sign up",
//                               style: TextStyle(fontWeight: FontWeight.w500)),
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
// correct code above//
// import 'package:flutter/material.dart';
// import 'signup_screen.dart';
// import 'location_permission_screen.dart';
// import 'forgot_password_screen.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_auth_service.dart';
// import '../main_home_page.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kGreen,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top Header
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
//                       ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
//                 ),
//               ),
//             ),

//             // Bottom White Section
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
//                       // Tabs
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
//                                 style: TextStyle(color: kGreen, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(builder: (_) => const SignupScreen())),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   "Sign Up",
//                                   style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // Email & Password Fields
//                       TextField(
//                         controller: emailController,
//                         decoration: const InputDecoration(
//                           labelText: "Email",
//                           prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: passwordController,
//                         obscureText: !_isPasswordVisible,
//                         decoration: InputDecoration(
//                           labelText: "Password",
//                           prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                               color: Colors.grey,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _isPasswordVisible = !_isPasswordVisible;
//                               });
//                             },
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 8),

//                       // Forgot Password
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
//                           ),
//                           child: const Text("Forgot Password?",
//                               style: TextStyle(fontWeight: FontWeight.w500)),
//                         ),
//                       ),

//                       const SizedBox(height: 12),

//                       // Login Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: _isLoading ? null : () => loginWithEmail(),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                                 "Login",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
//                               ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Google Login Button
//                       OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 52),
//                           side: const BorderSide(color: Colors.grey),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: _isLoading ? null : () => SupabaseAuthService.signInWithGoogle(context),
//                         icon: Image.asset('assets/google icon.png', height: 24),
//                         label: const Text(
//                           "Continue with Google",
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Center(
//                         child: TextButton(
//                           onPressed: () => Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => const SignupScreen()),
//                           ),
//                           child: const Text("Don’t have an account? Sign up",
//                               style: TextStyle(fontWeight: FontWeight.w500)),
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

//   // ---------------- LOGIN WITH EMAIL ----------------
//   Future<void> loginWithEmail() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await SupabaseAuthService.login(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//       );

//       final user = response?.user;
//       if (user != null && context.mounted) {
//         await SupabaseAuthService.syncUserProfile();

//         // check radius_km
//         final profile = await SupabaseAuthService.supabase
//             .from('users')
//             .select('radius_km')
//             .eq('id', user.id)
//             .maybeSingle();

//         if (profile == null || profile['radius_km'] == null) {
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
//         } else {
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (_) => const MainHomePage()));
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'location_permission_screen.dart';
import 'forgot_password_screen.dart';
import '../../utils/app_theme.dart';
import '../../services/supabase_auth_service.dart';
import '../main_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                      ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 22),
                ),
              ),
            ),

            // White bottom section
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
                                style: TextStyle(
                                    color: kGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignupScreen())),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Email
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text("Forgot Password?",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Login button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : loginWithEmail,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Google login
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed:
                            _isLoading ? null : () => SupabaseAuthService.signInWithGoogle(context),
                        icon: Image.asset('assets/google icon.png', height: 24),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
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

  // ---------------- LOGIN WITH EMAIL ----------------
  Future<void> loginWithEmail() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseAuthService.login(
          emailController.text.trim(), passwordController.text.trim());

      final user = response?.user;
      if (user != null && context.mounted) {
        await SupabaseAuthService.syncUserProfile();

        // Check if new user → radius_km null
        final profile = await SupabaseAuthService.supabase
            .from('users')
            .select('radius_km')
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null || profile['radius_km'] == null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const LocationPermissionScreen()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MainHomePage()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
