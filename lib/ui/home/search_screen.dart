
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
        backgroundColor: kGreen,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
            onPressed: _openFilters,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container
                (
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _searchItems,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    prefixIcon: const Icon(Icons.search, color: kGreen),
                    suffixIcon: (searchController.text.isNotEmpty)
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFFBDBDBD)),
                            onPressed: () {
                              searchController.clear();
                              _searchItems('');
                            },
                            tooltip: 'Clear',
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Search Results
            Expanded(
              child: loading && allItems.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: kGreen),
                    )
                  : displayedItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No items found.',
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                          itemCount: displayedItems.length + (loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= displayedItems.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(color: kGreen),
                                ),
                              );
                            }

                            final item = displayedItems[index];
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.black12,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade100),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
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
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: kTextDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  item.description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: kGreen,
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
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
