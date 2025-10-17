
import 'package:circlo_app/providers/exchange_provider.dart';
import 'package:circlo_app/providers/navigtation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🧱 Theme + Providers
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/chat_provider.dart';


// 🧭 Screens
import 'ui/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rvsklnveacozabkgfptu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ExchangeProvider()),
          ChangeNotifierProvider(create: (_) => NavigtationProvider()),
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
      home: const SplashScreen(),
    );
  }
}
