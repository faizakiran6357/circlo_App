
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import '../../services/exchange_service.dart';
// import '../../utils/app_theme.dart';
// import '../../models/exchange_model.dart';
// import 'exchange_status_screen.dart';

// class ExchangeRequestsScreen extends StatefulWidget {
//   const ExchangeRequestsScreen({super.key});

//   @override
//   State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
// }

// class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen>
//     with SingleTickerProviderStateMixin {
//   bool loading = true;
//   List<Map<String, dynamic>> incoming = [];
//   List<Map<String, dynamic>> outgoing = [];

//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
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
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Incoming Proposals'),
//             Tab(text: 'Sent Proposals'),
//           ],
//         ),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 /// 🟢 Incoming Proposals Tab
//                 RefreshIndicator(
//                   onRefresh: _loadData,
//                   child: _buildProposalsList(incoming, true),
//                 ),

//                 /// 🟣 Sent Proposals Tab
//                 RefreshIndicator(
//                   onRefresh: _loadData,
//                   child: _buildProposalsList(outgoing, false),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildProposalsList(List<Map<String, dynamic>> list, bool isIncoming) {
//     if (list.isEmpty) {
//       return ListView(
//         children: const [
//           Padding(
//             padding: EdgeInsets.only(top: 80),
//             child: Center(child: Text("No exchange requests yet.")),
//           ),
//         ],
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: list.length,
//       itemBuilder: (context, index) {
//         final e = list[index];
//         return _buildSlidableExchangeCard(e, isIncoming);
//       },
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
//           leading: itemImage != null
//               ? ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     itemImage,
//                     width: 48,
//                     height: 48,
//                     fit: BoxFit.cover,
//                   ),
//                 )
//               : CircleAvatar(
//                   backgroundColor: Colors.grey.shade300,
//                   child: const Icon(Icons.image_not_supported),
//                 ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kGreen.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Exchange Requests', style: TextStyle(fontSize: 18)),
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
                RefreshIndicator(
                  onRefresh: _loadData,
                  child: _buildProposalsList(incoming, true),
                ),
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
        children: [
          const SizedBox(height: 80),
          Icon(Icons.swap_horiz, size: 64, color: kTextDark.withOpacity(0.25)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "No exchange requests yet.",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (ctx, index) => _buildExchangeCard(list[index], isIncoming),
    );
  }

    Widget _buildExchangeCard(Map<String, dynamic> e, bool isIncoming) {
  final status = e['status'] ?? 'unknown';
  final item = e['item'];
  final proposer = e['proposer'];
  final itemTitle = item?['title'] ?? 'Unknown Item';
  final itemImage = item?['image_url'];
  final proposerName = proposer?['display_name'] ?? 'Unknown User';

  return Slidable(
    key: ValueKey(e['id']),
    endActionPane: ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.2,
      children: [
        SlidableAction(
          onPressed: (_) => _deleteExchange(e['id']),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ],
    ),
    child: Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: itemImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(itemImage, width: 50, height: 50, fit: BoxFit.cover),
              )
            : CircleAvatar(
                backgroundColor: kGreen.withOpacity(0.2),
                child: const Icon(Icons.image, color: Colors.white),
              ),
        title: Text(
          isIncoming
              ? "$proposerName offered an exchange"
              : "You proposed to exchange with $itemTitle",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5, // 🔹 Reduced font size for a cleaner look
            color: kTextDark,
          ),
        ),
        subtitle: Text(
          "Status: $status",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        trailing: isIncoming ? _buildIncomingButtons(e) : _buildOutgoingButtons(e),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExchangeStatusScreen(exchange: Exchange.fromMap(e)),
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
      return GestureDetector(
        onTap: () => _complete(e['id']),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        ),
      );
    }
    if (status == 'completed') {
      return const Icon(Icons.done_all, color: Colors.grey);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _accept(e['id']),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: kGreen, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _reject(e['id']),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildOutgoingButtons(Map<String, dynamic> e) {
    final status = e['status'];
    Color bgColor = status == 'completed' ? Colors.grey.shade300 : kTeal.withOpacity(0.2);
    Color textColor = status == 'completed' ? Colors.grey : kTeal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor),
      child: Text(
        status.toString(),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
