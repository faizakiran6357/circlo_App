import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/supabase_item_service.dart';

class ItemsProvider extends ChangeNotifier {
  List<Item> nearbyItems = [];
  List<Item> friendItems = [];
  List<Item> trendingItems = [];

  bool loadingNearby = false;
  bool loadingFriends = false;
  bool loadingTrending = false;

  Map<String, dynamic> appliedFilters = {};

  ItemsProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadNearby(), loadFriends(), loadTrending()]);
  }

  Future<void> loadNearby({double radiusKm = 50}) async {
    loadingNearby = true;
    notifyListeners();
    try {
      final items = await SupabaseItemService.fetchNearbyItems(radiusKm);
      nearbyItems = items;
    } catch (e) {
      debugPrint('loadNearby error: $e');
      nearbyItems = [];
    } finally {
      loadingNearby = false;
      notifyListeners();
    }
  }

  Future<void> loadFriends() async {
    loadingFriends = true;
    notifyListeners();
    try {
      friendItems = await SupabaseItemService.fetchFriendItems();
    } catch (e) {
      debugPrint('loadFriends error: $e');
      friendItems = [];
    } finally {
      loadingFriends = false;
      notifyListeners();
    }
  }

  Future<void> loadTrending() async {
    loadingTrending = true;
    notifyListeners();
    try {
      trendingItems = await SupabaseItemService.fetchTrendingItems();
    } catch (e) {
      debugPrint('loadTrending error: $e');
      trendingItems = [];
    } finally {
      loadingTrending = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    appliedFilters = filters;
    loadingNearby = true;
    notifyListeners();
    try {
      nearbyItems = await SupabaseItemService.fetchFilteredItems(filters);
    } catch (e) {
      debugPrint('applyFilters error: $e');
      nearbyItems = [];
    } finally {
      loadingNearby = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrent(int tabIndex) async {
    if (tabIndex == 0) await loadNearby();
    if (tabIndex == 1) await loadFriends();
    if (tabIndex == 2) await loadTrending();
  }
}
