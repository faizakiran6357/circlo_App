
// import 'package:circlo_app/models/item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../item_detail/item_detail_screen.dart';
// import '../home/filter_bottom_sheet.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final supabase = Supabase.instance.client;
//   final TextEditingController searchController = TextEditingController();

//   List<Item> allItems = [];
//   List<Item> displayedItems = [];
//   bool loading = true;
//   bool loadingMore = false;
//   bool hasMore = true;
//   int currentPage = 1;
//   final int limit = 7;
//   Map<String, dynamic> appliedFilters = {};

//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _loadItems(reset: true);
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         hasMore &&
//         !loadingMore &&
//         !loading) {
//       _loadItems();
//     }
//   }

//   /// 🔹 Load items from Supabase with pagination
//   Future<void> _loadItems({bool reset = false}) async {
//     if (reset) {
//       setState(() {
//         loading = true;
//         currentPage = 1;
//         hasMore = true;
//         allItems = [];
//       });
//     } else {
//       setState(() => loadingMore = true);
//     }

//     try {
//       final from = (currentPage - 1) * limit;
//       final to = from + limit - 1;

//       final response = await supabase
//           .from('items')
//           .select()
//           .range(from, to)
//           .order('created_at', ascending: false);

//       final List<Map<String, dynamic>> itemMaps =
//           List<Map<String, dynamic>>.from(response);

//       final newItems = itemMaps.map((m) => Item.fromMap(m)).toList();

//       setState(() {
//         allItems.addAll(newItems);
//         displayedItems = _applySearchFilter(searchController.text, allItems);
//         hasMore = newItems.length == limit;
//         currentPage++;
//         loading = false;
//         loadingMore = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading items: $e');
//       setState(() {
//         loading = false;
//         loadingMore = false;
//       });
//     }
//   }

//   List<Item> _applySearchFilter(String query, List<Item> items) {
//     if (query.isEmpty) return items;
//     return items
//         .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//   }

//   /// 🔹 Search handler
//   void _searchItems(String query) {
//     setState(() {
//       displayedItems = _applySearchFilter(query, allItems);
//     });
//   }

//   /// 🔹 Open Filter Bottom Sheet
//   void _openFilters() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => FilterBottomSheet(
//         initialFilters: appliedFilters,
//         onApply: (filters) {
//           Navigator.pop(context);
//           setState(() {
//             appliedFilters = filters;
//             _loadItems(reset: true); // reload items with filters applied
//           });
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: kGreen,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
//             onPressed: _openFilters,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           /// 🔍 Search Bar
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               onChanged: _searchItems,
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),

//           /// 🔹 Search Results
//           Expanded(
//             child: loading && allItems.isEmpty
//                 ? const Center(child: CircularProgressIndicator())
//                 : displayedItems.isEmpty
//                     ? const Center(child: Text('No items found.'))
//                     : ListView.builder(
//                         controller: _scrollController,
//                         itemCount: displayedItems.length + (loadingMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (index >= displayedItems.length) {
//                             return const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 20),
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           }

//                           final item = displayedItems[index];
//                           return Card(
//                             color: Colors.white,
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 6),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 10, horizontal: 16),
//                               leading: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: item.imageUrl != null &&
//                                         item.imageUrl!.isNotEmpty
//                                     ? Image.network(
//                                         item.imageUrl!,
//                                         width: 60,
//                                         height: 60,
//                                         fit: BoxFit.cover,
//                                       )
//                                     : Container(
//                                         width: 60,
//                                         height: 60,
//                                         color: Colors.grey[300],
//                                         child: const Icon(Icons.image,
//                                             color: Colors.white),
//                                       ),
//                               ),
//                               title: Text(
//                                 item.title,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w600),
//                               ),
//                               subtitle: Text(
//                                 item.description ?? '',
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) =>
//                                         ItemDetailScreen(item: item),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }pkaaaaaaaaaaaaaaaaaaaaaaa

import 'package:circlo_app/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../item_detail/item_detail_screen.dart';
import '../home/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();

  List<Item> allItems = [];
  List<Item> displayedItems = [];
  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 7;
  Map<String, dynamic> appliedFilters = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadItems(reset: true);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        hasMore &&
        !loadingMore &&
        !loading) {
      _loadItems();
    }
  }

  Future<void> _loadItems({bool reset = false}) async {
    if (reset) {
      setState(() {
        loading = true;
        currentPage = 1;
        hasMore = true;
        allItems = [];
      });
    } else {
      setState(() => loadingMore = true);
    }

    try {
      final from = (currentPage - 1) * limit;
      final to = from + limit - 1;

      final response = await supabase
          .from('items')
          .select()
          .range(from, to)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> itemMaps =
          List<Map<String, dynamic>>.from(response);

      final newItems = itemMaps.map((m) => Item.fromMap(m)).toList();

      setState(() {
        allItems.addAll(newItems);
        displayedItems = _applySearchFilter(searchController.text, allItems);
        hasMore = newItems.length == limit;
        currentPage++;
        loading = false;
        loadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading items: $e');
      setState(() {
        loading = false;
        loadingMore = false;
      });
    }
  }

  List<Item> _applySearchFilter(String query, List<Item> items) {
    if (query.isEmpty) return items;
    return items
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _searchItems(String query) {
    setState(() {
      displayedItems = _applySearchFilter(query, allItems);
    });
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterBottomSheet(
        initialFilters: appliedFilters,
        onApply: (filters) {
          Navigator.pop(context);
          setState(() {
            appliedFilters = filters;
            _loadItems(reset: true);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: kGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: _searchItems,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search, color: kGreen),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔹 Search Results
          Expanded(
            child: loading && allItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : displayedItems.isEmpty
                    ? const Center(child: Text('No items found.'))
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: displayedItems.length + (loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= displayedItems.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final item = displayedItems[index];
                          return Card(
                            color: Colors.white, // ✅ Card color changed to white
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image,
                                            color: Colors.white),
                                      ),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                item.description ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItemDetailScreen(item: item),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
