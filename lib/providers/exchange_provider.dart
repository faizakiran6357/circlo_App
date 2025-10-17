
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exchange_model.dart';
import '../services/exchange_service.dart';

class ExchangeProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Exchange> exchanges = [];
  bool loading = false;

  /// 🟢 Load all exchanges for the current user
  Future<void> loadExchanges() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    try {
      final res = await ExchangeService.fetchUserExchanges(user.id);
      exchanges = res;
      debugPrint('✅ Loaded ${res.length} exchanges for ${user.email}');
    } catch (e) {
      debugPrint('❌ Error loading exchanges: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 🟢 Update status (Accept / Reject / Completed / Closed)
  Future<void> updateStatus(String exchangeId, String status) async {
    try {
      await ExchangeService.updateExchangeStatus(exchangeId, status);
      final index = exchanges.indexWhere((e) => e.id == exchangeId);
      if (index != -1) {
        exchanges[index] =
            exchanges[index].copyWith(status: status, updatedAt: DateTime.now());
      }
      notifyListeners();
      debugPrint('✅ Exchange $exchangeId status updated to $status');
    } catch (e) {
      debugPrint('❌ Failed to update exchange status: $e');
    }
  }

  /// 🟢 Real-time listener (Supabase Flutter v2+ compatible)
  void startRealtimeSync() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final channel = _supabase.channel('exchanges-changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'exchanges',
      callback: (payload) {
        final newData = payload.newRecord ?? payload.oldRecord;
        if (newData == null) return;

        final exchange = Exchange.fromMap(Map<String, dynamic>.from(newData));
        final index = exchanges.indexWhere((e) => e.id == exchange.id);

        if (index != -1) {
          exchanges[index] = exchange;
        } else {
          exchanges.insert(0, exchange);
        }

        debugPrint('🔁 Exchange change detected → ${exchange.status}');
        notifyListeners();
      },
    );

    channel.subscribe();
    debugPrint('🟢 Real-time sync started for exchanges table');
  }

  /// 🟢 Fetch completed exchanges for history screen
  Future<List<Map<String, dynamic>>> fetchCompletedExchanges() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final res = await _supabase
          .from('exchanges')
          .select(
            '*, items!exchanges_item_id_fkey(title, image_url), users!exchanges_proposer_id_fkey(display_name, avatar_url)',
          )
          .or('proposer_id.eq.${user.id},item_id.in.(select id from items where user_id = ${user.id})')
          .inFilter('status', ['completed', 'closed'])
          .order('updated_at', ascending: false);

      return (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching completed exchanges: $e');
      return [];
    }
  }
}
