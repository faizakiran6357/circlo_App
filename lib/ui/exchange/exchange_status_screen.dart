
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/exchange_provider.dart';
// import '../../models/exchange_model.dart';
// import '../../utils/app_theme.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ExchangeStatusScreen extends StatefulWidget {
//   final Exchange exchange;
//   const ExchangeStatusScreen({super.key, required this.exchange});

//   @override
//   State<ExchangeStatusScreen> createState() => _ExchangeStatusScreenState();
// }

// class _ExchangeStatusScreenState extends State<ExchangeStatusScreen> {
//   Map<String, dynamic>? itemDetails;        // Requested item (other user's)
//   Map<String, dynamic>? offeredItemDetails; // Your offered item
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   Future<void> _loadItems() async {
//     try {
//       final supabase = Supabase.instance.client;

//       // Fetch requested item
//       final itemRes = await supabase
//           .from('items')
//           .select()
//           .eq('id', widget.exchange.itemId)
//           .maybeSingle();

//       // Fetch first offered item (if exists)
//       Map<String, dynamic>? offeredResData;
//       if (widget.exchange.offeredItemIds.isNotEmpty) {
//         offeredResData = await supabase
//             .from('items')
//             .select()
//             .eq('id', widget.exchange.offeredItemIds.first)
//             .maybeSingle();
//       }

//       setState(() {
//         itemDetails = itemRes as Map<String, dynamic>?;
//         offeredItemDetails = offeredResData as Map<String, dynamic>?;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//       debugPrint('❌ Error loading items: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ExchangeProvider>(context, listen: false);
//     final currentUserId = Supabase.instance.client.auth.currentUser!.id;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Exchange Details'),
//         backgroundColor: kGreen,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ---------------- EXCHANGE INFO ----------------
//                   Text(
//                     'Exchange ID: ${widget.exchange.id}',
//                     style: const TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Status: ${widget.exchange.status.toUpperCase()}',
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const Divider(height: 30),

//                   // ---------------- OTHER USER'S ITEM ----------------
//                   const Text('📦 Requested Item:',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 8),
//                   _buildItemCard(
//                     title: itemDetails?['title'] ?? 'Unknown Item',
//                     imageUrl: itemDetails?['image_url'],
//                     description: itemDetails?['description'] ??
//                         'No description available.',
//                   ),
//                   const SizedBox(height: 20),

//                   // ---------------- YOUR OFFERED ITEM ----------------
//                   const Text('🔁 Offered Item:',
//                       style:
//                           TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 8),
//                   _buildItemCard(
//                     title: offeredItemDetails?['title'] ?? 'Unknown Item',
//                     imageUrl: offeredItemDetails?['image_url'],
//                     description: offeredItemDetails?['description'] ??
//                         'No description available.',
//                   ),
//                   const SizedBox(height: 20),

//                   // ---------------- PROPOSER INFO ----------------
//                   ListTile(
//                     leading: widget.exchange.proposer?['avatar_url'] != null
//                         ? CircleAvatar(
//                             backgroundImage: NetworkImage(
//                                 widget.exchange.proposer!['avatar_url']),
//                           )
//                         : const CircleAvatar(child: Icon(Icons.person)),
//                     title: Text(widget.exchange.proposer?['display_name'] ??
//                         'Unknown User'),
//                     subtitle: const Text('Proposal Owner'),
//                   ),
//                   const Divider(height: 30),

//                   // ---------------- ACTION BUTTONS ----------------
//                   // Accept button only for incoming proposals
//                   if (widget.exchange.status == 'proposed' &&
//                       widget.exchange.proposerId != currentUserId)
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.check),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           minimumSize: const Size(double.infinity, 45)),
//                       onPressed: () async {
//                         await provider.updateStatus(
//                             widget.exchange.id, 'accepted');
//                         if (context.mounted) Navigator.pop(context, true);
//                       },
//                       label: const Text('Accept Exchange'),
//                     ),

//                   if (widget.exchange.status == 'accepted')
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.done_all),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           minimumSize: const Size(double.infinity, 45)),
//                       onPressed: () async {
//                         await provider.updateStatus(
//                             widget.exchange.id, 'completed');
//                         if (context.mounted) Navigator.pop(context, true);
//                       },
//                       label: const Text('Mark as Completed'),
//                     ),

//                   if (widget.exchange.status == 'completed')
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.close),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           minimumSize: const Size(double.infinity, 45)),
//                       onPressed: () async {
//                         await provider.updateStatus(
//                             widget.exchange.id, 'closed');
//                         if (context.mounted) Navigator.pop(context, true);
//                       },
//                       label: const Text('Close Exchange'),
//                     ),
//                 ],
//               ),
//             ),
//     );
//   }

//   /// Helper widget for showing item details
//   Widget _buildItemCard({
//     required String title,
//     String? imageUrl,
//     required String description,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: imageUrl != null
//                   ? Image.network(
//                       imageUrl,
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                     )
//                   : Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.grey[300],
//                       child:
//                           const Icon(Icons.image_not_supported, size: 40),
//                     ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 6),
//                   Text(
//                     description,
//                     style: const TextStyle(color: Colors.black87),
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:circlo_app/ui/profile/add_review_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/exchange_provider.dart';
// import '../../models/exchange_model.dart';
// import '../../utils/app_theme.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// class ExchangeStatusScreen extends StatefulWidget {
//   final Exchange exchange;
//   const ExchangeStatusScreen({super.key, required this.exchange});

//   @override
//   State<ExchangeStatusScreen> createState() => _ExchangeStatusScreenState();
// }

// class _ExchangeStatusScreenState extends State<ExchangeStatusScreen> {
//   Map<String, dynamic>? itemDetails;        
//   Map<String, dynamic>? offeredItemDetails; 
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   Future<void> _loadItems() async {
//     try {
//       final supabase = Supabase.instance.client;

//       final itemRes = await supabase
//           .from('items')
//           .select()
//           .eq('id', widget.exchange.itemId)
//           .maybeSingle();

//       Map<String, dynamic>? offeredResData;
//       if (widget.exchange.offeredItemIds.isNotEmpty) {
//         offeredResData = await supabase
//             .from('items')
//             .select()
//             .eq('id', widget.exchange.offeredItemIds.first)
//             .maybeSingle();
//       }

//       setState(() {
//         itemDetails = itemRes as Map<String, dynamic>?;
//         offeredItemDetails = offeredResData as Map<String, dynamic>?;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//       debugPrint('❌ Error loading items: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ExchangeProvider>(context, listen: false);
//     final currentUserId = Supabase.instance.client.auth.currentUser!.id;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Exchange Details'),
//         backgroundColor: kGreen,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Exchange info
//                   Text('Exchange ID: ${widget.exchange.id}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                   const SizedBox(height: 4),
//                   Text('Status: ${widget.exchange.status.toUpperCase()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   const Divider(height: 30),

//                   // Requested item
//                   const Text('📦 Requested Item:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 8),
//                   _buildItemCard(title: itemDetails?['title'] ?? 'Unknown Item', imageUrl: itemDetails?['image_url'], description: itemDetails?['description'] ?? 'No description available.'),
//                   const SizedBox(height: 20),

//                   // Offered item
//                   const Text('🔁 Offered Item:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 8),
//                   _buildItemCard(title: offeredItemDetails?['title'] ?? 'Unknown Item', imageUrl: offeredItemDetails?['image_url'], description: offeredItemDetails?['description'] ?? 'No description available.'),
//                   const SizedBox(height: 20),

//                   // Proposer info
//                   ListTile(
//                     leading: widget.exchange.proposer?['avatar_url'] != null
//                         ? CircleAvatar(backgroundImage: NetworkImage(widget.exchange.proposer!['avatar_url']))
//                         : const CircleAvatar(child: Icon(Icons.person)),
//                     title: Text(widget.exchange.proposer?['display_name'] ?? 'Unknown User'),
//                     subtitle: const Text('Proposal Owner'),
//                   ),
//                   const Divider(height: 30),

//                   // Action buttons
//                   if (widget.exchange.status == 'proposed' && widget.exchange.proposerId != currentUserId)
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.check),
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 45)),
//                       onPressed: () async {
//                         await provider.updateStatus(widget.exchange.id, 'accepted');
//                         if (context.mounted) Navigator.pop(context, true);
//                       },
//                       label: const Text('Accept Exchange'),
//                     ),

//                   if (widget.exchange.status == 'accepted')
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.done_all),
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 45)),
//                       onPressed: () async {
//                         await provider.updateStatus(widget.exchange.id, 'completed');
//                         if (context.mounted) Navigator.pop(context, true);
//                       },
//                       label: const Text('Mark as Completed'),
//                     ),

//                   if (widget.exchange.status == 'completed')
//                     Column(
//                       children: [
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.close),
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 45)),
//                           onPressed: () async {
//                             await provider.updateStatus(widget.exchange.id, 'closed');
//                             if (context.mounted) Navigator.pop(context, true);
//                           },
//                           label: const Text('Close Exchange'),
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.rate_review),
//                           style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 45)),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => AddReviewScreen(
//                                   targetUserId: widget.exchange.proposerId,
//                                   exchangeId: widget.exchange.id,
//                                 ),
//                               ),
//                             );
//                           },
//                           label: const Text('Leave a Review'),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildItemCard({required String title, String? imageUrl, required String description}) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: imageUrl != null
//                   ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
//                   : Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 40)),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 6),
//                   Text(description, style: const TextStyle(color: Colors.black87), maxLines: 3, overflow: TextOverflow.ellipsis),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:circlo_app/ui/profile/add_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exchange_provider.dart';
import '../../models/exchange_model.dart';
import '../../utils/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExchangeStatusScreen extends StatefulWidget {
  final Exchange exchange;
  const ExchangeStatusScreen({super.key, required this.exchange});

  @override
  State<ExchangeStatusScreen> createState() => _ExchangeStatusScreenState();
}

class _ExchangeStatusScreenState extends State<ExchangeStatusScreen> {
  Map<String, dynamic>? itemDetails;
  Map<String, dynamic>? offeredItemDetails;
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

      Map<String, dynamic>? offeredResData;
      if (widget.exchange.offeredItemIds.isNotEmpty) {
        offeredResData = await supabase
            .from('items')
            .select()
            .eq('id', widget.exchange.offeredItemIds.first)
            .maybeSingle();
      }

      setState(() {
        itemDetails = itemRes as Map<String, dynamic>?;
        offeredItemDetails = offeredResData as Map<String, dynamic>?;
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
                  // Exchange info
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

                  // Requested item
                  const Text(
                    '📦 Requested Item:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildItemCard(
                    title: itemDetails?['title'] ?? 'Unknown Item',
                    imageUrl: itemDetails?['image_url'],
                    description:
                        itemDetails?['description'] ?? 'No description available.',
                  ),
                  const SizedBox(height: 20),

                  // Offered item
                  const Text(
                    '🔁 Offered Item:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildItemCard(
                    title: offeredItemDetails?['title'] ?? 'Unknown Item',
                    imageUrl: offeredItemDetails?['image_url'],
                    description:
                        offeredItemDetails?['description'] ?? 'No description available.',
                  ),
                  const SizedBox(height: 20),

                  // Proposer info
                  ListTile(
                    leading: widget.exchange.proposer?['avatar_url'] != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                widget.exchange.proposer!['avatar_url']))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(widget.exchange.proposer?['display_name'] ??
                        'Unknown User'),
                    subtitle: const Text('Proposal Owner'),
                  ),
                  const Divider(height: 30),

                  // ------------------ ACTION BUTTONS ------------------

                  // ✅ Accept exchange (for incoming proposal)
                  if (widget.exchange.status == 'proposed' &&
                      widget.exchange.proposerId != currentUserId)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () async {
                        await provider.updateStatus(
                            widget.exchange.id, 'accepted');
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      label: const Text('Accept Exchange'),
                    ),

                  // ✅ Mark as completed (after accepted)
                  if (widget.exchange.status == 'accepted')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.done_all),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () async {
                        await provider.updateStatus(
                            widget.exchange.id, 'completed');
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      label: const Text('Mark as Completed'),
                    ),

                  // ✅ Close + Review (only for incoming proposals)
                  if (widget.exchange.status == 'completed' &&
                      isIncomingProposal)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          onPressed: () async {
                            await provider.updateStatus(
                                widget.exchange.id, 'closed');
                            if (context.mounted) Navigator.pop(context, true);
                          },
                          label: const Text('Close Exchange'),
                        ),
                        const SizedBox(height: 10),

                        // 🟢 Leave a Review — only for incoming proposals
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
                  ? Image.network(imageUrl,
                      width: 80, height: 80, fit: BoxFit.cover)
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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