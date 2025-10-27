
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../models/item_model.dart';
// import '../../services/supabase_item_service.dart';
// import '../../utils/app_theme.dart';
// import '../item_detail/item_detail_screen.dart';
// import '../home/offer_item_screen.dart';

// class ProfileItemsScreen extends StatefulWidget {
//   const ProfileItemsScreen({super.key});

//   @override
//   State<ProfileItemsScreen> createState() => _ProfileItemsScreenState();
// }

// class _ProfileItemsScreenState extends State<ProfileItemsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool loadingActive = true;
//   bool loadingArchived = true;

//   List<Item> activeItems = [];
//   List<Item> archivedItems = [];

//   final supabase = Supabase.instance.client;
//   final currentUserId = Supabase.instance.client.auth.currentUser?.id;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadActiveItems();
//     _loadArchivedItems();
//   }

//   Future<void> _loadActiveItems() async {
//     setState(() => loadingActive = true);
//     try {
//       final res = await supabase
//           .from('items')
//           .select()
//           .eq('user_id', currentUserId!)
//           .eq('status', 'active');
//       setState(() {
//         activeItems = (res as List).map((e) => Item.fromMap(e)).toList();
//         loadingActive = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Error loading active items: $e');
//       setState(() => loadingActive = false);
//     }
//   }

//   Future<void> _loadArchivedItems() async {
//     setState(() => loadingArchived = true);
//     try {
//       final res = await supabase
//           .from('items')
//           .select()
//           .eq('user_id', currentUserId!)
//           .eq('status', 'archived');
//       setState(() {
//         archivedItems = (res as List).map((e) => Item.fromMap(e)).toList();
//         loadingArchived = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Error loading archived items: $e');
//       setState(() => loadingArchived = false);
//     }
//   }

//   Future<void> _deleteItem(String id) async {
//     try {
//       await SupabaseItemService.deleteItem(id);
//       _showSnack('Item deleted successfully');
//       _refreshLists();
//     } catch (e) {
//       _showSnack('Failed to delete item: $e');
//     }
//   }

//   Future<void> _archiveItem(String id) async {
//     try {
//       await supabase.from('items').update({'status': 'archived'}).eq('id', id);
//       _showSnack('Item archived successfully');
//       _refreshLists();
//     } catch (e) {
//       _showSnack('Failed to archive item: $e');
//     }
//   }

//   Future<void> _unarchiveItem(String id) async {
//     try {
//       await supabase.from('items').update({'status': 'active'}).eq('id', id);
//       _showSnack('Item restored successfully');
//       _refreshLists();
//     } catch (e) {
//       _showSnack('Failed to unarchive item: $e');
//     }
//   }

//   void _refreshLists() {
//     _loadActiveItems();
//     _loadArchivedItems();
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Items'),
//         backgroundColor: kGreen,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Active'),
//             Tab(text: 'Archived'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildItemList(activeItems, loadingActive, isActiveTab: true),
//           _buildItemList(archivedItems, loadingArchived, isActiveTab: false),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemList(List<Item> items, bool loading,
//       {required bool isActiveTab}) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (items.isEmpty) {
//       return Center(
//         child:
//             Text(isActiveTab ? 'No active items yet.' : 'No archived items yet.'),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return Slidable(
//           key: ValueKey(item.id),
//           endActionPane: ActionPane(
//             motion: const DrawerMotion(),
//             children: [
//               SlidableAction(
//                 onPressed: (_) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => OfferItemScreen(itemToEdit: item),
//                     ),
//                   ).then((value) {
//                     if (value == true) _refreshLists();
//                   });
//                 },
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 icon: Icons.edit,
//                 label: 'Edit',
//               ),
//               SlidableAction(
//                 onPressed: (_) async {
//                   final confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (ctx) => AlertDialog(
//                       title: const Text('Delete Item'),
//                       content: const Text(
//                           'Are you sure you want to delete this item?'),
//                       actions: [
//                         TextButton(
//                             onPressed: () => Navigator.pop(ctx, false),
//                             child: const Text('Cancel')),
//                         TextButton(
//                             onPressed: () => Navigator.pop(ctx, true),
//                             child: const Text('Delete')),
//                       ],
//                     ),
//                   );
//                   if (confirm == true) _deleteItem(item.id);
//                 },
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 icon: Icons.delete,
//                 label: 'Delete',
//               ),
//             ],
//           ),
//           child: Card(
//             color: Colors.white, // ✅ WHITE CARD ADDED HERE
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 3,
//             child: ListTile(
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: item.imageUrl != null && item.imageUrl!.isNotEmpty
//                     ? Image.network(
//                         item.imageUrl!,
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                       )
//                     : Container(
//                         width: 60,
//                         height: 60,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.image, color: Colors.white),
//                       ),
//               ),
//               title: Text(
//                 item.title,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               subtitle: Text(
//                 item.description ?? 'No description',
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               trailing: IconButton(
//                 icon: Icon(
//                   isActiveTab ? Icons.archive : Icons.unarchive,
//                   color: Colors.grey[700],
//                 ),
//                 onPressed: () async {
//                   final confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (ctx) => AlertDialog(
//                       title:
//                           Text(isActiveTab ? 'Archive Item' : 'Unarchive Item'),
//                       content: Text(isActiveTab
//                           ? 'Move this item to archived?'
//                           : 'Restore this item to active list?'),
//                       actions: [
//                         TextButton(
//                             onPressed: () => Navigator.pop(ctx, false),
//                             child: const Text('Cancel')),
//                         TextButton(
//                           onPressed: () => Navigator.pop(ctx, true),
//                           child:
//                               Text(isActiveTab ? 'Archive' : 'Unarchive'),
//                         ),
//                       ],
//                     ),
//                   );
//                   if (confirm == true) {
//                     if (isActiveTab) {
//                       _archiveItem(item.id);
//                     } else {
//                       _unarchiveItem(item.id);
//                     }
//                   }
//                 },
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ItemDetailScreen(item: item),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/item_model.dart';
import '../../services/supabase_item_service.dart';
import '../../utils/app_theme.dart';
import '../item_detail/item_detail_screen.dart';
import '../home/offer_item_screen.dart';

class ProfileItemsScreen extends StatefulWidget {
  const ProfileItemsScreen({super.key});

  @override
  State<ProfileItemsScreen> createState() => _ProfileItemsScreenState();
}

class _ProfileItemsScreenState extends State<ProfileItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool loadingActive = true;
  bool loadingArchived = true;

  List<Item> activeItems = [];
  List<Item> archivedItems = [];

  final supabase = Supabase.instance.client;
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActiveItems();
    _loadArchivedItems();
  }

  Future<void> _loadActiveItems() async {
    setState(() => loadingActive = true);
    try {
      final res = await supabase
          .from('items')
          .select()
          .eq('user_id', currentUserId!)
          .eq('status', 'active');
      setState(() {
        activeItems = (res as List).map((e) => Item.fromMap(e)).toList();
        loadingActive = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading active items: $e');
      setState(() => loadingActive = false);
    }
  }

  Future<void> _loadArchivedItems() async {
    setState(() => loadingArchived = true);
    try {
      final res = await supabase
          .from('items')
          .select()
          .eq('user_id', currentUserId!)
          .eq('status', 'archived');
      setState(() {
        archivedItems = (res as List).map((e) => Item.fromMap(e)).toList();
        loadingArchived = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading archived items: $e');
      setState(() => loadingArchived = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      await SupabaseItemService.deleteItem(id);
      _showSnack('Item deleted successfully');
      _refreshLists();
    } catch (e) {
      _showSnack('Failed to delete item: $e');
    }
  }

  Future<void> _archiveItem(String id) async {
    try {
      await supabase.from('items').update({'status': 'archived'}).eq('id', id);
      _showSnack('Item archived successfully');
      _refreshLists();
    } catch (e) {
      _showSnack('Failed to archive item: $e');
    }
  }

  Future<void> _unarchiveItem(String id) async {
    try {
      await supabase.from('items').update({'status': 'active'}).eq('id', id);
      _showSnack('Item restored successfully');
      _refreshLists();
    } catch (e) {
      _showSnack('Failed to unarchive item: $e');
    }
  }

  void _refreshLists() {
    _loadActiveItems();
    _loadArchivedItems();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'My Items',
          style:
              Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Active'), Tab(text: 'Archived')],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemList(activeItems, loadingActive, isActiveTab: true),
          _buildItemList(archivedItems, loadingArchived, isActiveTab: false),
        ],
      ),
    );
  }

  Widget _buildItemList(List<Item> items, bool loading,
      {required bool isActiveTab}) {
    if (loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(color: kGreen, strokeWidth: 2.6),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActiveTab ? Icons.inbox_outlined : Icons.archive_outlined,
                color: kGreen,
                size: 34,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isActiveTab ? 'No active items yet' : 'No archived items yet',
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              isActiveTab
                  ? 'Post your item to get started.'
                  : 'Restore items from archive anytime.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: kTextDark.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Slidable(
          key: ValueKey(item.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfferItemScreen(itemToEdit: item),
                    ),
                  ).then((value) {
                    if (value == true) _refreshLists();
                  });
                },
                backgroundColor: kTeal,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Item'),
                      content: const Text(
                          'Are you sure you want to delete this item?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) _deleteItem(item.id);
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black.withOpacity(0.04)),
            ),
            elevation: 0,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
                      ),
              ),
              title: Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      height: 1.2,
                    ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.description ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: kTextDark.withOpacity(0.7)),
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: (isActiveTab ? kAmber : kTeal).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    isActiveTab ? Icons.archive_rounded : Icons.unarchive_rounded,
                    color: isActiveTab ? kAmber : kTeal,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title:
                            Text(isActiveTab ? 'Archive Item' : 'Unarchive Item'),
                        content: Text(isActiveTab
                            ? 'Move this item to archived?'
                            : 'Restore this item to active list?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(isActiveTab ? 'Archive' : 'Unarchive'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      if (isActiveTab) {
                        _archiveItem(item.id);
                      } else {
                        _unarchiveItem(item.id);
                      }
                    }
                  },
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailScreen(item: item),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}