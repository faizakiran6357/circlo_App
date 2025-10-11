// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseAuthService {
//   static final SupabaseClient supabase = Supabase.instance.client;

//   // ✳️ Sign up
//   static Future<AuthResponse?> signUp(String email, String password, String name) async {
//     try {
//       final response = await supabase.auth.signUp(
//         email: email,
//         password: password,
//         data: {'name': name},
//       );
//       return response;
//     } on AuthException catch (e) {
//       throw Exception(e.message);
//     } catch (e) {
//       throw Exception("Unexpected error: $e");
//     }
//   }

//   // ✳️ Login
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

//   // ✳️ Logout
//   static Future<void> logout() async {
//     await supabase.auth.signOut();
//   }

//   // ✳️ Reset Password
//   static Future<void> resetPassword(String email) async {
//     try {
//       await supabase.auth.resetPasswordForEmail(email);
//     } on AuthException catch (e) {
//       throw Exception(e.message);
//     }
//   }

//   // ✳️ Get Current User
//   static User? get currentUser => supabase.auth.currentUser;
// }
// import 'package:flutter/material.dart';
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

//   // ✳️ Logout
//   static Future<void> logout() async {
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

//   // ✳️ Google Sign-In (OAuth)
// static Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     // Always sign out first to clear cached Google session
//     await logout();

//     // Start Supabase OAuth with Google
//     await supabase.auth.signInWithOAuth(
//       OAuthProvider.google,
//       redirectTo: 'io.supabase.circlo://login-callback/',

//       // 🔹 Force Google to show account chooser
//       queryParams: {
//         'prompt': 'select_account',
//       },
//     );

//     // Listen for login completion
//     supabase.auth.onAuthStateChange.listen((data) async {
//       final session = data.session;
//       if (session != null && session.user != null) {
//         final user = session.user!;

//         // Check if user already exists
//         final existing = await supabase
//             .from('users')
//             .select()
//             .eq('id', user.id)
//             .maybeSingle();

//         // Create user record if new
//         if (existing == null) {
//           await createUserProfile(
//             user.id,
//             user.email ?? '',
//             user.userMetadata?['name'] ?? 'Unknown',
//           );
//         }

//         // Navigate after login
//         if (context.mounted) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
//             (route) => false,
//           );
//         }
//       }
//     });
//   } on AuthException catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
//   } catch (e) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("Error signing in with Google: $e")));
//   }
// }

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
      await supabase.from('users').insert({
        'id': id,
        'email': email,
        'display_name': name,
        'trust_score': 0,
        'points': 0,
        'badges': [],
        'created_at': DateTime.now().toIso8601String(),
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
      } catch (_) {
        // ignore any signOut/disconnect errors
      }
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
          '399668622217-r4slppjhbhvctce02jphk7gjegrapirf.apps.googleusercontent.com'; // 👈 replace with your actual Google web client ID

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      // ✅ Safely disconnect any previous session
      try {
        final currentUser = await googleSignIn.signInSilently();
        if (currentUser != null) {
          await googleSignIn.disconnect();
        }
      } catch (_) {}

      // ✅ Show account picker dialog
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Missing Google ID Token or Access Token';
      }

      // ✅ Sign in to Supabase
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // ✅ Ensure user exists in Supabase users table
      await _ensureUserRowExists();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ✳️ Ensure user exists in `users` table
  static Future<void> _ensureUserRowExists() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final existing = await supabase
        .from('users')
        .select()
        .eq('id', currentUser.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('users').insert({
        'id': currentUser.id,
        'email': currentUser.email,
        'display_name': currentUser.userMetadata?['name'] ?? 'Unknown',
        'avatar_url': currentUser.userMetadata?['avatar_url'],
        'trust_score': 0,
        'points': 0,
        'badges': [],
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
