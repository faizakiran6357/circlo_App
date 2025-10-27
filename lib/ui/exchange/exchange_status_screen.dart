
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

class _StatusPills extends StatelessWidget {
  final String current;
  const _StatusPills({required this.current});

  int get _index {
    switch (current) {
      case 'proposed':
        return 0;
      case 'accepted':
        return 1;
      case 'completed':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.campaign_outlined, 'Proposed'),
      (Icons.verified_outlined, 'Accepted'),
      (Icons.check_circle_outline, 'Completed'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == _index;
          Color bg;
          Color fg;
          if (i == 0) {
            bg = active ? kTeal.withOpacity(0.15) : Colors.transparent;
            fg = active ? kTeal : Colors.black54;
          } else if (i == 1) {
            bg = active ? kAmber.withOpacity(0.2) : Colors.transparent;
            fg = active ? kAmber : Colors.black54;
          } else {
            bg = active ? kGreen.withOpacity(0.15) : Colors.transparent;
            fg = active ? kGreen : Colors.black54;
          }
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i].$1, size: 18, color: fg),
                  const SizedBox(width: 6),
                  Text(items[i].$2, style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: kTextDark),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String current;
  const _StatusTimeline({required this.current});

  int get _currentIndex {
    switch (current) {
      case 'proposed':
        return 0;
      case 'accepted':
        return 1;
      case 'completed':
        return 2;
      default:
        return 0;
    }
  }

  Color _colorForStep(int step) {
    if (step == 0) return kTeal;
    if (step == 1) return kAmber;
    return kGreen;
  }

  @override
  Widget build(BuildContext context) {
    final labels = const ['Proposed', 'Accepted', 'Completed'];
    final activeIndex = _currentIndex;
    return Column(
      children: [
        Row(
          children: List.generate(3, (i) {
            final isActive = i <= activeIndex;
            final dotColor = isActive ? _colorForStep(i) : Colors.grey.shade300;
            final lineColor = (i < activeIndex) ? _colorForStep(i) : Colors.grey.shade300;
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i != 2)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: lineColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (i) {
            final isActive = i <= activeIndex;
            return Expanded(
              child: Align(
                alignment: i == 0
                    ? Alignment.centerLeft
                    : (i == 2 ? Alignment.centerRight : Alignment.center),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? _colorForStep(i) : Colors.black54,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CardImageWide extends StatelessWidget {
  final String? url;
  const _CardImageWide({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        height: 160,
        color: const Color(0xFFF0F2F5),
        child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 34)),
      );
    }
    return Image.network(
      url!,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 160,
          color: const Color(0xFFF0F2F5),
          child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 34)),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 160,
          color: const Color(0xFFF0F2F5),
          child: const Center(
            child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: kGreen)),
          ),
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  final String status;
  final bool isIncomingProposal;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCompleted;
  final VoidCallback onReview;

  const _ActionBar({
    required this.status,
    required this.isIncomingProposal,
    required this.onAccept,
    required this.onReject,
    required this.onCompleted,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    Widget? content;

    if (status == 'proposed' && isIncomingProposal) {
      content = Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onReject,
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onAccept,
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
            ),
          ),
        ],
      );
    } else if (status == 'accepted') {
      content = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAmber,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onCompleted,
        icon: const Icon(Icons.done_all),
        label: const Text('Mark as Completed'),
      );
    } else if (status == 'completed' && isIncomingProposal) {
      content = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: kTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onReview,
        icon: const Icon(Icons.rate_review),
        label: const Text('Leave a Review'),
      );
    }

    if (content == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: kBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: content,
    );
  }
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
        title: const Text('Exchange Details',style: TextStyle(color: Colors.white),),
        backgroundColor: kGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(color: kGreen, strokeWidth: 3),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.tag_outlined,
                          label: 'ID',
                          value: widget.exchange.id.substring(0, widget.exchange.id.length > 8 ? 8 : widget.exchange.id.length),
                        ),
                        _StatusChip(status: widget.exchange.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 24),

                    _StatusPills(current: widget.exchange.status),
                    const SizedBox(height: 16),

                    const _SectionHeader(title: 'Requested Item', icon: Icons.inventory_2_outlined, color: kGreen),
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

                    const _SectionHeader(title: 'Offered Items', icon: Icons.replay_rounded, color: kTeal),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE9EDF2)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.inbox_outlined, color: Colors.grey),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('No offered items found.', style: TextStyle(color: Colors.black54)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: widget.exchange.proposer?['avatar_url'] != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.exchange.proposer!['avatar_url']))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(widget.exchange.proposer?['display_name'] ?? 'Unknown User'),
                      subtitle: const Text('Proposal Owner'),
                    ),
                    const Divider(height: 30),

                    if (widget.exchange.status == 'proposed' && isIncomingProposal)
                      Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGreen,
                              foregroundColor: Colors.white,
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
                              foregroundColor: Colors.white,
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
                    else if (widget.exchange.status == 'accepted')
                      ElevatedButton.icon(
                        icon: const Icon(Icons.done_all),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAmber,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        onPressed: () async {
                          await provider.updateStatus(widget.exchange.id, 'completed');
                          if (context.mounted) Navigator.pop(context, true);
                        },
                        label: const Text('Mark as Completed'),
                      )
                    else if (widget.exchange.status == 'completed' && isIncomingProposal)
                      Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.rate_review),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kTeal,
                              foregroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    String? imageUrl,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _CardImage(url: imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kTextDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black87, height: 1.3),
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

class _SummaryCard extends StatelessWidget {
  final String idShort;
  final String status;
  final String proposerName;
  final String? proposerAvatar;

  const _SummaryCard({
    required this.idShort,
    required this.status,
    required this.proposerName,
    required this.proposerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: proposerAvatar != null ? NetworkImage(proposerAvatar!) : null,
            child: proposerAvatar == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proposerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kTextDark)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    _InfoChip(icon: Icons.tag_outlined, label: 'ID', value: idShort),
                    _StatusChip(status: status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EDF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kTeal),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: kTextDark)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case 'proposed':
        return kTeal;
      case 'accepted':
        return kAmber;
      case 'completed':
        return kGreen;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: _color),
          const SizedBox(width: 6),
          Text(status.toUpperCase(), style: TextStyle(color: _color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String? url;
  const _CardImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        width: 90,
        height: 90,
        color: const Color(0xFFF0F2F5),
        child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey, size: 30)),
      );
    }
    return Image.network(
      url!,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 90,
          height: 90,
          color: const Color(0xFFF0F2F5),
          child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30)),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 90,
          height: 90,
          color: const Color(0xFFF0F2F5),
          child: const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: kGreen)),
          ),
        );
      },
    );
  }
}
