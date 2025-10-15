// import 'package:circlo_app/ui/exchange/exchange_history_screen.dart';
// import 'package:flutter/material.dart';
// import '../../services/exchange_service.dart';
// import '../../utils/app_theme.dart';

// class ExchangeRequestsScreen extends StatefulWidget {
//   const ExchangeRequestsScreen({super.key});

//   @override
//   State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
// }

// class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen> {
//   List<Map<String, dynamic>> _proposals = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadProposals();
//   }

//   Future<void> _loadProposals() async {
//     setState(() => _loading = true);
//     try {
//       final data = await ExchangeService.fetchIncomingProposals();
//       setState(() => _proposals = data);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading proposals: $e')),
//       );
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Exchange Requests'), backgroundColor: kGreen,
//       actions: [
//         IconButton(
//   icon: const Icon(Icons.history), // 🕓 history icon
//   tooltip: 'Exchange History',
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ExchangeHistoryScreen()),
//     );
//   },
// ),
//       ],),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _proposals.isEmpty
//               ? const Center(child: Text('No exchange proposals yet'))
//               : RefreshIndicator(
//                   onRefresh: _loadProposals,
//                   child: ListView.builder(
//                     itemCount: _proposals.length,
//                     itemBuilder: (context, i) {
//                       final p = _proposals[i];
//                       final user = p['users'] ?? {};
//                       final status = p['status'] ?? 'proposed';
//                       return Card(
//                         margin: const EdgeInsets.all(8),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundImage: user['avatar_url'] != null
//                                 ? NetworkImage(user['avatar_url'])
//                                 : null,
//                             child: user['avatar_url'] == null
//                                 ? const Icon(Icons.person)
//                                 : null,
//                           ),
//                           title: Text(user['display_name'] ?? 'Unknown'),
//                           subtitle: Text('Status: $status'),
//                           trailing: status == 'proposed'
//                               ? Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.check, color: Colors.green),
//                                       onPressed: () async {
//                                         await ExchangeService.acceptProposal(p['id']);
//                                         _loadProposals();
//                                       },
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.close, color: Colors.red),
//                                       onPressed: () async {
//                                         await ExchangeService.rejectProposal(p['id']);
//                                         _loadProposals();
//                                       },
//                                     ),
//                                   ],
//                                 )
//                               : status == 'accepted'
//                                   ? TextButton(
//                                       onPressed: () async {
//                                         await ExchangeService.markCompleted(p['id']);
//                                         _loadProposals();
//                                       },
//                                       child: const Text('Mark Completed'),
//                                     )
//                                   : null,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/exchange_service.dart';
// import '../../utils/app_theme.dart';

// class ExchangeRequestsScreen extends StatefulWidget {
//   const ExchangeRequestsScreen({super.key});

//   @override
//   State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
// }

// class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen> {
//   bool loading = true;
//   List<Map<String, dynamic>> incoming = [];
//   List<Map<String, dynamic>> outgoing = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => loading = true);
//     try {
//       final inReq = await ExchangeService.fetchIncomingProposals();
//       final outReq = await ExchangeService.fetchMyProposals();
//       setState(() {
//         incoming = inReq;
//         outgoing = outReq;
//       });
//     } catch (e) {
//       debugPrint("❌ Error loading exchange data: $e");
//     } finally {
//       setState(() => loading = false);
//     }
//   }

//   Future<void> _accept(String id) async {
//     await ExchangeService.acceptProposal(id);
//     _loadData();
//   }

//   Future<void> _reject(String id) async {
//     await ExchangeService.rejectProposal(id);
//     _loadData();
//   }

//   Future<void> _complete(String id) async {
//     await ExchangeService.markCompleted(id);
//     _loadData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Exchange Requests'),
//         backgroundColor: kGreen,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _loadData,
//               child: ListView(
//                 padding: const EdgeInsets.all(8),
//                 children: [
//                   if (incoming.isNotEmpty)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 10, bottom: 5),
//                       child: Text('📥 Incoming Proposals',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16)),
//                     ),
//                   ...incoming.map((ex) => _buildExchangeCard(ex, true)),
//                   if (outgoing.isNotEmpty)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 20, bottom: 5),
//                       child: Text('📤 Sent Proposals',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16)),
//                     ),
//                   ...outgoing.map((ex) => _buildExchangeCard(ex, false)),
//                   if (incoming.isEmpty && outgoing.isEmpty)
//                     const Center(
//                       child: Padding(
//                         padding: EdgeInsets.only(top: 50),
//                         child: Text("No exchange requests yet."),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildExchangeCard(Map<String, dynamic> e, bool isIncoming) {
//     final status = e['status'] ?? 'unknown';
//     final item = e['item'];
//     final proposer = e['proposer'];
//     final itemTitle = item?['title'] ?? 'Unknown Item';
//     final itemImage = item?['image_url'];
//     final proposerName = proposer?['display_name'] ?? 'Unknown User';
//     final proposerAvatar = proposer?['avatar_url'];

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage:
//               proposerAvatar != null ? NetworkImage(proposerAvatar) : null,
//           child: proposerAvatar == null ? const Icon(Icons.person) : null,
//         ),
//         title: Text(
//           isIncoming
//               ? "$proposerName offered an exchange"
//               : "You proposed to exchange with ${itemTitle}",
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text("Status: $status"),
//         trailing: isIncoming
//             ? _buildIncomingButtons(e)
//             : _buildOutgoingButtons(e),
//       ),
//     );
//   }

//   Widget _buildIncomingButtons(Map<String, dynamic> e) {
//     final status = e['status'];
//     if (status == 'accepted') {
//       return IconButton(
//         icon: const Icon(Icons.check_circle, color: Colors.green),
//         onPressed: () => _complete(e['id']),
//         tooltip: 'Mark Completed',
//       );
//     }
//     if (status == 'completed') {
//       return const Icon(Icons.done_all, color: Colors.grey);
//     }
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.check, color: Colors.green),
//           onPressed: () => _accept(e['id']),
//         ),
//         IconButton(
//           icon: const Icon(Icons.close, color: Colors.red),
//           onPressed: () => _reject(e['id']),
//         ),
//       ],
//     );
//   }

//   Widget _buildOutgoingButtons(Map<String, dynamic> e) {
//     final status = e['status'];
//     if (status == 'completed') {
//       return const Icon(Icons.done_all, color: Colors.grey);
//     }
//     return Text(status.toString(),
//         style: const TextStyle(color: Colors.grey, fontSize: 12));
//   }
// }
import 'package:flutter/material.dart';
import '../../services/exchange_service.dart';
import '../../utils/app_theme.dart';
import '../../models/exchange_model.dart';
import 'exchange_status_screen.dart';

class ExchangeRequestsScreen extends StatefulWidget {
  const ExchangeRequestsScreen({super.key});

  @override
  State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
}

class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen> {
  bool loading = true;
  List<Map<String, dynamic>> incoming = [];
  List<Map<String, dynamic>> outgoing = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final inReq = await ExchangeService.fetchIncomingProposals();
      final outReq = await ExchangeService.fetchMyProposals();
      setState(() {
        incoming = inReq;
        outgoing = outReq;
      });
    } catch (e) {
      debugPrint("❌ Error loading exchange data: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _accept(String id) async {
    await ExchangeService.acceptProposal(id);
    _loadData();
  }

  Future<void> _reject(String id) async {
    await ExchangeService.rejectProposal(id);
    _loadData();
  }

  Future<void> _complete(String id) async {
    await ExchangeService.markCompleted(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Requests'),
        backgroundColor: kGreen,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  if (incoming.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: Text('📥 Incoming Proposals',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ...incoming.map((ex) => _buildExchangeCard(ex, true)),
                  if (outgoing.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: Text('📤 Sent Proposals',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ...outgoing.map((ex) => _buildExchangeCard(ex, false)),
                  if (incoming.isEmpty && outgoing.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text("No exchange requests yet."),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildExchangeCard(Map<String, dynamic> e, bool isIncoming) {
    final status = e['status'] ?? 'unknown';
    final item = e['item'];
    final proposer = e['proposer'];
    final itemTitle = item?['title'] ?? 'Unknown Item';
    final itemImage = item?['image_url'];
    final proposerName = proposer?['display_name'] ?? 'Unknown User';
    final proposerAvatar = proposer?['avatar_url'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              proposerAvatar != null ? NetworkImage(proposerAvatar) : null,
          child: proposerAvatar == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          isIncoming
              ? "$proposerName offered an exchange"
              : "You proposed to exchange with $itemTitle",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text("Status: $status"),
        trailing: isIncoming
            ? _buildIncomingButtons(e)
            : _buildOutgoingButtons(e),

        /// 👇 New: open status screen when tapped
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExchangeStatusScreen(
                exchange: Exchange.fromMap(e),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncomingButtons(Map<String, dynamic> e) {
    final status = e['status'];
    if (status == 'accepted') {
      return IconButton(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        onPressed: () => _complete(e['id']),
        tooltip: 'Mark Completed',
      );
    }
    if (status == 'completed') {
      return const Icon(Icons.done_all, color: Colors.grey);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => _accept(e['id']),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _reject(e['id']),
        ),
      ],
    );
  }

  Widget _buildOutgoingButtons(Map<String, dynamic> e) {
    final status = e['status'];
    if (status == 'completed') {
      return const Icon(Icons.done_all, color: Colors.grey);
    }
    return Text(status.toString(),
        style: const TextStyle(color: Colors.grey, fontSize: 12));
  }
}
