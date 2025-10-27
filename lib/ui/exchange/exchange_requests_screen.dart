
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
        elevation: 0,
        centerTitle: true,
        backgroundColor: kGreen,
        surfaceTintColor: kGreen,
        foregroundColor: Colors.white,
        title: Text(
          'Exchange Requests',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Incoming Proposals'),
              Tab(text: 'Sent Proposals'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            indicator: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    color: kGreen, strokeWidth: 2.6),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  color: kGreen,
                  backgroundColor: Colors.white,
                  onRefresh: _loadData,
                  child: _buildProposalsList(incoming, true),
                ),
                RefreshIndicator(
                  color: kGreen,
                  backgroundColor: Colors.white,
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
        physics:
            const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: [
          const SizedBox(height: 96),
          Icon(Icons.swap_horiz_rounded,
              size: 64, color: kTextDark.withOpacity(0.18)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'No exchange requests yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Pull to refresh or check back later.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: itemImage != null
              ? Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: kTeal.withOpacity(0.5), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      itemImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 26,
                  backgroundColor: kGreen.withOpacity(0.12),
                  child: const Icon(Icons.image, color: kGreen),
                ),
          title: Text(
            isIncoming
                ? "$proposerName offered an exchange"
                : "You proposed to exchange with $itemTitle",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: kTextDark,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "Status: $status",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          trailing: isIncoming
              ? _buildIncomingButtons(e)
              : _buildOutgoingButtons(e),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ExchangeStatusScreen(exchange: Exchange.fromMap(e)),
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
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: kGreen,
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
        ),
      );
    }
    if (status == 'completed') {
      return const Icon(Icons.done_all_rounded, color: Colors.grey);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _accept(e['id']),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration:
                const BoxDecoration(color: kGreen, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _reject(e['id']),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.redAccent, shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded,
                color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildOutgoingButtons(Map<String, dynamic> e) {
    final status = e['status'];
    Color bgColor =
        status == 'completed' ? Colors.grey.shade300 : kTeal.withOpacity(0.16);
    Color textColor =
        status == 'completed' ? Colors.grey : kTeal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        border: Border.all(color: textColor.withOpacity(0.25)),
      ),
      child: Text(
        status.toString(),
        style: TextStyle(
            color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
