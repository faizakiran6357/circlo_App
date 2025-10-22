
import 'dart:convert';
import 'package:circlo_app/get_server_key.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///  Background message handler (for FCM messages)
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

  ///  Initialize both local & FCM notifications
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

    //  Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    //  Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground notification: ${message.notification?.title}');
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
        );
      }
    });

    // When user taps on a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🟢 User tapped notification: ${message.notification?.title}');
    });
  }

  /// Show local notification (used for both FCM & Supabase triggers)
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

  ///  Send push notification via FCM (if you want remote delivery)
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
