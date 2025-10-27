
// import 'package:circlo_app/services/supabase_item_service.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import '../models/item_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ItemsProvider extends ChangeNotifier {
//   // 🧠 Core Lists
//   List<Item> _nearbyItems = [];
//   List<Item> _trendingItems = [];
//   List<Item> _friendItems = [];

//   // 🧠 Pagination state
//   int nearbyPage = 1;
//   int trendingPage = 1;
//   int friendsPage = 1;
//   final int pageLimit = 7;

//   bool hasMoreNearby = true;
//   bool hasMoreTrending = true;
//   bool hasMoreFriends = true;

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

//   // 🧩 Set selected radius (safe call)
//   void setSelectedRadius(double radius) {
//     _selectedRadius = radius;

//     // ✅ Avoid notifying during widget build phase
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       notifyListeners();
//     });
//   }

//   // --------------------------------------------------------
//   // 🗺️ Load Nearby Items (paginated)
//   // --------------------------------------------------------
//   Future<void> loadNearby({bool reset = false}) async {
//     if (reset) {
//       nearbyPage = 1;
//       _nearbyItems = [];
//       hasMoreNearby = true;
//     }
//     if (!hasMoreNearby) return;

//     try {
//       loadingNearby = true;
//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

//       final position = await Geolocator.getCurrentPosition();

//       final fetchedItems = await SupabaseItemService.fetchNearbyItemsPaginated(
//         userLat: position.latitude,
//         userLng: position.longitude,
//         maxRadiusKm: _selectedRadius,
//         page: nearbyPage,
//         limit: pageLimit,
//       );

//       if (fetchedItems.length < pageLimit) hasMoreNearby = false;

//       final ids = _nearbyItems.map((e) => e.id).toSet();
//       final newItems = fetchedItems.where((e) => !ids.contains(e.id)).toList();

//       _nearbyItems.insertAll(0, newItems);
//       nearbyPage++;
//     } catch (e) {
//       debugPrint("❌ Error loading nearby items: $e");
//     } finally {
//       loadingNearby = false;
//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
//     }
//   }

//   // --------------------------------------------------------
//   // 🔁 Load Trending Items
//   // --------------------------------------------------------
//   Future<void> loadTrending({bool reset = false}) async {
//     if (reset) {
//       trendingPage = 1;
//       _trendingItems = [];
//       hasMoreTrending = true;
//     }
//     if (!hasMoreTrending) return;

//     try {
//       loadingTrending = true;
//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

//       final fetchedItems = await SupabaseItemService.fetchTrendingItemsPaginated(
//         page: trendingPage,
//         limit: pageLimit,
//       );

//       if (fetchedItems.length < pageLimit) hasMoreTrending = false;

//       _trendingItems.addAll(fetchedItems);
//       trendingPage++;
//     } catch (e) {
//       debugPrint("❌ Error loading trending items: $e");
//     } finally {
//       loadingTrending = false;
//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
//     }
//   }

//   // --------------------------------------------------------
//   // 🔁 Load Friend Items
//   // --------------------------------------------------------
//   Future<void> loadFriends({bool reset = false}) async {
//     if (reset) {
//       friendsPage = 1;
//       _friendItems = [];
//       hasMoreFriends = true;
//     }
//     if (!hasMoreFriends) return;

//     try {
//       loadingFriends = true;
//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

//       final fetchedItems = await SupabaseItemService.fetchFriendItemsPaginated(
//         page: friendsPage,
//         limit: pageLimit,
//       );

//       if (fetchedItems.length < pageLimit) hasMoreFriends = false;

//       _friendItems.addAll(fetchedItems);
//       friendsPage++;
//     } catch (e) {
//       debugPrint("❌ Error loading friend items: $e");
//     } finally {
//       loadingFriends = false;
//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
//     }
//   }

//   // --------------------------------------------------------
//   // 🎯 Apply filters
//   // --------------------------------------------------------
//   void applyFilters(Map<String, dynamic> filters) {
//     appliedFilters = filters;
//     WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
//   }

//   // --------------------------------------------------------
//   // 🔁 Refresh current tab manually
//   // --------------------------------------------------------
//   Future<void> refreshCurrent(int tabIndex) async {
//     switch (tabIndex) {
//       case 0:
//         await loadNearby(reset: true);
//         break;
//       case 1:
//         await loadFriends(reset: true);
//         break;
//       case 2:
//         await loadTrending(reset: true);
//         break;
//       default:
//         break;
//     }
//   }

//   // --------------------------------------------------------
//   // 🗑️ Delete Item
//   // --------------------------------------------------------
//   Future<void> deleteItem(String id) async {
//     try {
//       await SupabaseItemService.deleteItem(id);
//       _nearbyItems.removeWhere((item) => item.id == id);
//       _trendingItems.removeWhere((item) => item.id == id);
//       _friendItems.removeWhere((item) => item.id == id);

//       WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
//     } catch (e) {
//       debugPrint('❌ Delete error: $e');
//     }
//   }

//   // --------------------------------------------------------
//   // 🖊️ Edit Item
//   // --------------------------------------------------------
//   Future<bool?> editItem(BuildContext context, Item item) async {
//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => OfferItemScreen(itemToEdit: item),
//       ),
//     );
//     return result;
//   }

//   // --------------------------------------------------------
//   // 🔁 Refresh all tabs
//   // --------------------------------------------------------
//   Future<void> refreshAll() async {
//     await Future.wait([
//       loadNearby(reset: true),
//       loadFriends(reset: true),
//       loadTrending(reset: true),
//     ]);
//   }
// }
// import 'package:circlo_app/services/supabase_item_service.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import '../models/item_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ItemsProvider extends ChangeNotifier {
//   // 🧠 Core Lists
//   List<Item> _nearbyItems = [];
//   List<Item> _trendingItems = [];
//   List<Item> _friendItems = [];

//   // 🧠 Pagination state
//   int nearbyPage = 1;
//   int trendingPage = 1;
//   int friendsPage = 1;
//   final int pageLimit = 7;

//   bool hasMoreNearby = true;
//   bool hasMoreTrending = true;
//   bool hasMoreFriends = true;

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

//   // --------------------------------------------------------
//   // 🔁 Load Nearby Items (paginated)
//   // --------------------------------------------------------
//   Future<void> loadNearby({bool reset = false}) async {
//     if (loadingNearby) return; // ✅ prevent double-loading

//     if (reset) {
//       nearbyPage = 1;
//       _nearbyItems = [];
//       hasMoreNearby = true;
//     }
//     if (!hasMoreNearby) return;

//     try {
//       loadingNearby = true;
//       notifyListeners();

//       final position = await Geolocator.getCurrentPosition(); // ✅ get user location

//       final fetchedItems = await SupabaseItemService.fetchNearbyItemsPaginated(
//         userLat: position.latitude,
//         userLng: position.longitude,
//         maxRadiusKm: _selectedRadius,
//         page: nearbyPage,
//         limit: pageLimit,
//       );

//       if (fetchedItems.length < pageLimit) hasMoreNearby = false;

//       // ✅ Remove duplicates and append new ones at the bottom
//       final ids = _nearbyItems.map((e) => e.id).toSet();
//       final newItems = fetchedItems.where((e) => !ids.contains(e.id)).toList();

//       _nearbyItems.addAll(newItems);
//       nearbyPage++;
//     } catch (e) {
//       debugPrint("❌ Error loading nearby items: $e");
//     } finally {
//       loadingNearby = false;
//       notifyListeners();
//     }
//   }

//   // --------------------------------------------------------
//   // 🔁 Load Trending Items (paginated)
//   // --------------------------------------------------------
//   Future<void> loadTrending({bool reset = false}) async {
//     if (loadingTrending) return; // ✅ prevent double-loading

//     if (reset) {
//       trendingPage = 1;
//       _trendingItems = [];
//       hasMoreTrending = true;
//     }
//     if (!hasMoreTrending) return;

//     try {
//       loadingTrending = true;
//       notifyListeners();

//       final fetchedItems = await SupabaseItemService.fetchTrendingItemsPaginated(
//         page: trendingPage,
//         limit: pageLimit,
//       );

//       if (fetchedItems.length < pageLimit) hasMoreTrending = false;

//       _trendingItems.addAll(fetchedItems);
//       trendingPage++;
//     } catch (e) {
//       debugPrint("❌ Error loading trending items: $e");
//     } finally {
//       loadingTrending = false;
//       notifyListeners();
//     }
//   }

//   // --------------------------------------------------------
//   // 🔁 Load Friend Items (paginated)
//   // --------------------------------------------------------
//   Future<void> loadFriends({bool reset = false}) async {
//     if (loadingFriends) return; // ✅ prevent double-loading

//     if (reset) {
//       friendsPage = 1;
//       _friendItems = [];
//       hasMoreFriends = true;
//     }
//     if (!hasMoreFriends) return;

//     try {
//       loadingFriends = true;
//       notifyListeners();

//       final fetchedItems = await SupabaseItemService.fetchFriendItemsPaginated(
//         page: friendsPage,
//         limit: pageLimit,
//       );

//       if (fetchedItems.length < pageLimit) hasMoreFriends = false;

//       _friendItems.addAll(fetchedItems);
//       friendsPage++;
//     } catch (e) {
//       debugPrint("❌ Error loading friend items: $e");
//     } finally {
//       loadingFriends = false;
//       notifyListeners();
//     }
//   }

//   // --------------------------------------------------------
//   // 🎯 Apply filters
//   // --------------------------------------------------------
//   void applyFilters(Map<String, dynamic> filters) {
//     appliedFilters = filters;
//     notifyListeners();
//   }

//   // --------------------------------------------------------
//   // 🔁 Refresh current tab manually
//   // --------------------------------------------------------
//   Future<void> refreshCurrent(int tabIndex) async {
//     switch (tabIndex) {
//       case 0:
//         await loadNearby(reset: true);
//         break;
//       case 1:
//         await loadFriends(reset: true);
//         break;
//       case 2:
//         await loadTrending(reset: true);
//         break;
//       default:
//         break;
//     }
//   }

//   // --------------------------------------------------------
//   // 🗑️ Delete Item
//   // --------------------------------------------------------
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

//   // --------------------------------------------------------
//   // 🖊️ Edit Item
//   // --------------------------------------------------------
//   Future<bool?> editItem(BuildContext context, Item item) async {
//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => OfferItemScreen(itemToEdit: item),
//       ),
//     );
//     return result; // true if updated, null otherwise
//   }

//   // --------------------------------------------------------
//   // 🔁 Refresh all tabs
//   // --------------------------------------------------------
//   Future<void> refreshAll() async {
//     await Future.wait([
//       loadNearby(reset: true),
//       loadFriends(reset: true),
//       loadTrending(reset: true),
//     ]);
//   }
// }
import 'package:circlo_app/services/supabase_item_service.dart';
import 'package:circlo_app/ui/home/offer_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import '../models/item_model.dart';

class ItemsProvider extends ChangeNotifier {
  // 🧠 Core Lists
  List<Item> _nearbyItems = [];
  List<Item> _trendingItems = [];
  List<Item> _friendItems = [];

  // 🧠 Pagination state
  int nearbyPage = 1;
  int trendingPage = 1;
  int friendsPage = 1;
  final int pageLimit = 7;

  bool hasMoreNearby = true;
  bool hasMoreTrending = true;
  bool hasMoreFriends = true;

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

  // --------------------------------------------------------
  // 🎯 Set selected radius
  // --------------------------------------------------------
  void setSelectedRadius(double radius) {
    _selectedRadius = radius;
    _safeNotify();
  }

  // --------------------------------------------------------
  // 🔁 Load Nearby Items (paginated)
  // --------------------------------------------------------
  Future<void> loadNearby({bool reset = false}) async {
    if (loadingNearby) return;

    if (reset) {
      nearbyPage = 1;
      _nearbyItems = [];
      hasMoreNearby = true;
    }
    if (!hasMoreNearby) return;

    try {
      loadingNearby = true;
      _safeNotify();

      final position = await Geolocator.getCurrentPosition();

      final fetchedItems = await SupabaseItemService.fetchNearbyItemsPaginated(
        userLat: position.latitude,
        userLng: position.longitude,
        maxRadiusKm: _selectedRadius,
        page: nearbyPage,
        limit: pageLimit,
      );

      if (fetchedItems.length < pageLimit) hasMoreNearby = false;

      final ids = _nearbyItems.map((e) => e.id).toSet();
      final newItems = fetchedItems.where((e) => !ids.contains(e.id)).toList();

      _nearbyItems.addAll(newItems);
      nearbyPage++;
    } catch (e) {
      debugPrint("❌ Error loading nearby items: $e");
    } finally {
      loadingNearby = false;
      _safeNotify();
    }
  }

  // --------------------------------------------------------
  // 🔁 Load Trending Items (paginated)
  // --------------------------------------------------------
  Future<void> loadTrending({bool reset = false}) async {
    if (loadingTrending) return;

    if (reset) {
      trendingPage = 1;
      _trendingItems = [];
      hasMoreTrending = true;
    }
    if (!hasMoreTrending) return;

    try {
      loadingTrending = true;
      _safeNotify();

      final fetchedItems = await SupabaseItemService.fetchTrendingItemsPaginated(
        page: trendingPage,
        limit: pageLimit,
      );

      if (fetchedItems.length < pageLimit) hasMoreTrending = false;

      _trendingItems.addAll(fetchedItems);
      trendingPage++;
    } catch (e) {
      debugPrint("❌ Error loading trending items: $e");
    } finally {
      loadingTrending = false;
      _safeNotify();
    }
  }

  // --------------------------------------------------------
  // 🔁 Load Friend Items (paginated)
  // --------------------------------------------------------
  Future<void> loadFriends({bool reset = false}) async {
    if (loadingFriends) return;

    if (reset) {
      friendsPage = 1;
      _friendItems = [];
      hasMoreFriends = true;
    }
    if (!hasMoreFriends) return;

    try {
      loadingFriends = true;
      _safeNotify();

      final fetchedItems = await SupabaseItemService.fetchFriendItemsPaginated(
        page: friendsPage,
        limit: pageLimit,
      );

      if (fetchedItems.length < pageLimit) hasMoreFriends = false;

      _friendItems.addAll(fetchedItems);
      friendsPage++;
    } catch (e) {
      debugPrint("❌ Error loading friend items: $e");
    } finally {
      loadingFriends = false;
      _safeNotify();
    }
  }

  // --------------------------------------------------------
  // 🎯 Apply filters
  // --------------------------------------------------------
  void applyFilters(Map<String, dynamic> filters) {
    appliedFilters = filters;
    _safeNotify();
  }

  // --------------------------------------------------------
  // 🔁 Refresh current tab manually
  // --------------------------------------------------------
  Future<void> refreshCurrent(int tabIndex) async {
    switch (tabIndex) {
      case 0:
        await loadNearby(reset: true);
        break;
      case 1:
        await loadFriends(reset: true);
        break;
      case 2:
        await loadTrending(reset: true);
        break;
      default:
        break;
    }
  }

  // --------------------------------------------------------
  // 🗑️ Delete Item
  // --------------------------------------------------------
  Future<void> deleteItem(String id) async {
    try {
      await SupabaseItemService.deleteItem(id);
      _nearbyItems.removeWhere((item) => item.id == id);
      _trendingItems.removeWhere((item) => item.id == id);
      _friendItems.removeWhere((item) => item.id == id);
      _safeNotify();
    } catch (e) {
      debugPrint('❌ Delete error: $e');
    }
  }

  // --------------------------------------------------------
  // 🖊️ Edit Item
  // --------------------------------------------------------
  Future<bool?> editItem(BuildContext context, Item item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OfferItemScreen(itemToEdit: item),
      ),
    );
    return result;
  }

  // --------------------------------------------------------
  // 🔁 Refresh all tabs
  // --------------------------------------------------------
  Future<void> refreshAll() async {
    await Future.wait([
      loadNearby(reset: true),
      loadFriends(reset: true),
      loadTrending(reset: true),
    ]);
  }

  // --------------------------------------------------------
  // 🧩 Safe notifyListeners wrapper
  // --------------------------------------------------------
  void _safeNotify() {
    if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle ||
        WidgetsBinding.instance.schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}
