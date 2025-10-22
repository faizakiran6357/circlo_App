
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exchange_model.dart';

class ExchangeService {
  static final supabase = Supabase.instance.client;

  /// 🟢 Create new exchange proposal
  static Future<void> createExchangeProposal({
    required String itemId,
    required List<String> offeredItemIds,
    Map<String, dynamic>? meetupLocation,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await supabase.from('exchanges').insert({
      'item_id': itemId,
      'proposer_id': user.id,
      // Store as JSON (safe for text or jsonb column)
      'offered_item_ids': jsonEncode(offeredItemIds),
      'status': 'proposed',
      'meetup_location': meetupLocation,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ------------------------------------------------------------------
  // 🟢 Generic helper to update status
  // ------------------------------------------------------------------
  static Future<void> updateExchangeStatus(
      String exchangeId, String newStatus) async {
    await supabase.from('exchanges').update({
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', exchangeId);
  }

  // ------------------------------------------------------------------
  // 🟢 Actions
  // ------------------------------------------------------------------
  static Future<void> acceptProposal(String exchangeId) async =>
      updateExchangeStatus(exchangeId, 'accepted');

  static Future<void> rejectProposal(String exchangeId) async =>
      updateExchangeStatus(exchangeId, 'rejected');

  static Future<void> markCompleted(String exchangeId) async =>
      updateExchangeStatus(exchangeId, 'completed');

  // ------------------------------------------------------------------
  // 🟢 Fetch all exchanges related to current user (as proposer or owner)
  // ------------------------------------------------------------------
  static Future<List<Exchange>> fetchUserExchanges(String userId) async {
    final itemsRes =
        await supabase.from('items').select('id').eq('user_id', userId);
    final itemIds = (itemsRes as List).map((e) => e['id'].toString()).toList();

    final res = await supabase
        .from('exchanges')
        .select(
            '*, proposer:users!exchanges_proposer_id_fkey(display_name, avatar_url), item:items!exchanges_item_id_fkey(title, image_url, user_id)')
        .or(
            'proposer_id.eq.$userId,item_id.in.(${itemIds.map((id) => "'$id'").join(",")})')
        .order('created_at', ascending: false);

    return (res as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['offered_item_ids'] is String) {
        try {
          map['offered_item_ids'] = jsonDecode(map['offered_item_ids']);
        } catch (_) {
          map['offered_item_ids'] = [];
        }
      }
      return Exchange.fromMap(map);
    }).toList();
  }

  // ------------------------------------------------------------------
  // 🟢 Fetch incoming proposals (proposals to my items)
  // ------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchIncomingProposals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final myItemsRes =
        await supabase.from('items').select('id').eq('user_id', user.id);
    final itemIds =
        (myItemsRes as List).map((e) => e['id'].toString()).toList();

    if (itemIds.isEmpty) return [];

    final res = await supabase
        .from('exchanges')
        .select(
            '*, proposer:users!exchanges_proposer_id_fkey(display_name, avatar_url), item:items!exchanges_item_id_fkey(title, image_url)')
        .inFilter('item_id', itemIds)
        .order('created_at', ascending: false);

    return (res as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['offered_item_ids'] is String) {
        try {
          map['offered_item_ids'] = jsonDecode(map['offered_item_ids']);
        } catch (_) {
          map['offered_item_ids'] = [];
        }
      }
      return map;
    }).toList();
  }

  // ------------------------------------------------------------------
  // 🟢 Fetch outgoing proposals (sent by me)
  // ------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchMyProposals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('exchanges')
        .select(
            '*, item:items!exchanges_item_id_fkey(title, image_url), proposer:users!exchanges_proposer_id_fkey(display_name, avatar_url)')
        .eq('proposer_id', user.id)
        .order('created_at', ascending: false);

    return (res as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['offered_item_ids'] is String) {
        try {
          map['offered_item_ids'] = jsonDecode(map['offered_item_ids']);
        } catch (_) {
          map['offered_item_ids'] = [];
        }
      }
      return map;
    }).toList();
  }

  // ------------------------------------------------------------------
  // 🟢 Fetch completed or closed exchanges for history
  // ------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchCompletedExchanges() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('exchanges')
        .select(
            '*, proposer:users!exchanges_proposer_id_fkey(display_name, avatar_url), item:items!exchanges_item_id_fkey(title, image_url)')
        .inFilter('status', ['completed', 'closed'])
        .or('proposer_id.eq.${user.id},item.user_id.eq.${user.id}')
        .order('created_at', ascending: false);

    return (res as List).map((e) {
      final map = Map<String, dynamic>.from(e);
      if (map['offered_item_ids'] is String) {
        try {
          map['offered_item_ids'] = jsonDecode(map['offered_item_ids']);
        } catch (_) {
          map['offered_item_ids'] = [];
        }
      }
      return map;
    }).toList();
  }

  static Future<void> deleteExchange(String id) async {
    await supabase.from('exchanges').delete().eq('id', id);
  }
}