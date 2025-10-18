
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import '../../services/exchange_service.dart';
// import '../../utils/app_theme.dart';
// import '../../models/exchange_model.dart';
// import 'exchange_status_screen.dart';

// class ExchangeRequestsScreen extends StatefulWidget {
//   const ExchangeRequestsScreen({super.key});

//   @override
//   State<ExchangeRequestsScreen> createState() =>
//       _ExchangeRequestsScreenState();
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

//   Future<void> _deleteExchange(String id) async {
//     try {
//       await ExchangeService.deleteExchange(id);
//       _showSnack('Exchange deleted successfully');
//       _loadData();
//     } catch (e) {
//       _showSnack('Failed to delete: $e');
//     }
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
//                       child: Text(
//                         '📥 Incoming Proposals',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                     ),
//                   ...incoming.map((ex) => _buildSlidableExchangeCard(ex, true)),

//                   if (outgoing.isNotEmpty)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 20, bottom: 5),
//                       child: Text(
//                         '📤 Sent Proposals',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                     ),
//                   ...outgoing.map((ex) => _buildSlidableExchangeCard(ex, false)),

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

//   Widget _buildSlidableExchangeCard(Map<String, dynamic> e, bool isIncoming) {
//     final status = e['status'] ?? 'unknown';
//     final item = e['item'];
//     final proposer = e['proposer'];
//     final itemTitle = item?['title'] ?? 'Unknown Item';
//     final itemImage = item?['image_url'];
//     final proposerName = proposer?['display_name'] ?? 'Unknown User';
//     final proposerAvatar = proposer?['avatar_url'];

//     return Slidable(
//       key: ValueKey(e['id']),
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         extentRatio: 0.25,
//         children: [
//           SlidableAction(
//             onPressed: (_) => _deleteExchange(e['id']),
//             backgroundColor: Colors.red,
//             icon: Icons.delete,
//             label: 'Delete',
//           ),
//         ],
//       ),
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundImage:
//                 proposerAvatar != null ? NetworkImage(proposerAvatar) : null,
//             child: proposerAvatar == null
//                 ? const Icon(Icons.person)
//                 : null,
//           ),
//           title: Text(
//             isIncoming
//                 ? "$proposerName offered an exchange"
//                 : "You proposed to exchange with $itemTitle",
//             style: const TextStyle(fontWeight: FontWeight.w500),
//           ),
//           subtitle: Text("Status: $status"),
//           trailing: isIncoming
//               ? _buildIncomingButtons(e)
//               : _buildOutgoingButtons(e),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ExchangeStatusScreen(
//                   exchange: Exchange.fromMap(e),
//                 ),
//               ),
//             );
//           },
//         ),
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
//     return Text(
//       status.toString(),
//       style: const TextStyle(color: Colors.grey, fontSize: 12),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../services/exchange_service.dart';
import '../../utils/app_theme.dart';
import '../../models/exchange_model.dart';
import 'exchange_status_screen.dart';

class ExchangeRequestsScreen extends StatefulWidget {
  const ExchangeRequestsScreen({super.key});

  @override
  State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
}

class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen>
    with SingleTickerProviderStateMixin {
  bool loading = true;
  List<Map<String, dynamic>> incoming = [];
  List<Map<String, dynamic>> outgoing = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _deleteExchange(String id) async {
    try {
      await ExchangeService.deleteExchange(id);
      _showSnack('Exchange deleted successfully');
      _loadData();
    } catch (e) {
      _showSnack('Failed to delete: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Requests'),
        backgroundColor: kGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Incoming Proposals'),
            Tab(text: 'Sent Proposals'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                /// 🟢 Incoming Proposals Tab
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildProposalsList(incoming, true),
                ),

                /// 🟣 Sent Proposals Tab
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildProposalsList(outgoing, false),
                ),
              ],
            ),
    );
  }

  Widget _buildProposalsList(List<Map<String, dynamic>> list, bool isIncoming) {
    if (list.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: Text("No exchange requests yet.")),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final e = list[index];
        return _buildSlidableExchangeCard(e, isIncoming);
      },
    );
  }

  Widget _buildSlidableExchangeCard(Map<String, dynamic> e, bool isIncoming) {
    final status = e['status'] ?? 'unknown';
    final item = e['item'];
    final proposer = e['proposer'];
    final itemTitle = item?['title'] ?? 'Unknown Item';
    final itemImage = item?['image_url'];
    final proposerName = proposer?['display_name'] ?? 'Unknown User';
    final proposerAvatar = proposer?['avatar_url'];

    return Slidable(
      key: ValueKey(e['id']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _deleteExchange(e['id']),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: itemImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    itemImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
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
    return Text(
      status.toString(),
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }
}