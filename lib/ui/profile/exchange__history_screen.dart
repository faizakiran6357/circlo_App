
import 'package:circlo_app/ui/exchange/exchange_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../../models/exchange_model.dart';

class ExchangeHistoryScreen extends StatefulWidget {
  const ExchangeHistoryScreen({super.key});

  @override
  State<ExchangeHistoryScreen> createState() => _ExchangeHistoryScreenState();
}

class _ExchangeHistoryScreenState extends State<ExchangeHistoryScreen> {
  List<Map<String, dynamic>> exchanges = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadExchanges();
  }

  Future<void> _loadExchanges() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('exchanges')
        .select()
        .or('proposer_id.eq.${user.id},item.user_id.eq.${user.id}');

    setState(() {
      exchanges = List<Map<String, dynamic>>.from(res as List);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Exchange History'), backgroundColor: kGreen),
      body: exchanges.isEmpty
          ? const Center(child: Text('No exchanges yet'))
          : ListView.builder(
              itemCount: exchanges.length,
              itemBuilder: (_, i) {
                final exchange = exchanges[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Exchange ${exchange['id']}'),
                    subtitle: Text('Status: ${exchange['status']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExchangeStatusScreen(
                            exchange: Exchange.fromMap(exchange),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
