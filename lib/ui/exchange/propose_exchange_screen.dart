import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/exchange_service.dart';
import '../../services/supabase_item_service.dart';
import '../../models/item_model.dart';
import '../../utils/app_theme.dart';

class ProposeExchangeScreen extends StatefulWidget {
  final String targetItemId;
  const ProposeExchangeScreen({super.key, required this.targetItemId});

  @override
  State<ProposeExchangeScreen> createState() => _ProposeExchangeScreenState();
}

class _ProposeExchangeScreenState extends State<ProposeExchangeScreen> {
  List<Item> myItems = [];
  final selectedIds = <String>{};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyItems();
  }

  Future<void> _loadMyItems() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res = await SupabaseItemService.fetchAllItems();
    setState(() {
      myItems = res.where((i) => i.userId == user.id).toList();
      loading = false;
    });
  }

  Future<void> _submit() async {
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item')),
      );
      return;
    }

    await ExchangeService.createExchangeProposal(
      itemId: widget.targetItemId,
      offeredItemIds: selectedIds.toList(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exchange proposal sent!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propose Exchange'),
        backgroundColor: kGreen,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : myItems.isEmpty
              ? const Center(child: Text('You have no active items.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: myItems.length,
                        itemBuilder: (context, i) {
                          final item = myItems[i];
                          final selected = selectedIds.contains(item.id);
                          return ListTile(
                            leading: Image.network(
                              item.imageUrl ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(item.title),
                            trailing: Checkbox(
                              value: selected,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    selectedIds.add(item.id);
                                  } else {
                                    selectedIds.remove(item.id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: _submit,
                        child: const Text('Send Proposal'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
