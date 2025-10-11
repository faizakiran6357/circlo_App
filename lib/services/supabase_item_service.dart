// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseItemService {
//   static final SupabaseClient supabase = Supabase.instance.client;

//   // 🔹 Fetch all items (for Home Feed)
//   static Future<List<Map<String, dynamic>>> fetchAllItems() async {
//     final response = await supabase
//         .from('items')
//         .select()
//         .order('created_at', ascending: false);
//     return response;
//   }

//   // 🔹 Fetch nearby items (using radius)
//   static Future<List<Map<String, dynamic>>> fetchNearbyItems(double userRadius) async {
//     final response = await supabase
//         .from('items')
//         .select()
//         .lte('radius_km', userRadius)
//         .order('created_at', ascending: false);
//     return response;
//   }

//   // 🔹 Fetch friend items (for now, mock - later connect with friends table)
//   static Future<List<Map<String, dynamic>>> fetchFriendItems() async {
//     final response = await supabase
//         .from('items')
//         .select()
//         .order('trust_score', ascending: false);
//     return response;
//   }

//   // 🔹 Fetch trending items (highest trust score)
//   static Future<List<Map<String, dynamic>>> fetchTrendingItems() async {
//     final response = await supabase
//         .from('items')
//         .select()
//         .order('trust_score', ascending: false)
//         .limit(10);
//     return response;
//   }

//   // 🔹 Add a new item
//   static Future<void> addItem({
//     required String title,
//     required String description,
//     required String category,
//     required String condition,
//     List<String>? tags,
//     double? radiusKm,
//     String? imageUrl,
//   }) async {
//     final user = supabase.auth.currentUser;
//     if (user == null) throw Exception("User not logged in");

//     await supabase.from('items').insert({
//       'user_id': user.id,
//       'title': title,
//       'description': description,
//       'category': category,
//       'condition': condition,
//       'tags': tags ?? [],
//       'radius_km': radiusKm ?? 5,
//       'image_url': imageUrl,
//     });
//   }
// }
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseItemService {
//   static final SupabaseClient supabase = Supabase.instance.client;

//   // ---------------------------
//   // 🟢 Fetch All Items
//   // ---------------------------
//   static Future<List<Map<String, dynamic>>> fetchAllItems() async {
//     final res = await supabase
//         .from('items')
//         .select()
//         .order('created_at', ascending: false);
//     return List<Map<String, dynamic>>.from(res as List);
//   }

//   // ---------------------------
//   // 🟢 Fetch Nearby Items
//   // ---------------------------
//   static Future<List<Map<String, dynamic>>> fetchNearbyItems(double maxRadiusKm) async {
//     final res = await supabase
//         .from('items')
//         .select()
//         .lte('radius_km', maxRadiusKm)
//         .order('created_at', ascending: false);
//     return List<Map<String, dynamic>>.from(res as List);
//   }

//   // ---------------------------
//   // 🟢 Fetch Friend Items
//   // ---------------------------
//   static Future<List<Map<String, dynamic>>> fetchFriendItems() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) return [];

//     final friendsRes = await supabase
//         .from('friends')
//         .select('friend_id')
//         .eq('user_id', user.id)
//         .eq('status', 'accepted');

//     final friendRows = List<Map<String, dynamic>>.from(friendsRes as List);
//     final friendIds = friendRows.map((r) => r['friend_id'] as String).toList();
//     if (friendIds.isEmpty) return [];

//    final res = await supabase
//     .from('items')
//     .select()
//     .inFilter('user_id', friendIds)
//     .order('created_at', ascending: false);


//     return List<Map<String, dynamic>>.from(res as List);
//   }

//   // ---------------------------
//   // 🟢 Fetch Trending Items
//   // ---------------------------
//   static Future<List<Map<String, dynamic>>> fetchTrendingItems({int limit = 12}) async {
//     final res = await supabase
//         .from('items')
//         .select()
//         .order('trust_score', ascending: false)
//         .limit(limit);
//     return List<Map<String, dynamic>>.from(res as List);
//   }

//   // ---------------------------
//   // 🟢 Fetch Filtered Items
//   // ---------------------------
//   static Future<List<Map<String, dynamic>>> fetchFilteredItems(
//       Map<String, dynamic> filters) async {
//     // 🧩 Use dynamic builder type to avoid assignment type mismatch
//     dynamic builder = supabase.from('items').select();

//     final category = filters['category'] as String?;
//     final condition = filters['condition'] as String?;
//     final sort = filters['sort'] as String?;
//     final radius = filters['radiusKm'] as num?;

//     if (category != null && category.isNotEmpty && category != 'All') {
//       builder = builder.eq('category', category);
//     }
//     if (condition != null && condition.isNotEmpty && condition != 'All') {
//       builder = builder.eq('condition', condition);
//     }
//     if (radius != null) {
//       builder = builder.lte('radius_km', radius);
//     }

//     // 🧩 Apply sorting — fixed type issue
//     if (sort == 'Newest' || sort == null) {
//       builder = (builder as PostgrestTransformBuilder).order('created_at', ascending: false);
//     } else if (sort == 'Closest') {
//       builder = (builder as PostgrestTransformBuilder).order('radius_km', ascending: true);
//     } else if (sort == 'Highest Trust') {
//       builder = (builder as PostgrestTransformBuilder).order('trust_score', ascending: false);
//     } else {
//       builder = (builder as PostgrestTransformBuilder).order('created_at', ascending: false);
//     }

//     final res = await builder;
//     return List<Map<String, dynamic>>.from(res as List);
//   }

//   // ---------------------------
//   // 🟢 Add a New Item (for Module 4)
//   // ---------------------------
//   static Future<void> addItem({
//     required String title,
//     required String description,
//     required String category,
//     required String condition,
//     List<String>? tags,
//     double? radiusKm,
//     String? imageUrl,
//   }) async {
//     final user = supabase.auth.currentUser;
//     if (user == null) throw Exception('User not authenticated');

//     await supabase.from('items').insert({
//       'user_id': user.id,
//       'title': title,
//       'description': description,
//       'category': category,
//       'condition': condition,
//       'tags': tags ?? [],
//       'radius_km': radiusKm ?? 5,
//       'image_url': imageUrl,
//     });
//   }
// }
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';

class SupabaseItemService {
  static final SupabaseClient supabase = Supabase.instance.client;

  static Future<List<Item>> _mapListToItems(dynamic res) async {
    if (res == null) return [];
    final List rows = res as List;
    return rows.map((e) => Item.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  static Future<List<Item>> fetchAllItems() async {
    final res = await supabase.from('items').select().order('created_at', ascending: false);
    return _mapListToItems(res);
  }

  static Future<List<Item>> fetchNearbyItems(double maxRadiusKm) async {
    final res = await supabase.from('items').select().lte('radius_km', maxRadiusKm).order('created_at', ascending: false);
    return _mapListToItems(res);
  }

  static Future<List<Item>> fetchFriendItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final friendsRes = await supabase.from('friends').select('friend_id').eq('user_id', user.id).eq('status', 'accepted');
    final List friendRows = friendsRes as List? ?? [];
    final friendIds = friendRows.map((r) => r['friend_id'].toString()).toList();
    if (friendIds.isEmpty) return [];

    final res = await supabase.from('items').select().inFilter('user_id', friendIds).order('created_at', ascending: false);
    return _mapListToItems(res);
  }

  static Future<List<Item>> fetchTrendingItems({int limit = 12}) async {
    final res = await supabase.from('items').select().order('trust_score', ascending: false).limit(limit);
    return _mapListToItems(res);
  }

  // filters: category, condition, sort (Newest/Closest/Highest Trust), radiusKm
  static Future<List<Item>> fetchFilteredItems(Map<String, dynamic> filters) async {
    dynamic builder = supabase.from('items').select();

    final category = filters['category'] as String?;
    final condition = filters['condition'] as String?;
    final sort = filters['sort'] as String?;
    final radius = filters['radiusKm'] as num?;

    if (category != null && category.isNotEmpty && category != 'All') builder = builder.eq('category', category);
    if (condition != null && condition.isNotEmpty && condition != 'All') builder = builder.eq('condition', condition);
    if (radius != null) builder = builder.lte('radius_km', radius);

    if (sort == 'Closest') {
      builder = (builder as PostgrestTransformBuilder).order('radius_km', ascending: true);
    } else if (sort == 'Highest Trust') {
      builder = (builder as PostgrestTransformBuilder).order('trust_score', ascending: false);
    } else {
      builder = (builder as PostgrestTransformBuilder).order('created_at', ascending: false);
    }

    final res = await builder;
    return _mapListToItems(res);
  }

  static Future<void> addItem({
    required String title,
    required String description,
    required String category,
    required String condition,
    List<String>? tags,
    double? radiusKm,
    String? imageUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('items').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'tags': tags ?? [],
      'radius_km': radiusKm ?? 5,
      'image_url': imageUrl,
    });
  }
}
