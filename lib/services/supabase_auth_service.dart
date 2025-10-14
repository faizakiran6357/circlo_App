
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../ui/auth/location_permission_screen.dart';

// class SupabaseAuthService {
//   static final SupabaseClient supabase = Supabase.instance.client;

//   // ✳️ Email Sign Up
//   static Future<AuthResponse?> signUp(String email, String password, String name) async {
//     try {
//       final response = await supabase.auth.signUp(
//         email: email,
//         password: password,
//         data: {'name': name},
//       );

//       if (response.user != null) {
//         await createUserProfile(response.user!.id, email, name);
//       }
//       return response;
//     } on AuthException catch (e) {
//       throw Exception(e.message);
//     } catch (e) {
//       throw Exception("Unexpected error: $e");
//     }
//   }

//   // ✳️ Create Profile in users table
//   static Future<void> createUserProfile(String id, String email, String name) async {
//     try {
//       await supabase.from('users').insert({
//         'id': id,
//         'email': email,
//         'display_name': name,
//         'trust_score': 0,
//         'points': 0,
//         'badges': [],
//         'created_at': DateTime.now().toIso8601String(),
//       });
//     } catch (e) {
//       debugPrint("⚠️ Error inserting user profile: $e");
//     }
//   }

//   // ✳️ Email Login
//   static Future<AuthResponse?> login(String email, String password) async {
//     try {
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: password,
//       );
//       return response;
//     } on AuthException catch (e) {
//       throw Exception(e.message);
//     } catch (e) {
//       throw Exception("Unexpected error: $e");
//     }
//   }

//   // ✳️ Logout (Supabase + Google)
//   static Future<void> logout() async {
//     try {
//       final googleSignIn = GoogleSignIn();
//       try {
//         await googleSignIn.disconnect();
//       } catch (_) {
//         // ignore any signOut/disconnect errors
//       }
//     } catch (_) {}
//     await supabase.auth.signOut();
//   }

//   // ✳️ Forgot Password
//   static Future<void> resetPassword(String email) async {
//     try {
//       await supabase.auth.resetPasswordForEmail(email);
//     } on AuthException catch (e) {
//       throw Exception(e.message);
//     } catch (e) {
//       throw Exception("Unexpected error: $e");
//     }
//   }

//   static User? get currentUser => supabase.auth.currentUser;

//   // ✳️ Google Sign-In (always show account picker)
//   static Future<void> signInWithGoogle(BuildContext context) async {
//     try {
//       const webClientId =
//           '399668622217-r4slppjhbhvctce02jphk7gjegrapirf.apps.googleusercontent.com'; // 👈 replace with your actual Google web client ID

//       final GoogleSignIn googleSignIn = GoogleSignIn(
//         serverClientId: webClientId,
//       );

//       // ✅ Safely disconnect any previous session
//       try {
//         final currentUser = await googleSignIn.signInSilently();
//         if (currentUser != null) {
//           await googleSignIn.disconnect();
//         }
//       } catch (_) {}

//       // ✅ Show account picker dialog
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//       if (googleUser == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Google sign-in cancelled')),
//         );
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final accessToken = googleAuth.accessToken;
//       final idToken = googleAuth.idToken;

//       if (accessToken == null || idToken == null) {
//         throw 'Missing Google ID Token or Access Token';
//       }

//       // ✅ Sign in to Supabase
//       await supabase.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: idToken,
//         accessToken: accessToken,
//       );

//       // ✅ Ensure user exists in Supabase users table
//       await _ensureUserRowExists();

//       if (context.mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
//           (route) => false,
//         );
//       }
//     } on AuthException catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.message)));
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }


//   // ✅ Ensure user exists in `users` table (fixed for Google + normal users)
// static Future<void> _ensureUserRowExists() async {
//   final currentUser = supabase.auth.currentUser;
//   if (currentUser == null) return;

//   try {
//     final existing = await supabase
//         .from('users')
//         .select()
//         .eq('id', currentUser.id)
//         .maybeSingle();

//     final displayName = currentUser.userMetadata?['name'] ??
//         currentUser.userMetadata?['full_name'] ??
//         currentUser.userMetadata?['display_name'] ??
//         currentUser.email?.split('@').first ??
//         'Unknown User';

//     final avatarUrl = currentUser.userMetadata?['avatar_url'] ?? '';

//     if (existing == null) {
//       await supabase.from('users').insert({
//         'id': currentUser.id,
//         'email': currentUser.email,
//         'display_name': displayName,
//         'avatar_url': avatarUrl,
//         'trust_score': 0,
//         'points': 0,
//         'badges': [],
//         'created_at': DateTime.now().toIso8601String(),
//       });
//     } else {
//       await supabase.from('users').update({
//         'display_name': displayName,
//         'avatar_url': avatarUrl,
//         'updated_at': DateTime.now().toIso8601String(),
//       }).eq('id', currentUser.id);
//     }
//   } catch (e) {
//     debugPrint("⚠️ Error ensuring user row: $e");
//   }
// }

//     // ✅ Keep users table synced with auth data
//   static Future<void> syncUserProfile() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return;

//     try {
//       final existing = await supabase
//           .from('users')
//           .select()
//           .eq('id', user.id)
//           .maybeSingle();

//       if (existing == null) {
//         await supabase.from('users').insert({
//           'id': user.id,
//           'email': user.email,
//           'display_name': user.userMetadata?['display_name'] ??
//               user.userMetadata?['name'] ??
//               user.email?.split('@').first ??
//               'User',
//           'avatar_url': user.userMetadata?['avatar_url'] ?? '',
//           'created_at': DateTime.now().toIso8601String(),
//         });
//       } else {
//         await supabase.from('users').update({
//           'display_name': user.userMetadata?['display_name'] ??
//               existing['display_name'] ??
//               user.email?.split('@').first,
//           'avatar_url':
//               user.userMetadata?['avatar_url'] ?? existing['avatar_url'],
//           'updated_at': DateTime.now().toIso8601String(),
//         }).eq('id', user.id);
//       }

//       debugPrint("✅ User synced successfully: ${user.email}");
//     } catch (e) {
//       debugPrint("❌ User sync failed: $e");
//     }
//   }

// }
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ui/auth/location_permission_screen.dart';

class SupabaseAuthService {
  static final SupabaseClient supabase = Supabase.instance.client;

  // ✳️ Email Sign Up
  static Future<AuthResponse?> signUp(String email, String password, String name) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        await createUserProfile(response.user!.id, email, name);
      }
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✳️ Create Profile in users table
  static Future<void> createUserProfile(String id, String email, String name) async {
    try {
      await supabase.from('users').upsert({
        'id': id,
        'email': email,
        'display_name': name,
        'trust_score': 0,
        'points': 0,
        'badges': [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("⚠️ Error inserting user profile: $e");
    }
  }

  // ✳️ Email Login
  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // ✳️ Logout (Supabase + Google)
  static Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
    } catch (_) {}
    await supabase.auth.signOut();
  }

  // ✳️ Forgot Password
  static Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  static User? get currentUser => supabase.auth.currentUser;

  // ✳️ Google Sign-In (always show account picker)
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      const webClientId =
          '399668622217-r4slppjhbhvctce02jphk7gjegrapirf.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);

      // ✅ Disconnect any previous silent session
      try {
        final currentUser = await googleSignIn.signInSilently();
        if (currentUser != null) await googleSignIn.disconnect();
      } catch (_) {}

      // ✅ Show account picker
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Missing Google ID Token or Access Token';
      }

      // ✅ Sign in to Supabase
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      // ✅ Ensure user exists or updates correctly
      await _ensureUserRowExists();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ✅ Ensure user exists in `users` table (safe for all login types)
  static Future<void> _ensureUserRowExists() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      final displayName = currentUser.userMetadata?['display_name'] ??
          currentUser.userMetadata?['name'] ??
          currentUser.userMetadata?['full_name'] ??
          currentUser.email?.split('@').first ??
          'Unknown User';

      final avatarUrl = currentUser.userMetadata?['avatar_url'] ?? '';

      await supabase.from('users').upsert({
        'id': currentUser.id,
        'email': currentUser.email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'trust_score': 0,
        'points': 0,
        'badges': [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint("✅ User ensured in table: ${currentUser.email}");
    } catch (e) {
      debugPrint("⚠️ Error ensuring user row: $e");
    }
  }

  // ✅ Sync profile when app restarts
  static Future<void> syncUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final displayName = user.userMetadata?['display_name'] ??
          user.userMetadata?['name'] ??
          user.email?.split('@').first ??
          'User';

      final avatarUrl = user.userMetadata?['avatar_url'] ?? '';

      await supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint("✅ User synced successfully: ${user.email}");
    } catch (e) {
      debugPrint("❌ User sync failed: $e");
    }
  }
}
 