
// import 'package:circlo_app/providers/exchange_provider.dart';
// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // 🧱 Theme + Providers
// import 'utils/app_theme.dart';
// import 'providers/auth_provider.dart';
// import 'providers/items_provider.dart';
// import 'providers/chat_provider.dart';


// // 🧭 Screens
// import 'ui/auth/splash_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ItemsProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//         ChangeNotifierProvider(create: (_) => ExchangeProvider()),
//         ChangeNotifierProvider(create: (_) => NavigtationProvider()),
//       ],
//       child: const CircloApp(),
//     ),
//   );
// }

// class CircloApp extends StatelessWidget {
//   const CircloApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,
//       home: const SplashScreen(),
//     );
//   }
// }
// import 'package:circlo_app/providers/exchange_provider.dart';
// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Firebase dependencies
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// // 🧱 Theme + Providers
// import 'utils/app_theme.dart';
// import 'providers/auth_provider.dart';
// import 'providers/items_provider.dart';
// import 'providers/chat_provider.dart';

// // 🧭 Screens
// import 'ui/auth/splash_screen.dart';

// // 🔹 Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   // Initialize Firebase
//   await Firebase.initializeApp();

//   // Set background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ItemsProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//         ChangeNotifierProvider(create: (_) => ExchangeProvider()),
//         ChangeNotifierProvider(create: (_) => NavigtationProvider()),
//           ChangeNotifierProvider( create: (_) => AuthProvider()..initFcmTokenListener(),)
//       ],
//       child: const CircloApp(),
//     ),
//   );
// }

// class CircloApp extends StatefulWidget {
//   const CircloApp({super.key});

//   @override
//   State<CircloApp> createState() => _CircloAppState();
// }

// class _CircloAppState extends State<CircloApp> {
//   @override
//   void initState() {
//     super.initState();
//     _setupFCM();
//   }

//   void _setupFCM() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Request permission (iOS)
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     print('User granted permission: ${settings.authorizationStatus}');

//     // Get FCM token
//     String? token = await messaging.getToken();
//     print("FCM Token: $token");

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Received a foreground message: ${message.notification?.title}');
//       // Here you can show a local in-app notification using any package
//     });

//     // Handle messages when app is opened from terminated state
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('App opened from notification: ${message.notification?.title}');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,
//       home: const SplashScreen(),
//     );
//   }
// }
// import 'package:circlo_app/providers/exchange_provider.dart';
// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Firebase dependencies
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// // 🧱 Theme + Providers
// import 'utils/app_theme.dart';
// import 'providers/auth_provider.dart';
// import 'providers/items_provider.dart';
// import 'providers/chat_provider.dart';

// // 🧭 Screens
// import 'ui/auth/splash_screen.dart';

// // ✅ Import your notification service
// import 'services/notification_service.dart';

// // 🔹 Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   // ✅ Initialize Firebase
//   await Firebase.initializeApp();

//   // ✅ Initialize NotificationService early (important!)
//   await NotificationService.init();

//   // ✅ Set background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()..initFcmTokenListener()),
//         ChangeNotifierProvider(create: (_) => ItemsProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//         ChangeNotifierProvider(create: (_) => ExchangeProvider()),
//         ChangeNotifierProvider(create: (_) => NavigtationProvider()),
//       ],
//       child: const CircloApp(),
//     ),
//   );
// }

// class CircloApp extends StatefulWidget {
//   const CircloApp({super.key});

//   @override
//   State<CircloApp> createState() => _CircloAppState();
// }

// class _CircloAppState extends State<CircloApp> {
//   @override
//   void initState() {
//     super.initState();
//     _setupFCM();
//   }

//   void _setupFCM() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Request permission (especially needed for iOS)
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     print('User granted permission: ${settings.authorizationStatus}');

//     // Get FCM token
//     String? token = await messaging.getToken();
//     print("✅ Current FCM Token: $token");

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 Foreground message: ${message.notification?.title}');
//       NotificationService.showLocalNotification(
//         title: message.notification?.title ?? 'Notification',
//         body: message.notification?.body ?? '',
//       );
//     });

//     // Handle messages when the app is opened from terminated/background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('🔔 App opened from notification: ${message.notification?.title}');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,
//       home: const SplashScreen(),
//     );
//   }
// }
// import 'package:circlo_app/providers/exchange_provider.dart';
// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Firebase dependencies
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// // 🧱 Theme + Providers
// import 'utils/app_theme.dart';
// import 'providers/auth_provider.dart';
// import 'providers/items_provider.dart';
// import 'providers/chat_provider.dart';

// // 🧭 Screens
// import 'ui/auth/splash_screen.dart';

// // ✅ Notification service
// import 'services/notification_service.dart';

// // 🔹 Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   // ✅ Initialize Firebase
//   await Firebase.initializeApp();

//   // ✅ Initialize NotificationService early
//   await NotificationService.init();

//   // ✅ Set background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()..initFcmTokenListener()),
//         ChangeNotifierProvider(create: (_) => ItemsProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//         ChangeNotifierProvider(create: (_) => ExchangeProvider()),
//         ChangeNotifierProvider(create: (_) => NavigtationProvider()),
//       ],
//       child: const CircloApp(),
//     ),
//   );
// }

// class CircloApp extends StatefulWidget {
//   const CircloApp({super.key});

//   @override
//   State<CircloApp> createState() => _CircloAppState();
// }

// class _CircloAppState extends State<CircloApp> {
//   @override
//   void initState() {
//     super.initState();
//     _setupFCM();
//   }

//   void _setupFCM() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Request permission
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     print('User granted permission: ${settings.authorizationStatus}');

//     // Get FCM token
//     String? token = await messaging.getToken();
//     print("✅ Current FCM Token: $token");

//     // Save token if user is already logged in
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.user != null && token != null) {
//       await authProvider.saveFcmToken(authProvider.user!.id);
//       print("✅ FCM token saved for existing user ${authProvider.user!.id}");
//     }

//     // Foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 Foreground message: ${message.notification?.title}');
//       NotificationService.showLocalNotification(
//         title: message.notification?.title ?? 'Notification',
//         body: message.notification?.body ?? '',
//       );
//     });

//     // Notification tap handling
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('🔔 App opened from notification: ${message.notification?.title}');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,
//       home: const SplashScreen(),
//     );
//   }
// }
// import 'package:circlo_app/providers/exchange_provider.dart';
// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Firebase dependencies
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// // 🧱 Theme + Providers
// import 'utils/app_theme.dart';
// import 'providers/auth_provider.dart';
// import 'providers/items_provider.dart';
// import 'providers/chat_provider.dart';

// // 🧭 Screens
// import 'ui/auth/splash_screen.dart';

// // ✅ Notification service
// import 'services/notification_service.dart';

// // 🔹 Background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 1️⃣ Initialize Firebase first (important for FCM)
//   await Firebase.initializeApp();

//   // 2️⃣ Initialize Supabase
//   await Supabase.initialize(
//     url: 'https://rvsklnveacozabkgfptu.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
//   );

//   // 3️⃣ Initialize local + FCM notifications
//   await NotificationService.init();

//   // 4️⃣ Register background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // 5️⃣ Run app with all providers
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()..initFcmTokenListener()),
//         ChangeNotifierProvider(create: (_) => ItemsProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//         ChangeNotifierProvider(create: (_) => ExchangeProvider()),
//         ChangeNotifierProvider(create: (_) => NavigtationProvider()),
//       ],
//       child: const CircloApp(),
//     ),
//   );
// }

// class CircloApp extends StatefulWidget {
//   const CircloApp({super.key});

//   @override
//   State<CircloApp> createState() => _CircloAppState();
// }

// class _CircloAppState extends State<CircloApp> {
//   @override
//   void initState() {
//     super.initState();
//     _setupFCM();
//   }

//   void _setupFCM() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Request permission
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     print('User granted permission: ${settings.authorizationStatus}');

//     // Get FCM token
//     String? token = await messaging.getToken();
//     print("✅ Current FCM Token: $token");

//     // Save token if user is already logged in
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.user != null && token != null) {
//       await authProvider.saveFcmToken(authProvider.user!.id);
//       print("✅ FCM token saved for existing user ${authProvider.user!.id}");
//     }

//     // Foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 Foreground message: ${message.notification?.title}');
//       NotificationService.showLocalNotification(
//         title: message.notification?.title ?? 'Notification',
//         body: message.notification?.body ?? '',
//       );
//     });

//     // Notification tap handling
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('🔔 App opened from notification: ${message.notification?.title}');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Circlo',
//       debugShowCheckedModeBanner: false,
//       theme: circloTheme,
//       home: const SplashScreen(),
//     );
//   }
// }
import 'package:circlo_app/providers/exchange_provider.dart';
import 'package:circlo_app/providers/navigtation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/items_provider.dart';
import 'providers/chat_provider.dart';
import 'ui/auth/splash_screen.dart';
import 'services/notification_service.dart';

/// Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Firebase
  await Firebase.initializeApp();

  // 2️⃣ Supabase
  await Supabase.initialize(
    url: 'https://rvsklnveacozabkgfptu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2c2tsbnZlYWNvemFia2dmcHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwNDA4MDQsImV4cCI6MjA3NTYxNjgwNH0.tpARsyhulLxzECEbNjWbYch-nidBgvnQpYxMVwt1sRw',
  );

  // 3️⃣ Local + FCM notifications
  await NotificationService.init();

  // 4️⃣ Background FCM handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 5️⃣ Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initFcmTokenListener()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ExchangeProvider()),
        ChangeNotifierProvider(create: (_) => NavigtationProvider()),
      ],
      child: const CircloApp(),
    ),
  );
}

class CircloApp extends StatefulWidget {
  const CircloApp({super.key});

  @override
  State<CircloApp> createState() => _CircloAppState();
}

class _CircloAppState extends State<CircloApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
    _setupSupabaseRealtimeListener();
  }

  /// ✅ Listen for push notifications via FCM
  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Get and save FCM token
    String? token = await messaging.getToken();
    print("✅ Current FCM Token: $token");

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null && token != null) {
      await authProvider.saveFcmToken(authProvider.user!.id);
      print("✅ FCM token saved for ${authProvider.user!.id}");
    }

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showLocalNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });

    // Tap handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 App opened from notification: ${message.notification?.title}');
    });
  }

  /// ✅ Listen for Supabase notifications (from triggers)
  void _setupSupabaseRealtimeListener() async {
    final supabase = Supabase.instance.client;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) return;

    print('🟢 Listening to Supabase notifications for ${authProvider.user!.id}');

    supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: authProvider.user!.id,
          ),
          callback: (payload) async {
            final newNotification = payload.newRecord;
            final title = newNotification['title'] ?? 'New Notification';
            final body = newNotification['body'] ?? '';
            print('🔔 New Supabase notification: $title');
            await NotificationService.showLocalNotification(title: title, body: body);
          },
        )
        .subscribe();
  }

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
