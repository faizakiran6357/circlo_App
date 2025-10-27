
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  AppUser? user;
  bool loading = false;
  RealtimeChannel? _notificationChannel;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = supabase.auth.currentSession;
    if (session?.user != null) {
      await _loadUserProfile(session!.user!);
      await saveFcmToken(session.user!.id);
      // start listening for notifications for this user
      startNotificationListener(session.user!.id);
    }

    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session?.user != null) {
        await _loadUserProfile(session!.user!);
        await saveFcmToken(session.user!.id);
        startNotificationListener(session.user!.id);
      } else {
        stopNotificationListener();
        user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(User u) async {
    try {
      loading = true;
      notifyListeners();

      final res = await supabase.from('users').select().eq('id', u.id).maybeSingle();
      if (res != null) {
        user = AppUser.fromMap(Map<String, dynamic>.from(res));
      } else {
        user = AppUser(
          id: u.id,
          displayName: u.userMetadata?['name'],
          email: u.email,
        );
      }
    } catch (e) {
      debugPrint('AuthProvider load profile error: $e');
      user = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    stopNotificationListener();
    user = null;
    notifyListeners();
  }

  Future<void> setRadius(double newRadius) async {
    if (user == null) return;

    try {
      await supabase.from('users').update({'radius_km': newRadius}).eq('id', user!.id);
      user = user!.copyWith(radiusKm: newRadius);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating radius in provider: $e');
    }
  }

  /// Save FCM token to Supabase users table
  Future<void> saveFcmToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        debugPrint('⚠️ No FCM token retrieved from Firebase');
        return;
      }
      await supabase.from('users').update({'fcm_token': fcmToken}).eq('id', userId);
      debugPrint('✅ FCM token saved to Supabase: $fcmToken');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Listen for token refresh and update
  void initFcmTokenListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      try {
        await supabase.from('users').update({'fcm_token': newToken}).eq('id', currentUser.id);
        debugPrint('✅ FCM token refreshed for ${currentUser.id}: $newToken');
      } catch (e) {
        debugPrint('⚠️ Failed to update refreshed FCM token: $e');
      }
    });
  }

  /// PUBLIC: start listening to user's notifications (Realtime)
  /// Call this after login (or during init if session exists).
  void startNotificationListener(String userId) {
    // stop previous channel if any
    stopNotificationListener();

    _notificationChannel = supabase
        .channel('user_notifications_$userId')
        .onPostgresChanges(
          // listen only to inserts on notifications table
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            // required named parameter 'type' — use equality filter
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            try {
              final record = payload.newRecord;
              final title = record['title'] ?? 'Notification';
              final body = record['body'] ?? '';

              debugPrint("📩 New notification for $userId: $title - $body");

              // show local banner
              await NotificationService.showLocalNotification(
                title: title,
                body: body,
              );
            } catch (e) {
              debugPrint('⚠️ Error handling realtime notification: $e');
            }
          },
        )
        .subscribe();

    debugPrint("📡 Started notification listener for user $userId");
  }

  /// PUBLIC: stop listening to notifications
  void stopNotificationListener() {
    if (_notificationChannel != null) {
      supabase.removeChannel(_notificationChannel!);
      _notificationChannel = null;
      debugPrint("🛑 Stopped notification listener");
    }
  }
}
