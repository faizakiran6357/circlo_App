
import 'package:circlo_app/models/item_model.dart';
import 'package:circlo_app/ui/item_detail/item_detail_screen.dart';
import 'package:circlo_app/ui/profile/add_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/exchange_provider.dart';
import '../../models/exchange_model.dart';
import '../../utils/app_theme.dart';

class ExchangeStatusScreen extends StatefulWidget {
  final Exchange exchange;
  const ExchangeStatusScreen({super.key, required this.exchange});

  @override
  State<ExchangeStatusScreen> createState() => _ExchangeStatusScreenState();
}

class _ExchangeStatusScreenState extends State<ExchangeStatusScreen> {
  Map<String, dynamic>? itemDetails;
  List<Map<String, dynamic>> offeredItems = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final supabase = Supabase.instance.client;

      final itemRes = await supabase
          .from('items')
          .select()
          .eq('id', widget.exchange.itemId)
          .maybeSingle();

      List<Map<String, dynamic>> offeredItemsData = [];
      if (widget.exchange.offeredItemIds.isNotEmpty) {
        final offeredRes = await supabase
            .from('items')
            .select()
            .inFilter('id', widget.exchange.offeredItemIds);
        offeredItemsData = List<Map<String, dynamic>>.from(offeredRes);
      }

      setState(() {
        itemDetails = itemRes as Map<String, dynamic>?;
        offeredItems = offeredItemsData;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('❌ Error loading items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExchangeProvider>(context, listen: false);
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    final bool isIncomingProposal = widget.exchange.proposerId != currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Details'),
        backgroundColor: kGreen,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exchange ID: ${widget.exchange.id}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${widget.exchange.status.toUpperCase()}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 30),

                  const Text(
                    '📦 Requested Item:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Requested item — tapping opens ItemDetailScreen (convert map -> Item)
                  GestureDetector(
                    onTap: () {
                      if (itemDetails != null) {
                        try {
                          final itemModel = Item.fromMap(itemDetails!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(item: itemModel),
                            ),
                          );
                        } catch (e) {
                          debugPrint('❌ Failed to convert itemDetails to Item: $e');
                        }
                      }
                    },
                    child: _buildItemCard(
                      title: itemDetails?['title'] ?? 'Unknown Item',
                      imageUrl: itemDetails?['image_url'],
                      description:
                          itemDetails?['description'] ?? 'No description available.',
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    '🔁 Offered Items:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  if (offeredItems.isNotEmpty)
                    Column(
                      children: offeredItems.map((item) {
                        return GestureDetector(
                          onTap: () {
                            try {
                              final itemModel = Item.fromMap(item);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(item: itemModel),
                                ),
                              );
                            } catch (e) {
                              debugPrint('❌ Failed to convert offered item to Item: $e');
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildItemCard(
                              title: item['title'] ?? 'Unknown Item',
                              imageUrl: item['image_url'],
                              description:
                                  item['description'] ?? 'No description available.',
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text('No offered items found.'),
                  const SizedBox(height: 20),

                  ListTile(
                    leading: widget.exchange.proposer?['avatar_url'] != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.exchange.proposer!['avatar_url']))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(widget.exchange.proposer?['display_name'] ?? 'Unknown User'),
                    subtitle: const Text('Proposal Owner'),
                  ),
                  const Divider(height: 30),

                  // ---------- ACTION BUTTONS ----------
                  // If status is 'proposed' AND current user is the receiver -> show Accept + Reject
                  if (widget.exchange.status == 'proposed' && isIncomingProposal)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: () async {
                            await provider.updateStatus(widget.exchange.id, 'accepted');
                            if (context.mounted) Navigator.pop(context, true);
                          },
                          label: const Text('Accept Proposal'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: () async {
                            await provider.updateStatus(widget.exchange.id, 'rejected');
                            if (context.mounted) Navigator.pop(context, true);
                          },
                          label: const Text('Reject Proposal'),
                        ),
                      ],
                    )

                  // If status is 'accepted' -> show Mark as Completed (any side can mark completed)
                  else if (widget.exchange.status == 'accepted')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.done_all),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () async {
                        await provider.updateStatus(widget.exchange.id, 'completed');
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      label: const Text('Mark as Completed'),
                    )

                  // If status is 'completed' -> show only Leave a Review for incoming proposal
                  else if (widget.exchange.status == 'completed' && isIncomingProposal)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.rate_review),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddReviewScreen(
                                  targetUserId: widget.exchange.proposerId,
                                  exchangeId: widget.exchange.id,
                                ),
                              ),
                            );
                          },
                          label: const Text('Leave a Review'),
                        ),
                      ],
                    ),

                  // (no close button shown for completed)
                ],
              ),
            ),
    );
  }

  Widget _buildItemCard({
    required String title,
    String? imageUrl,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null
                  ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black87),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
