// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../services/exchange_service.dart';
// import '../../services/supabase_item_service.dart';
// import '../../models/item_model.dart';
// import '../../utils/app_theme.dart';

// class ProposeExchangeScreen extends StatefulWidget {
//   final String targetItemId;
//   const ProposeExchangeScreen({super.key, required this.targetItemId});

//   @override
//   State<ProposeExchangeScreen> createState() => _ProposeExchangeScreenState();
// }

// class _ProposeExchangeScreenState extends State<ProposeExchangeScreen> {
//   List<Item> myItems = [];
//   final selectedIds = <String>{};
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadMyItems();
//   }

//   Future<void> _loadMyItems() async {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) return;

//     final res = await SupabaseItemService.fetchAllItems();
//     setState(() {
//       myItems = res.where((i) => i.userId == user.id).toList();
//       loading = false;
//     });
//   }

//   Future<void> _submit() async {
//     if (selectedIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Select at least one item')),
//       );
//       return;
//     }

//     await ExchangeService.createExchangeProposal(
//       itemId: widget.targetItemId,
//       offeredItemIds: selectedIds.toList(),
//     );

//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Exchange proposal sent!')),
//     );
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Propose Exchange'),
//         backgroundColor: kGreen,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : myItems.isEmpty
//               ? const Center(child: Text('You have no active items.'))
//               : Column(
//                   children: [
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: myItems.length,
//                         itemBuilder: (context, i) {
//                           final item = myItems[i];
//                           final selected = selectedIds.contains(item.id);
//                           return ListTile(
//                             leading: Image.network(
//                               item.imageUrl ?? '',
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                             ),
//                             title: Text(item.title),
//                             trailing: Checkbox(
//                               value: selected,
//                               onChanged: (v) {
//                                 setState(() {
//                                   if (v == true) {
//                                     selectedIds.add(item.id);
//                                   } else {
//                                     selectedIds.remove(item.id);
//                                   }
//                                 });
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           minimumSize: const Size(double.infinity, 48),
//                         ),
//                         onPressed: _submit,
//                         child: const Text('Send Proposal'),
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }
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
        elevation: 0,
        backgroundColor: kGreen,
        foregroundColor: kTextDark,
        centerTitle: true,
        title: const Text('Propose Exchange',style: TextStyle(color: Colors.white),),
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
            : myItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 72, color: kTeal),
                          SizedBox(height: 16),
                          Text(
                            'You have no active items.',
                            style: TextStyle(fontSize: 16, color: kTextDark),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kGreen, kTeal],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: const [
                              Icon(Icons.swap_horiz_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Select one or more items to offer',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.92,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: myItems.length,
                            itemBuilder: (context, i) {
                              final item = myItems[i];
                              final selected = selectedIds.contains(item.id);
                              return _ItemCard(
                                title: item.title,
                                imageUrl: item.imageUrl,
                                selected: selected,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      selectedIds.add(item.id);
                                    } else {
                                      selectedIds.remove(item.id);
                                    }
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      selectedIds.remove(item.id);
                                    } else {
                                      selectedIds.add(item.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        decoration: BoxDecoration(
                          color: kBg,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            )
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: _submit,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Send Proposal'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final bool selected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const _ItemCard({
    required this.title,
    required this.imageUrl,
    required this.selected,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? kGreen : Colors.transparent, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _ItemImage(url: imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Row(
                children: [
                  const Spacer(),
                  Transform.scale(
                    scale: 1.05,
                    child: Checkbox(
                      value: selected,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      activeColor: kGreen,
                      onChanged: onChanged,
                    ),
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

class _ItemImage extends StatelessWidget {
  final String? url;
  const _ItemImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final hasUrl = (url != null && url!.trim().isNotEmpty);
    if (!hasUrl) {
      return Container(
        color: const Color(0xFFF0F2F5),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.grey, size: 36),
        ),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF0F2F5),
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF0F2F5),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: kGreen),
            ),
          ),
        );
      },
    );
  }
}