
// import 'package:flutter/material.dart';
// import 'radius_selection_screen.dart';
// import '../../services/supabase_auth_service.dart';
// import '../../utils/app_theme.dart';
// import 'login_screen.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final nameController = TextEditingController();
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
//                   "Sign up now to access\nyour personal account",
//                   style: Theme.of(context)
//                       .textTheme
//                       .headlineSmall
//                       ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
//                 ),
//               ),
//             ),

//             // Bottom Section
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
//                             child: GestureDetector(
//                               onTap: () => Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (_) => const LoginScreen())),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   "Login",
//                                   style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
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
//                               child: Text("Sign Up",
//                                   style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
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
//                           prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

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
//                       const SizedBox(height: 24),

//                       // Sign Up Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: () async {
//                           try {
//                             final response = await SupabaseAuthService.signUp(
//                               emailController.text.trim(),
//                               passwordController.text.trim(),
//                               nameController.text.trim(),
//                             );
//                             if (response?.user != null && context.mounted) {
//   await SupabaseAuthService.syncUserProfile(); // 👈 Add this
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()),
//   );
// }

//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(e.toString())),
//                             );
//                           }
//                         },
//                         child: const Text(
//                           "Sign Up",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Google Sign-Up
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
//                           "Sign up with Google",
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Center(
//                         child: TextButton(
//                           onPressed: () => Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => const LoginScreen()),
//                           ),
//                           child: const Text("Already have an account? Login",
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
// import 'package:flutter/material.dart';
// import '../../services/supabase_auth_service.dart';
// import '../../utils/app_theme.dart';
// import 'login_screen.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final nameController = TextEditingController();
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
//             // 🟢 Header Section
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
//                       ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 22),
//                 ),
//               ),
//             ),

//             // ⚪ Bottom Section
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
//                       // 🔄 Tabs
//                       Row(
//                         children: [
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () => Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                               ),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   "Login",
//                                   style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
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
//                               child: Text("Sign Up",
//                                   style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // 🧍 Name Field
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           labelText: "Full Name",
//                           prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // 📧 Email Field
//                       TextField(
//                         controller: emailController,
//                         decoration: const InputDecoration(
//                           labelText: "Email",
//                           prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // 🔒 Password Field
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
//                               setState(() => _isPasswordVisible = !_isPasswordVisible);
//                             },
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // 🟢 Sign Up Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: _isLoading
//                             ? null
//                             : () async {
//                                 setState(() => _isLoading = true);
//                                 try {
//                                   final response = await SupabaseAuthService.signUp(
//                                     emailController.text.trim(),
//                                     passwordController.text.trim(),
//                                     nameController.text.trim(),
//                                   );

//                                   if (response?.user != null && context.mounted) {
//                                     await SupabaseAuthService.syncUserProfile();

//                                     // ✅ Show message & go to login
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                             "Account created successfully! Please log in."),
//                                       ),
//                                     );

//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(builder: (_) => const LoginScreen()),
//                                     );
//                                   }
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text(e.toString())),
//                                   );
//                                 } finally {
//                                   if (mounted) setState(() => _isLoading = false);
//                                 }
//                               },
//                         child: _isLoading
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                                 "Sign Up",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 16,
//                                     color: Colors.white),
//                               ),
//                       ),

//                       const SizedBox(height: 24),

//                       // 🔵 Google Sign Up
//                       OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 52),
//                           side: const BorderSide(color: Colors.grey),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: () async {
//                           try {
//                             await SupabaseAuthService.signInWithGoogle(context);
//                             if (context.mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text(
//                                         "Google account linked! Please log in now.")),
//                               );
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (_) => const LoginScreen()),
//                               );
//                             }
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Google Sign-up failed: $e")),
//                             );
//                           }
//                         },
//                         icon: Image.asset('assets/google icon.png', height: 24),
//                         label: const Text(
//                           "Sign up with Google",
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Center(
//                         child: TextButton(
//                           onPressed: () => Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => const LoginScreen()),
//                           ),
//                           child: const Text(
//                             "Already have an account? Login",
//                             style: TextStyle(fontWeight: FontWeight.w500),
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
// correct code above//
// import 'package:flutter/material.dart';
// import '../../services/supabase_auth_service.dart';
// import '../../utils/app_theme.dart';
// import 'login_screen.dart';
// import '../main_home_page.dart';
// import 'location_permission_screen.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final nameController = TextEditingController();
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
//             // Header Section
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
//                             child: GestureDetector(
//                               onTap: () => Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const LoginScreen()),
//                               ),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   "Login",
//                                   style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
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
//                               child: Text("Sign Up",
//                                   style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // Name Field
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           labelText: "Full Name",
//                           prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

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
//                               setState(() => _isPasswordVisible = !_isPasswordVisible);
//                             },
//                           ),
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Sign Up Button
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 52),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: _isLoading ? null : () => signupWithEmail(),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                                 "Sign Up",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 16,
//                                     color: Colors.white),
//                               ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Google Sign Up
//                       OutlinedButton.icon(
//                         style: OutlinedButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 52),
//                           side: const BorderSide(color: Colors.grey),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: _isLoading ? null : () => SupabaseAuthService.signInWithGoogle(context),
//                         icon: Image.asset('assets/google icon.png', height: 24),
//                         label: const Text(
//                           "Sign up with Google",
//                           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       Center(
//                         child: TextButton(
//                           onPressed: () => Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (_) => const LoginScreen()),
//                           ),
//                           child: const Text(
//                             "Already have an account? Login",
//                             style: TextStyle(fontWeight: FontWeight.w500),
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

//   // ---------------- SIGNUP WITH EMAIL ----------------
//   Future<void> signupWithEmail() async {
//     setState(() => _isLoading = true);
//     try {
//       final response = await SupabaseAuthService.signUp(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//         nameController.text.trim(),
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
import '../../services/supabase_auth_service.dart';
import '../../utils/app_theme.dart';
import 'login_screen.dart';
import '../main_home_page.dart';
import 'location_permission_screen.dart';

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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
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
                      ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 22),
                ),
              ),
            ),

            // Bottom White Section
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
                                    builder: (_) => const LoginScreen()),
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
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
                                  style: TextStyle(
                                      color: kGreen,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Name Field
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon:
                              Icon(Icons.person_outline, color: Colors.grey),
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
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible);
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : signupWithEmail,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Google Sign Up
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => SupabaseAuthService.signInWithGoogle(context),
                        icon: Image.asset('assets/google icon.png', height: 24),
                        label: const Text(
                          "Sign up with Google",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
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

  // ---------------- SIGNUP WITH EMAIL ----------------
  Future<void> signupWithEmail() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseAuthService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
      );

      final user = response?.user;
      if (user != null && context.mounted) {
        await SupabaseAuthService.syncUserProfile();

        // ✅ New user always goes to LocationPermissionScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
