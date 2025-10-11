import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  AppUser? user;
  bool loading = false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = supabase.auth.currentSession;
    if (session?.user != null) {
      await _loadUserProfile(session!.user!);
    }
    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session?.user != null) {
        await _loadUserProfile(session!.user!);
      } else {
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
        // fallback minimal profile from auth user
        user = AppUser(id: u.id, displayName: u.userMetadata?['name'], email: u.email);
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
    user = null;
    notifyListeners();
  }
}
