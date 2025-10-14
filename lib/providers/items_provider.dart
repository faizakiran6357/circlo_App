// import 'package:flutter/material.dart';
// import '../models/item_model.dart';
// import '../services/supabase_item_service.dart';

// class ItemsProvider extends ChangeNotifier {
//   List<Item> nearbyItems = [];
//   List<Item> friendItems = [];
//   List<Item> trendingItems = [];

//   bool loadingNearby = false;
//   bool loadingFriends = false;
//   bool loadingTrending = false;

//   Map<String, dynamic> appliedFilters = {};

//   ItemsProvider() {
//     loadAll();
//   }

//   Future<void> loadAll() async {
//     await Future.wait([loadNearby(), loadFriends(), loadTrending()]);
//   }

//   Future<void> loadNearby({double radiusKm = 50}) async {
//     loadingNearby = true;
//     notifyListeners();
//     try {
//       final items = await SupabaseItemService.fetchNearbyItems(radiusKm);
//       nearbyItems = items;
//     } catch (e) {
//       debugPrint('loadNearby error: $e');
//       nearbyItems = [];
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadFriends() async {
//     loadingFriends = true;
//     notifyListeners();
//     try {
//       friendItems = await SupabaseItemService.fetchFriendItems();
//     } catch (e) {
//       debugPrint('loadFriends error: $e');
//       friendItems = [];
//     } finally {
//       loadingFriends = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadTrending() async {
//     loadingTrending = true;
//     notifyListeners();
//     try {
//       trendingItems = await SupabaseItemService.fetchTrendingItems();
//     } catch (e) {
//       debugPrint('loadTrending error: $e');
//       trendingItems = [];
//     } finally {
//       loadingTrending = false;
//       notifyListeners();
//     }
//   }

//   Future<void> applyFilters(Map<String, dynamic> filters) async {
//     appliedFilters = filters;
//     loadingNearby = true;
//     notifyListeners();
//     try {
//       nearbyItems = await SupabaseItemService.fetchFilteredItems(filters);
//     } catch (e) {
//       debugPrint('applyFilters error: $e');
//       nearbyItems = [];
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   Future<void> refreshCurrent(int tabIndex) async {
//     if (tabIndex == 0) await loadNearby();
//     if (tabIndex == 1) await loadFriends();
//     if (tabIndex == 2) await loadTrending();
//   }
// }
// import 'package:flutter/material.dart';
// import '../models/item_model.dart';
// import '../services/supabase_item_service.dart';

// class ItemsProvider extends ChangeNotifier {
//   List<Item> nearbyItems = [];
//   List<Item> friendItems = [];
//   List<Item> trendingItems = [];

//   bool loadingNearby = false;
//   bool loadingFriends = false;
//   bool loadingTrending = false;

//   Map<String, dynamic> appliedFilters = {};

//   ItemsProvider() {
//     loadAll();
//   }

//   Future<void> loadAll() async {
//     await Future.wait([loadNearby(), loadFriends(), loadTrending()]);
//   }

//   Future<void> loadNearby({double radiusKm = 50}) async {
//     loadingNearby = true;
//     notifyListeners();
//     try {
//       final items = await SupabaseItemService.fetchNearbyItems(radiusKm);
//       nearbyItems = items;
//     } catch (e) {
//       debugPrint('loadNearby error: $e');
//       nearbyItems = [];
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadFriends() async {
//     loadingFriends = true;
//     notifyListeners();
//     try {
//       friendItems = await SupabaseItemService.fetchFriendItems();
//     } catch (e) {
//       debugPrint('loadFriends error: $e');
//       friendItems = [];
//     } finally {
//       loadingFriends = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadTrending() async {
//     loadingTrending = true;
//     notifyListeners();
//     try {
//       trendingItems = await SupabaseItemService.fetchTrendingItems();
//     } catch (e) {
//       debugPrint('loadTrending error: $e');
//       trendingItems = [];
//     } finally {
//       loadingTrending = false;
//       notifyListeners();
//     }
//   }

//   Future<void> applyFilters(Map<String, dynamic> filters) async {
//     appliedFilters = filters;
//     loadingNearby = true;
//     notifyListeners();
//     try {
//       nearbyItems = await SupabaseItemService.fetchFilteredItems(filters);
//     } catch (e) {
//       debugPrint('applyFilters error: $e');
//       nearbyItems = [];
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   Future<void> refreshCurrent(int tabIndex) async {
//     if (tabIndex == 0) await loadNearby();
//     if (tabIndex == 1) await loadFriends();
//     if (tabIndex == 2) await loadTrending();
//   }

//   // 🟩🟩🟩 Added Section: For HomeFeedScreen swipe actions

//   // ✅ Return the correct list based on active tab (default: nearby)
//   List<Item> get items => nearbyItems;

//   // 🗑️ Delete item (locally removes from list)
//   void deleteItem(String id) {
//     nearbyItems.removeWhere((item) => item.id == id);
//     notifyListeners();

//     // Optionally: delete from Supabase backend
//     SupabaseItemService.deleteItem(id).catchError((e) {
//       debugPrint('deleteItem error: $e');
//     });
//   }

//   // ✏️ Edit item (placeholder — can be replaced with real edit logic)
//   void editItem(BuildContext context, Item item) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Edit feature coming soon for ${item.title}')),
//     );
//   }

//   // 🟩🟩🟩 End Added Section
// }
// import 'package:flutter/material.dart';
// import '../services/supabase_item_service.dart';
// import '../models/item_model.dart';

// class ItemsProvider with ChangeNotifier {
//   List<Item> _nearbyItems = [];
//   List<Item> _trendingItems = [];
//   List<Item> _friendItems = [];

//   bool loadingNearby = false;
//   bool loadingTrending = false;
//   bool loadingFriends = false;

//   double? _selectedRadiusKm; // ✅ store radius from radius selection screen
//   Map<String, dynamic> appliedFilters = {};

//   List<Item> get nearbyItems => _nearbyItems;
//   List<Item> get trendingItems => _trendingItems;
//   List<Item> get friendItems => _friendItems;

//   // ✅ Call this from RadiusSelectionScreen after user picks radius
//   void setSelectedRadius(double radiusKm) {
//     _selectedRadiusKm = radiusKm;
//     notifyListeners();
//   }

//   // ✅ Load nearby items using current radius (default 100 km if not set)
//   Future<void> loadNearby() async {
//     try {
//       loadingNearby = true;
//       notifyListeners();

//       final radius = _selectedRadiusKm ?? 100.0;
//       _nearbyItems = await SupabaseItemService.fetchNearbyItems(radius);
//     } catch (e) {
//       debugPrint('❌ loadNearby error: $e');
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   // ✅ Load all trending items — no radius filter
//   Future<void> loadTrending() async {
//     try {
//       loadingTrending = true;
//       notifyListeners();
//       _trendingItems = await SupabaseItemService.fetchTrendingItems(limit: 50);
//     } catch (e) {
//       debugPrint('❌ loadTrending error: $e');
//     } finally {
//       loadingTrending = false;
//       notifyListeners();
//     }
//   }

//   Future<void> loadFriends() async {
//     try {
//       loadingFriends = true;
//       notifyListeners();
//       _friendItems = await SupabaseItemService.fetchFriendItems();
//     } catch (e) {
//       debugPrint('❌ loadFriends error: $e');
//     } finally {
//       loadingFriends = false;
//       notifyListeners();
//     }
//   }

//   // ✅ Refresh logic used by home feed tab bar refresh button
//   Future<void> refreshCurrent(int index) async {
//     if (index == 0) {
//       await loadNearby();
//     } else if (index == 1) {
//       await loadFriends();
//     } else {
//       await loadTrending();
//     }
//   }

//   // 🟢 Apply Filters (if using filter sheet)
//   Future<void> applyFilters(Map<String, dynamic> filters) async {
//     appliedFilters = filters;
//     notifyListeners();
//   }

//   // 🟢 Delete / Edit item integration (same as before)
//   Future<void> deleteItem(String id) async {
//     await SupabaseItemService.deleteItem(id);
//     _nearbyItems.removeWhere((e) => e.id == id);
//     _trendingItems.removeWhere((e) => e.id == id);
//     notifyListeners();
//   }

//   Future<void> editItem(BuildContext context, Item item) async {
//     // open edit UI if needed
//   }
// }
// import 'package:circlo_app/services/supabase_item_service.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:flutter/material.dart';
// import '../models/item_model.dart';


// class ItemsProvider extends ChangeNotifier {
//   // 🧠 Core Lists
//   List<Item> _nearbyItems = [];
//   List<Item> _trendingItems = [];

//   // 🧠 Loading states
//   bool loadingNearby = false;
//   bool loadingTrending = false;

//   // 🧠 Radius & Filters
//   double _selectedRadius = 30; // default 30 km
//   Map<String, dynamic> appliedFilters = {};

//   // 🧠 Getters
//   List<Item> get nearbyItems => _nearbyItems;
//   List<Item> get trendingItems => _trendingItems;
//   double get selectedRadius => _selectedRadius;

//   // 🧩 Set selected radius
//   void setSelectedRadius(double radius) {
//     _selectedRadius = radius;
//     notifyListeners();
//   }

//   // 🔁 Load Nearby Items (filtered by radius)
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

//   // 🎯 Apply filters (optional use in future)
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
//     // 🧠 Friends Feed Data
//   List<Item> _friendItems = [];
//   bool loadingFriends = false;

//   List<Item> get friendItems => _friendItems;

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


//   // // 🧰 Edit Item (called from HomeFeedScreen)
//   // void editItem(BuildContext context, Item item) {
//   //   // TODO: Implement edit logic or open edit screen
//   //   debugPrint("Editing item: ${item.title}");
//   // }

//   // // 🗑️ Delete Item
//   // Future<void> deleteItem(String id) async {
//   //   try {
//   //     await SupabaseItemService.deleteItem(id);
//   //     _nearbyItems.removeWhere((item) => item.id == id);
//   //     _trendingItems.removeWhere((item) => item.id == id);
//   //     notifyListeners();
//   //   } catch (e) {
//   //     debugPrint("❌ Error deleting item: $e");
//   //   }
//   // }
//   Future<void> deleteItem(String id) async {
//   try {
//     await SupabaseItemService.deleteItem(id);
//     nearbyItems.removeWhere((item) => item.id == id);
//     trendingItems.removeWhere((item) => item.id == id);
//     friendItems.removeWhere((item) => item.id == id);
//     notifyListeners();
//   } catch (e) {
//     debugPrint('Delete error: $e');
//   }
// }

// void editItem(BuildContext context, Item item) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => OfferItemScreen(itemToEdit: item), // ✅ use edit mode
//     ),
//   );
// }
// }
import 'package:circlo_app/services/supabase_item_service.dart';
import 'package:circlo_app/ui/home/offer_item_screen.dart';
import 'package:flutter/material.dart';
import '../models/item_model.dart';

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

      final fetchedItems = await SupabaseItemService.fetchNearbyItems(_selectedRadius);
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

  // 🔁 Load Friend Items
  Future<void> loadFriends() async {
    try {
      loadingFriends = true;
      notifyListeners();

      final fetchedItems = await SupabaseItemService.fetchFriendItems();
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
