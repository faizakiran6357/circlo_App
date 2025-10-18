
// import 'dart:typed_data';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';
// import '../models/item_model.dart';

// class SupabaseItemService {
//   static final SupabaseClient supabase = Supabase.instance.client;
//   static final _uuid = const Uuid();

//   // ----------------------------------------------------------
//   // 🟢 Helper — map query results to Item model list
//   // ----------------------------------------------------------
//   static Future<List<Item>> _mapListToItems(dynamic res) async {
//     if (res == null) return [];
//     final List rows = res as List;
//     return rows.map((e) => Item.fromMap(Map<String, dynamic>.from(e))).toList();
//   }

//   // ----------------------------------------------------------
//   // 🟢 Fetch All Items
//   // ----------------------------------------------------------
//   static Future<List<Item>> fetchAllItems() async {
//     final res = await supabase
//         .from('items')
//         .select()
//         .order('created_at', ascending: false);
//     return _mapListToItems(res);
//   }

//   // ----------------------------------------------------------
//   // 🟢 Fetch Nearby Items
//   // ----------------------------------------------------------
//   static Future<List<Item>> fetchNearbyItems(double maxRadiusKm) async {
//     final res = await supabase
//         .from('items')
//         .select()
//         .lte('radius_km', maxRadiusKm)
//         .order('created_at', ascending: false);
//     return _mapListToItems(res);
//   }

//   // // ----------------------------------------------------------
//   // // 🟢 Fetch Friend Items
//   // // ----------------------------------------------------------
 
//     static Future<List<Item>> fetchFriendItems() async {
//   final user = supabase.auth.currentUser;
//   if (user == null) return [];

//   final friendsRes = await supabase
//       .from('friends')
//       .select('user_id, friend_id')
//       .or(
//         'and(user_id.eq.${user.id},status.eq.accepted),'
//         'and(friend_id.eq.${user.id},status.eq.accepted)',
//       );

//   final List friendRows = friendsRes as List? ?? [];
//   List<String> friendIds = [];

//   for (var f in friendRows) {
//     if (f['user_id'] == user.id) {
//       friendIds.add(f['friend_id'].toString());
//     } else {
//       friendIds.add(f['user_id'].toString());
//     }
//   }

//   if (friendIds.isEmpty) return [];

//   final res = await supabase
//       .from('items')
//       .select()
//       .inFilter('user_id', friendIds)
//       .order('created_at', ascending: false);

//   return _mapListToItems(res);
// }


//   // ----------------------------------------------------------
//   // 🟢 Fetch Trending Items (latest first)
//   // ----------------------------------------------------------
//   static Future<List<Item>> fetchTrendingItems({int limit = 50}) async {
//     final res = await supabase
//         .from('items')
//         .select()
//         .order('created_at', ascending: false)
//         .limit(limit);
//     return _mapListToItems(res);
//   }

//   // ----------------------------------------------------------
//   // 🟢 Fetch Filtered Items
//   // ----------------------------------------------------------
//   static Future<List<Item>> fetchFilteredItems(
//       Map<String, dynamic> filters) async {
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

//     if (sort == 'Closest') {
//       builder =
//           (builder as PostgrestTransformBuilder).order('radius_km', ascending: true);
//     } else if (sort == 'Highest Trust') {
//       builder =
//           (builder as PostgrestTransformBuilder).order('trust_score', ascending: false);
//     } else {
//       builder =
//           (builder as PostgrestTransformBuilder).order('created_at', ascending: false);
//     }

//     final res = await builder;
//     return _mapListToItems(res);
//   }

//   // ----------------------------------------------------------
//   // 🟢 Upload Image to Supabase Storage
//   // ----------------------------------------------------------
//   static Future<String?> uploadImageToStorage({
//     required Uint8List bytes,
//     String? filenamePrefix,
//   }) async {
//     final user = supabase.auth.currentUser;
//     if (user == null) throw Exception('User not authenticated');

//     final id = _uuid.v4();
//     final filename = '${filenamePrefix ?? user.id}-$id.jpg';
//     final path = 'items/$filename';

//     try {
//       final storage = supabase.storage.from('item-images');
//       await storage.uploadBinary(path, bytes);
//       final publicUrl = storage.getPublicUrl(path);
//       if (publicUrl is String) return publicUrl;

//       const projectUrl = 'https://rvsklnveacozabkgfptu.supabase.co';
//       return '$projectUrl/storage/v1/object/public/item-images/$path';
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // ----------------------------------------------------------
//   // 🟢 Add a New Item
//   // ----------------------------------------------------------
//   static Future<void> addItem({
//     required String title,
//     required String description,
//     required String category,
//     required String condition,
//     List<String>? tags,
//     double? radiusKm,
//     double? trustScore,
//     String? imageUrl,
//     Map<String, dynamic>? location,
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
//       'radius_km': radiusKm?.toDouble() ?? 10.0,
//       'trust_score': trustScore?.toDouble() ?? 0.0,
//       'image_url': imageUrl,
//       'location': location,
//       'created_at': DateTime.now().toIso8601String(),
//     });
//   }

//   // ----------------------------------------------------------
//   // 🟢 Update Existing Item
//   // ----------------------------------------------------------
//   static Future<void> updateItem({
//     required String id,
//     required String title,
//     required String description,
//     required String category,
//     required String condition,
//     required double radiusKm,
//     String? imageUrl,
//     Map<String, dynamic>? location,
//   }) async {
//     final updateData = {
//       'title': title,
//       'description': description,
//       'category': category,
//       'condition': condition,
//       'radius_km': radiusKm,
//       'image_url': imageUrl,
//       'location': location,
//       'updated_at': DateTime.now().toIso8601String(),
//     };

//     updateData.removeWhere((key, value) => value == null);

//     try {
//       await supabase.from('items').update(updateData).eq('id', id);
//     } catch (e) {
//       throw Exception('Update failed: $e');
//     }
//   }

//   // ----------------------------------------------------------
//   // 🟡 DELETE Item
//   // ----------------------------------------------------------
//   static Future<void> deleteItem(String id) async {
//     try {
//       await supabase.from('items').delete().eq('id', id);
//       print('✅ Item deleted successfully: $id');
//     } catch (e) {
//       print('❌ Supabase deleteItem error: $e');
//       rethrow;
//     }
//   }
//     // ----------------------------------------------------------
//   // 🟢 Fetch Current User's Items
//   // ----------------------------------------------------------
//   static Future<List<Item>> getCurrentUserItems() async {
//     final user = supabase.auth.currentUser;
//     if (user == null) throw Exception('User not authenticated');

//     try {
//       final res = await supabase
//           .from('items')
//           .select()
//           .eq('user_id', user.id)
//           .order('created_at', ascending: false);

//       return _mapListToItems(res);
//     } catch (e) {
//       print('❌ Error fetching current user items: $e');
//       rethrow;
//     }
//   }

// }
 import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';

class SupabaseItemService {
  static final SupabaseClient supabase = Supabase.instance.client;
  static final _uuid = const Uuid();

  // ----------------------------------------------------------
  // 🟢 Helper — map query results to Item model list
  // ----------------------------------------------------------
  static Future<List<Item>> _mapListToItems(dynamic res) async {
    if (res == null) return [];
    final List rows = res as List;
    return rows.map((e) => Item.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  // ----------------------------------------------------------
  // 🟢 Fetch All Items
  // ----------------------------------------------------------
  static Future<List<Item>> fetchAllItems() async {
    final res = await supabase
        .from('items')
        .select()
        .order('created_at', ascending: false);
    return _mapListToItems(res);
  }

  // ----------------------------------------------------------
  // 🟢 Fetch Nearby Items
  // ----------------------------------------------------------
  static Future<List<Item>> fetchNearbyItems(double maxRadiusKm) async {
    final res = await supabase
        .from('items')
        .select()
        .lte('radius_km', maxRadiusKm)
        .order('created_at', ascending: false);
    return _mapListToItems(res);
  }

  // 🟢 Fetch Nearby Items Paginated
  static Future<List<Item>> fetchNearbyItemsPaginated(double maxRadiusKm, {int page = 1, int limit = 7}) async {
    final from = (page - 1) * limit;
    final to = from + limit - 1;
    final res = await supabase
        .from('items')
        .select()
        .lte('radius_km', maxRadiusKm)
        .order('created_at', ascending: false)
        .range(from, to);
    return _mapListToItems(res);
  }

  // ----------------------------------------------------------
  // 🟢 Fetch Friend Items
  // ----------------------------------------------------------
  static Future<List<Item>> fetchFriendItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final friendsRes = await supabase
        .from('friends')
        .select('user_id, friend_id')
        .or(
          'and(user_id.eq.${user.id},status.eq.accepted),'
          'and(friend_id.eq.${user.id},status.eq.accepted)',
        );

    final List friendRows = friendsRes as List? ?? [];
    List<String> friendIds = [];

    for (var f in friendRows) {
      if (f['user_id'] == user.id) {
        friendIds.add(f['friend_id'].toString());
      } else {
        friendIds.add(f['user_id'].toString());
      }
    }

    if (friendIds.isEmpty) return [];

    final res = await supabase
        .from('items')
        .select()
        .inFilter('user_id', friendIds)
        .order('created_at', ascending: false);

    return _mapListToItems(res);
  }

  // 🟢 Fetch Friend Items Paginated
  static Future<List<Item>> fetchFriendItemsPaginated({int page = 1, int limit = 7}) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final friendsRes = await supabase
        .from('friends')
        .select('user_id, friend_id')
        .or(
          'and(user_id.eq.${user.id},status.eq.accepted),'
          'and(friend_id.eq.${user.id},status.eq.accepted)',
        );

    final List friendRows = friendsRes as List? ?? [];
    List<String> friendIds = [];

    for (var f in friendRows) {
      if (f['user_id'] == user.id) {
        friendIds.add(f['friend_id'].toString());
      } else {
        friendIds.add(f['user_id'].toString());
      }
    }

    if (friendIds.isEmpty) return [];

    final from = (page - 1) * limit;
    final to = from + limit - 1;

    final res = await supabase
        .from('items')
        .select()
        .inFilter('user_id', friendIds)
        .order('created_at', ascending: false)
        .range(from, to);

    return _mapListToItems(res);
  }

  // ----------------------------------------------------------
  // 🟢 Fetch Trending Items (latest first)
  // ----------------------------------------------------------
  static Future<List<Item>> fetchTrendingItems({int limit = 50}) async {
    final res = await supabase
        .from('items')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return _mapListToItems(res);
  }

  // 🟢 Fetch Trending Items Paginated
  static Future<List<Item>> fetchTrendingItemsPaginated({int page = 1, int limit = 7}) async {
    final from = (page - 1) * limit;
    final to = from + limit - 1;

    final res = await supabase
        .from('items')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);

    return _mapListToItems(res);
  }

  // ----------------------------------------------------------
  // 🟢 Fetch Filtered Items
  // ----------------------------------------------------------
  static Future<List<Item>> fetchFilteredItems(Map<String, dynamic> filters) async {
    dynamic builder = supabase.from('items').select();

    final category = filters['category'] as String?;
    final condition = filters['condition'] as String?;
    final sort = filters['sort'] as String?;
    final radius = filters['radiusKm'] as num?;

    if (category != null && category.isNotEmpty && category != 'All') {
      builder = builder.eq('category', category);
    }
    if (condition != null && condition.isNotEmpty && condition != 'All') {
      builder = builder.eq('condition', condition);
    }
    if (radius != null) {
      builder = builder.lte('radius_km', radius);
    }

    if (sort == 'Closest') {
      builder =
          (builder as PostgrestTransformBuilder).order('radius_km', ascending: true);
    } else if (sort == 'Highest Trust') {
      builder =
          (builder as PostgrestTransformBuilder).order('trust_score', ascending: false);
    } else {
      builder =
          (builder as PostgrestTransformBuilder).order('created_at', ascending: false);
    }

    final res = await builder;
    return _mapListToItems(res);
  }

  // ----------------------------------------------------------
  // 🟢 Upload Image to Supabase Storage
  // ----------------------------------------------------------
  static Future<String?> uploadImageToStorage({
    required Uint8List bytes,
    String? filenamePrefix,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final id = _uuid.v4();
    final filename = '${filenamePrefix ?? user.id}-$id.jpg';
    final path = 'items/$filename';

    try {
      final storage = supabase.storage.from('item-images');
      await storage.uploadBinary(path, bytes);
      final publicUrl = storage.getPublicUrl(path);
      if (publicUrl is String) return publicUrl;

      const projectUrl = 'https://rvsklnveacozabkgfptu.supabase.co';
      return '$projectUrl/storage/v1/object/public/item-images/$path';
    } catch (e) {
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // 🟢 Add a New Item
  // ----------------------------------------------------------
  static Future<void> addItem({
    required String title,
    required String description,
    required String category,
    required String condition,
    List<String>? tags,
    double? radiusKm,
    double? trustScore,
    String? imageUrl,
    Map<String, dynamic>? location,
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
      'radius_km': radiusKm?.toDouble() ?? 10.0,
      'trust_score': trustScore?.toDouble() ?? 0.0,
      'image_url': imageUrl,
      'location': location,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ----------------------------------------------------------
  // 🟢 Update Existing Item
  // ----------------------------------------------------------
  static Future<void> updateItem({
    required String id,
    required String title,
    required String description,
    required String category,
    required String condition,
    required double radiusKm,
    String? imageUrl,
    Map<String, dynamic>? location,
  }) async {
    final updateData = {
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'radius_km': radiusKm,
      'image_url': imageUrl,
      'location': location,
      'updated_at': DateTime.now().toIso8601String(),
    };

    updateData.removeWhere((key, value) => value == null);

    try {
      await supabase.from('items').update(updateData).eq('id', id);
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // ----------------------------------------------------------
  // 🟡 DELETE Item
  // ----------------------------------------------------------
  static Future<void> deleteItem(String id) async {
    try {
      await supabase.from('items').delete().eq('id', id);
      print('✅ Item deleted successfully: $id');
    } catch (e) {
      print('❌ Supabase deleteItem error: $e');
      rethrow;
    }
  }

  // ----------------------------------------------------------
  // 🟢 Fetch Current User's Items
  // ----------------------------------------------------------
  static Future<List<Item>> getCurrentUserItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final res = await supabase
          .from('items')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return _mapListToItems(res);
    } catch (e) {
      print('❌ Error fetching current user items: $e');
      rethrow;
    }
  }
}
