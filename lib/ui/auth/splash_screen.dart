// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';
// import 'onboarding_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     // 🔹 Simple fade-in animation
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//     _controller.forward();

//     // 🔹 Navigate to Onboarding after delay
//     Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _animation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // 🌿 Circular animation design
//               Container(
//                 height: 110,
//                 width: 110,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [kGreen, kTeal],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: const Center(
//                   child: Icon(Icons.recycling_rounded,
//                       color: Colors.white, size: 60),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // App name
//               Text(
//                 "Circlo",
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: kTextDark,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Share. Exchange. Connect.",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: kTextDark.withOpacity(0.6),
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// // correct code above//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'onboarding_screen.dart';
// import 'location_permission_screen.dart';
// import 'radius_selection_screen.dart';
// import '../main_home_page.dart'; // your main home page import

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     // 🔹 Fade-in animation
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//     _controller.forward();

//     // 🔹 Check session after splash delay
//     Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         checkUserSession();
//       }
//     });
//   }

//   Future<void> checkUserSession() async {
//     final user = Supabase.instance.client.auth.currentUser;

//     if (user == null) {
//       // ❌ User not logged in → go to onboarding
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//       );
//     } else {
//       // ✅ User logged in → check radius_km in users table
//       final response = await Supabase.instance.client
//           .from('users')
//           .select('radius_km')
//           .eq('id', user.id)
//           .maybeSingle(); // updated API

//       if (response == null) {
//         // User row not found → fallback to onboarding
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//         );
//       } else {
//         final radius = response['radius_km'];
//         if (radius == null) {
//           // 🆕 New user → go to location permission screen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => LocationPermissionScreen()),
//           );
//         } else {
//           // 🔹 Existing user → go directly to MainHomePage
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const MainHomePage()),
//           );
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _animation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // 🌿 Circular logo
//               Container(
//                 height: 110,
//                 width: 110,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [kGreen, kTeal],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: const Center(
//                   child: Icon(Icons.recycling_rounded,
//                       color: Colors.white, size: 60),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 "Circlo",
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: kTextDark,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Share. Exchange. Connect.",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: kTextDark.withOpacity(0.6),
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
// //   }
// // }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import 'onboarding_screen.dart';
import 'location_permission_screen.dart';
import '../main_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Wait for splash animation then check session
    Timer(const Duration(seconds: 3), () {
      if (mounted) checkUserSession();
    });
  }

  Future<void> checkUserSession() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // User not logged in → Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // User logged in → check radius_km
      final response = await Supabase.instance.client
          .from('users')
          .select('radius_km')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null || response['radius_km'] == null) {
        // New user → Location permission screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        );
      } else {
        // Existing user → Main Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [kGreen, kTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.recycling_rounded,
                      color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Circlo",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Share. Exchange. Connect.",
                style: TextStyle(
                  fontSize: 14,
                  color: kTextDark.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import 'onboarding_screen.dart';
// import 'location_permission_screen.dart';
// import '../main_home_page.dart';
// import '../../providers/auth_provider.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//     _controller.forward();

//     // Wait for splash animation then check session
//     Timer(const Duration(seconds: 3), () {
//       if (mounted) checkUserSession();
//     });
//   }

//   Future<void> checkUserSession() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final user = authProvider.user;

//     if (user == null) {
//       // Not logged in → Onboarding
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
//     } else {
//       // Logged in → Check radius
//       if (user.radiusKm == null) {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LocationPermissionScreen()));
//       } else {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainHomePage()));
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _animation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 height: 110,
//                 width: 110,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [kGreen, kTeal],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: const Center(
//                   child: Icon(Icons.recycling_rounded, color: Colors.white, size: 60),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 "Circlo",
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: kTextDark,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Share. Exchange. Connect.",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: kTextDark.withOpacity(0.6),
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
