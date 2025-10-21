// import 'dart:convert';
// import 'package:circlo_app/get_server_key.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         // handle notification click
//         print("Notification clicked with payload: $payload");
//       },
//     );

//     // Request FCM permission
//     await FirebaseMessaging.instance.requestPermission();

//     // Foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         showLocalNotification(
//           title: message.notification!.title ?? '',
//           body: message.notification!.body ?? '',
//         );
//       }
//     });

//     // Handle messages opened from background / terminated
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('User opened notification: ${message.notification?.title}');
//       // navigate to specific screen if needed
//     });
//   }

//   static Future<void> showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'circlo_channel',
//       'Circlo Notifications',
//       channelDescription: 'Notifications for Circlo App',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   // 🔹 Send FCM notification using service account
//   static Future<void> sendPushNotification({
//     required String fcmToken,
//     required String title,
//     required String body,
//   }) async {
//     final accessToken = await GetServerKey().getServerKeyToken();

//     final url =
//         'https://fcm.googleapis.com/v1/projects/circlo-app/messages:send';

//     final message = {
//       "message": {
//         "token": fcmToken,
//         "notification": {"title": title, "body": body},
//       }
//     };

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(message),
//     );

//     print('FCM Response: ${response.statusCode} ${response.body}');
//   }
// }
// import 'dart:convert';
// import 'package:circlo_app/get_server_key.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // ✅ Background message handler
//   @pragma('vm:entry-point')
//   static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     if (message.notification != null) {
//       await showLocalNotification(
//         title: message.notification!.title ?? '',
//         body: message.notification!.body ?? '',
//       );
//     }
//   }

//   static Future<void> init() async {
//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (payload) {
//         print("Notification clicked with payload: $payload");
//         // Optionally handle deep link navigation here
//       },
//     );

//     // Request FCM permission
//     await FirebaseMessaging.instance.requestPermission();

//     // ✅ Register background handler
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     // Foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         showLocalNotification(
//           title: message.notification!.title ?? '',
//           body: message.notification!.body ?? '',
//         );
//       }
//     });

//     // When user taps a notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('User opened notification: ${message.notification?.title}');
//     });
//   }

//   static Future<void> showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'circlo_channel',
//       'Circlo Notifications',
//       channelDescription: 'Notifications for Circlo App',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   // 🔹 Send FCM notification using service account
//   static Future<void> sendPushNotification({
//     required String fcmToken,
//     required String title,
//     required String body,
//   }) async {
//     final accessToken = await GetServerKey().getServerKeyToken();

//     final url =
//         'https://fcm.googleapis.com/v1/projects/circlo-app/messages:send';

//     final message = {
//       "message": {
//         "token": fcmToken,
//         "notification": {"title": title, "body": body},
//       }
//     };

//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(message),
//     );

//     print('FCM Response: ${response.statusCode} ${response.body}');
//   }
// }
// import 'dart:convert';
// import 'package:circlo_app/get_server_key.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'package:firebase_core/firebase_core.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // ✅ Background message handler
//   @pragma('vm:entry-point')
//   static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     await Firebase.initializeApp(); // ensure Firebase is ready
//     if (message.notification != null) {
//       await showLocalNotification(
//         title: message.notification!.title ?? '',
//         body: message.notification!.body ?? '',
//       );
//     }
//   }

//   // ✅ Initialize notification services (local + FCM)
//   static Future<void> init() async {
//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (response) {
//         print("🔔 Notification clicked: ${response.payload}");
//         // TODO: Add navigation if needed
//       },
//     );

//     // ✅ Ask permission for FCM
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // ✅ Register background handler
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     // ✅ Handle foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📨 Foreground notification received: ${message.notification?.title}');
//       if (message.notification != null) {
//         showLocalNotification(
//           title: message.notification!.title ?? '',
//           body: message.notification!.body ?? '',
//         );
//       }
//     });

//     // ✅ Handle notification tap (when app in background)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('🟢 User opened notification: ${message.notification?.title}');
//       // TODO: Add navigation or logic if needed
//     });
//   }

//   // ✅ Show local notification (foreground)
//   static Future<void> showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'circlo_channel',
//       'Circlo Notifications',
//       channelDescription: 'Notifications for Circlo App',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );

//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);

//     await _flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
//       title,
//       body,
//       platformDetails,
//     );
//   }

//   // ✅ Send push notification using FCM HTTP v1 API
//   static Future<void> sendPushNotification({
//     required String fcmToken,
//     required String title,
//     required String body,
//   }) async {
//     try {
//       final accessToken = await GetServerKey().getServerKeyToken();

//       final url = Uri.parse(
//         'https://fcm.googleapis.com/v1/projects/circlo-app/messages:send',
//       );

//       final message = {
//         "message": {
//           "token": fcmToken,
//           "notification": {"title": title, "body": body},
//         }
//       };

//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(message),
//       );

//       if (response.statusCode == 200) {
//         print('✅ Push notification sent successfully.');
//       } else {
//         print('⚠️ FCM send error: ${response.statusCode} ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Error sending FCM notification: $e');
//     }
//   }
// }
import 'dart:convert';
import 'package:circlo_app/get_server_key.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ✅ Background message handler (for FCM messages)
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    if (message.notification != null) {
      await showLocalNotification(
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
      );
    }
  }

  /// ✅ Initialize both local & FCM notifications
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        print("🔔 Notification clicked: ${response.payload}");
        // Optionally handle navigation here
      },
    );

    // Request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ✅ Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground notification: ${message.notification?.title}');
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    // ✅ When user taps on a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🟢 User tapped notification: ${message.notification?.title}');
    });
  }

  /// ✅ Show local notification (used for both FCM & Supabase triggers)
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'circlo_channel',
      'Circlo Notifications',
      channelDescription: 'Notifications for Circlo App',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }

  /// ✅ Send push notification via FCM (if you want remote delivery)
  static Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    try {
      final accessToken = await GetServerKey().getServerKeyToken();

      final message = {
        "message": {
          "token": fcmToken,
          "notification": {"title": title, "body": body},
        }
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/circlo-app/messages:send'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Push notification sent successfully.');
      } else {
        print('⚠️ FCM send error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending FCM notification: $e');
    }
  }
}
