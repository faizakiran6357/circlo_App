// // import 'package:circlo_app/ui/auth/login_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'utils/app_theme.dart';
// // import 'ui/auth/onboarding_screen.dart';

// // // later you'll import supabase and other services, but not yet for frontend-only phase

// // void main() {
// //   runApp(const CircloApp());
// // }

// // class CircloApp extends StatelessWidget {
// //   const CircloApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Circlo',
// //       debugShowCheckedModeBanner: false,
// //       theme: circloTheme,
// //       home: const OnboardingScreen(),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'utils/app_theme.dart';
// import 'ui/auth/onboarding_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 🔗 initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   runApp(const CircloApp());
// }

// class CircloApp extends StatelessWidget {
//   const CircloApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,
//       home: const OnboardingScreen(),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'utils/app_theme.dart';
// import 'ui/auth/onboarding_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   runApp(const CircloApp());
// }

// class CircloApp extends StatelessWidget {
//   const CircloApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,

//       // 🔹 Always start from Onboarding screen
//       // (Even if user is already logged in)
//       home: const OnboardingScreen(),
//     );
//   }
// }
// import 'package:circlo_app/ui/auth/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'utils/app_theme.dart';
// import 'ui/auth/onboarding_screen.dart';
// import 'ui/auth/reset_password_screen.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   // ✅ Listen for Supabase password recovery deep link
//   Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
//     final event = data.event;
//     if (event == AuthChangeEvent.passwordRecovery) {
//       // Open Reset Password Screen when user clicks link from email
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
//       );
//     }
//   });

//   runApp(const CircloApp());
// }

// class CircloApp extends StatelessWidget {
//   const CircloApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: navigatorKey,
//       theme: circloTheme,
//       home: const SplashScreen(),
//     );
//   }
// }
import 'package:circlo_app/ui/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'ui/auth/onboarding_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rvsklnveacozabkgfptu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
      ],
      child: const CircloApp(),
    ),
  );
}

class CircloApp extends StatelessWidget {
  const CircloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circlo',
      debugShowCheckedModeBanner: false,
      theme: circloTheme,
      home: const SplashScreen(), // keep current behavior
    );
  }
}
