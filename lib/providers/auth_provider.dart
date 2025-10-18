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
  Future<void> setRadius(double newRadius) async {
  if (user == null) return;

  try {
    // Update in Supabase
    await supabase.from('users').update({'radius_km': newRadius}).eq('id', user!.id);

    // Update locally in provider
    user = user!.copyWith(radiusKm: newRadius);

    notifyListeners(); // notify all listeners
  } catch (e) {
    debugPrint('❌ Error updating radius in provider: $e');
  }
}

}
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart';
// import '../models/user_model.dart';
// import '../providers/items_provider.dart';

// class AuthProvider extends ChangeNotifier {
//   final SupabaseClient supabase = Supabase.instance.client;

//   AppUser? user;
//   bool loading = false;

//   AuthProvider() {
//     _init();
//   }

//   Future<void> _init() async {
//     final session = supabase.auth.currentSession;
//     if (session?.user != null) {
//       await _loadUserProfile(session!.user!);
//     }

//     supabase.auth.onAuthStateChange.listen((data) async {
//       final session = data.session;
//       if (session?.user != null) {
//         await _loadUserProfile(session!.user!);
//       } else {
//         user = null;
//         notifyListeners();
//       }
//     });
//   }

//   Future<void> _loadUserProfile(User u) async {
//     try {
//       loading = true;
//       notifyListeners();

//       final res =
//           await supabase.from('users').select().eq('id', u.id).maybeSingle();

//       if (res != null) {
//         user = AppUser.fromMap(Map<String, dynamic>.from(res));

//         // ✅ Safely handle radius (supports int or double)
//         final dynamic radiusValue = res['radius_km'];
//         final double radius = (radiusValue is num)
//             ? radiusValue.toDouble()
//             : double.tryParse(radiusValue?.toString() ?? '') ?? 30.0;

//         // ✅ After login, automatically apply user radius and load nearby/trending items
//         WidgetsBinding.instance.addPostFrameCallback((_) async {
//           try {
//             // Ensure we have a mounted context with providers
//             final ctx = WidgetsBinding.instance.focusManager.primaryFocus?.context;
//             if (ctx != null) {
//               final itemsProvider =
//                   Provider.of<ItemsProvider>(ctx, listen: false);
//               itemsProvider.setSelectedRadius(radius);
//               await itemsProvider.loadNearby();
//               await itemsProvider.loadTrending();
//             }
//           } catch (e) {
//             debugPrint('⚠️ Auto-load nearby failed: $e');
//           }
//         });
//       } else {
//         // 🟢 fallback minimal profile (if user row not found)
//         user = AppUser(
//           id: u.id,
//           displayName: u.userMetadata?['name'],
//           email: u.email,
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ AuthProvider load profile error: $e');
//       user = null;
//     } finally {
//       loading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> signOut() async {
//     await supabase.auth.signOut();
//     user = null;
//     notifyListeners();
//   }
//     /// ✅ Save user radius in Supabase + update local user object
//   Future<void> updateUserRadius(double radiusKm) async {
//     if (user == null) return;

//     try {
//       await supabase
//           .from('users')
//           .update({'radius_km': radiusKm})
//           .eq('id', user!.id);

//       // update locally too
//       user = user!.copyWith(radiusKm: radiusKm);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('❌ Failed to update radius: $e');
//     }
//   }

// }
