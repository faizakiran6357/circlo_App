
// import 'package:circlo_app/services/supabase_item_service.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:flutter/material.dart';
// import '../models/item_model.dart';

// class ItemsProvider extends ChangeNotifier {
//   // 🧠 Core Lists
//   List<Item> _nearbyItems = [];
//   List<Item> _trendingItems = [];
//   List<Item> _friendItems = [];

//   // 🧠 Loading states
//   bool loadingNearby = false;
//   bool loadingTrending = false;
//   bool loadingFriends = false;

//   // 🧠 Radius & Filters
//   double _selectedRadius = 30; // default 30 km
//   Map<String, dynamic> appliedFilters = {};

//   // 🧠 Getters
//   List<Item> get nearbyItems => _nearbyItems;
//   List<Item> get trendingItems => _trendingItems;
//   List<Item> get friendItems => _friendItems;
//   double get selectedRadius => _selectedRadius;

//   // 🧩 Set selected radius
//   void setSelectedRadius(double radius) {
//     _selectedRadius = radius;
//     notifyListeners();
//   }

//   // 🔁 Load Nearby Items
//   Future<void> loadNearby() async {
//     try {
//       loadingNearby = true;
//       notifyListeners();

//       final fetchedItems = await SupabaseItemService.fetchNearbyItems(_selectedRadius);
//       _nearbyItems = fetchedItems;

//     } catch (e) {
//       debugPrint("❌ Error loading nearby items: $e");
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   // 🔁 Load Trending Items
//   Future<void> loadTrending() async {
//     try {
//       loadingTrending = true;
//       notifyListeners();

//       final fetchedItems = await SupabaseItemService.fetchTrendingItems();
//       _trendingItems = fetchedItems;

//     } catch (e) {
//       debugPrint("❌ Error loading trending items: $e");
//     } finally {
//       loadingTrending = false;
//       notifyListeners();
//     }
//   }

//   // 🔁 Load Friend Items
//   Future<void> loadFriends() async {
//     try {
//       loadingFriends = true;
//       notifyListeners();

//       final fetchedItems = await SupabaseItemService.fetchFriendItems();
//       _friendItems = fetchedItems;

//     } catch (e) {
//       debugPrint("❌ Error loading friend items: $e");
//       _friendItems = [];
//     } finally {
//       loadingFriends = false;
//       notifyListeners();
//     }
//   }

//   // 🎯 Apply filters
//   void applyFilters(Map<String, dynamic> filters) {
//     appliedFilters = filters;
//     notifyListeners();
//   }

//   // 🔁 Refresh current tab manually
//   Future<void> refreshCurrent(int tabIndex) async {
//     switch (tabIndex) {
//       case 0:
//         await loadNearby();
//         break;
//       case 2:
//         await loadTrending();
//         break;
//       default:
//         break;
//     }
//   }

//   // 🗑️ Delete Item
//   Future<void> deleteItem(String id) async {
//     try {
//       await SupabaseItemService.deleteItem(id);
//       _nearbyItems.removeWhere((item) => item.id == id);
//       _trendingItems.removeWhere((item) => item.id == id);
//       _friendItems.removeWhere((item) => item.id == id);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('❌ Delete error: $e');
//     }
//   }

//   // 🖊️ Edit Item
//   Future<bool?> editItem(BuildContext context, Item item) async {
//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => OfferItemScreen(itemToEdit: item),
//       ),
//     );
//     return result; // true if updated, null otherwise
//   }
// }
import 'package:circlo_app/services/supabase_item_service.dart';
import 'package:circlo_app/ui/home/offer_item_screen.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemsProvider extends ChangeNotifier {
  // 🧠 Core Lists
  List<Item> _nearbyItems = [];
  List<Item> _trendingItems = [];
  List<Item> _friendItems = [];

  // 🧠 Loading states
  bool loadingNearby = false;
  bool loadingTrending = false;
  bool loadingFriends = false;

  // 🧠 Radius & Filters
  double _selectedRadius = 30; // default 30 km
  Map<String, dynamic> appliedFilters = {};

  // 🧠 Getters
  List<Item> get nearbyItems => _nearbyItems;
  List<Item> get trendingItems => _trendingItems;
  List<Item> get friendItems => _friendItems;
  double get selectedRadius => _selectedRadius;

  // 🧩 Set selected radius
  void setSelectedRadius(double radius) {
    _selectedRadius = radius;
    notifyListeners();
  }

  // 🔁 Load Nearby Items
  Future<void> loadNearby() async {
    try {
      loadingNearby = true;
      notifyListeners();

      final fetchedItems =
          await SupabaseItemService.fetchNearbyItems(_selectedRadius);
      _nearbyItems = fetchedItems;
    } catch (e) {
      debugPrint("❌ Error loading nearby items: $e");
    } finally {
      loadingNearby = false;
      notifyListeners();
    }
  }

  // 🔁 Load Trending Items
  Future<void> loadTrending() async {
    try {
      loadingTrending = true;
      notifyListeners();

      final fetchedItems = await SupabaseItemService.fetchTrendingItems();
      _trendingItems = fetchedItems;
    } catch (e) {
      debugPrint("❌ Error loading trending items: $e");
    } finally {
      loadingTrending = false;
      notifyListeners();
    }
  }

  // 🔁 Load Friend Items (Updated)
  Future<void> loadFriends() async {
    try {
      loadingFriends = true;
      notifyListeners();

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint("⚠️ No logged-in user — cannot load friend posts");
        _friendItems = [];
        return;
      }

      final fetchedItems = await SupabaseItemService.fetchFriendItems();

      if (fetchedItems.isEmpty) {
        debugPrint("ℹ️ No posts found from friends yet.");
      } else {
        debugPrint("✅ Loaded ${fetchedItems.length} posts from friends.");
      }

      _friendItems = fetchedItems;
    } catch (e) {
      debugPrint("❌ Error loading friend items: $e");
      _friendItems = [];
    } finally {
      loadingFriends = false;
      notifyListeners();
    }
  }

  // 🎯 Apply filters
  void applyFilters(Map<String, dynamic> filters) {
    appliedFilters = filters;
    notifyListeners();
  }

  // 🔁 Refresh current tab manually
  Future<void> refreshCurrent(int tabIndex) async {
    switch (tabIndex) {
      case 0:
        await loadNearby();
        break;
      case 1:
        await loadFriends();
        break;
      case 2:
        await loadTrending();
        break;
      default:
        break;
    }
  }

  // 🗑️ Delete Item
  Future<void> deleteItem(String id) async {
    try {
      await SupabaseItemService.deleteItem(id);
      _nearbyItems.removeWhere((item) => item.id == id);
      _trendingItems.removeWhere((item) => item.id == id);
      _friendItems.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Delete error: $e');
    }
  }

  // 🖊️ Edit Item
  Future<bool?> editItem(BuildContext context, Item item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OfferItemScreen(itemToEdit: item),
      ),
    );
    return result; // true if updated, null otherwise
  }
}
