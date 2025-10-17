// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../widgets/bottom_nav_bar.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen>
//     with SingleTickerProviderStateMixin {
//   final supabase = Supabase.instance.client;
//   late TabController _tabController;
//   final TextEditingController searchController = TextEditingController();
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   Future<List<dynamic>> _searchItems() async {
//     if (searchQuery.isEmpty) return [];
//     final response = await supabase
//         .from('items')
//         .select()
//         .ilike('title', '%$searchQuery%');
//     return response;
//   }

//   Future<List<dynamic>> _searchUsers() async {
//     if (searchQuery.isEmpty) return [];
//     final response = await supabase
//         .from('profiles')
//         .select()
//         .ilike('name', '%$searchQuery%');
//     return response;
//   }

//   Future<List<dynamic>> _searchExchanges() async {
//     if (searchQuery.isEmpty) return [];
//     final response = await supabase
//         .from('exchanges')
//         .select()
//         .ilike('status', '%$searchQuery%');
//     return response;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
    
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: kGreen,
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Items'),
//             Tab(text: 'Users'),
//             Tab(text: 'Exchanges'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items, users, or exchanges...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (val) => setState(() => searchQuery = val),
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildItemsTab(),
//                 _buildUsersTab(),
//                 _buildExchangesTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
       
//     );
//   }

//   Widget _buildItemsTab() {
//     return FutureBuilder<List<dynamic>>(
//       future: _searchItems(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
//         final items = snapshot.data!;
//         if (items.isEmpty) {
//           return const Center(child: Text('No items found.'));
//         }
//         return ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: kTeal.withOpacity(0.2),
//                   child: const Icon(Icons.inventory_2, color: kTeal),
//                 ),
//                 title: Text(item['title'] ?? 'Untitled'),
//                 subtitle: Text(item['description'] ?? ''),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildUsersTab() {
//     return FutureBuilder<List<dynamic>>(
//       future: _searchUsers(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
//         final users = snapshot.data!;
//         if (users.isEmpty) {
//           return const Center(child: Text('No users found.'));
//         }
//         return ListView.builder(
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             final user = users[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: kGreen.withOpacity(0.2),
//                   child: const Icon(Icons.person, color: kGreen),
//                 ),
//                 title: Text(user['name'] ?? 'Unknown'),
//                 subtitle: Text(user['email'] ?? ''),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildExchangesTab() {
//     return FutureBuilder<List<dynamic>>(
//       future: _searchExchanges(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
//         final exchanges = snapshot.data!;
//         if (exchanges.isEmpty) {
//           return const Center(child: Text('No exchanges found.'));
//         }
//         return ListView.builder(
//           itemCount: exchanges.length,
//           itemBuilder: (context, index) {
//             final exchange = exchanges[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: kAmber.withOpacity(0.2),
//                   child: const Icon(Icons.swap_horiz, color: kAmber),
//                 ),
//                 title: Text('Exchange #${exchange['id']}'),
//                 subtitle: Text('Status: ${exchange['status'] ?? 'N/A'}'),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../home/home_feed_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../profile/profile_overview_screen.dart';
// import '../home/offer_item_screen.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen>
//     with SingleTickerProviderStateMixin {
//   final supabase = Supabase.instance.client;
//   late TabController _tabController;
//   final TextEditingController searchController = TextEditingController();
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   Future<List<dynamic>> _searchItems() async {
//     if (searchQuery.isEmpty) return [];
//     final response = await supabase
//         .from('items')
//         .select()
//         .ilike('title', '%$searchQuery%');
//     return response;
//   }

//   Future<List<dynamic>> _searchUsers() async {
//     if (searchQuery.isEmpty) return [];
//     final response = await supabase
//         .from('profiles')
//         .select()
//         .ilike('name', '%$searchQuery%');
//     return response;
//   }

//   Future<List<dynamic>> _searchExchanges() async {
//     if (searchQuery.isEmpty) return [];
//     final response = await supabase
//         .from('exchanges')
//         .select()
//         .ilike('status', '%$searchQuery%');
//     return response;
//   }

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeFeedScreen()),
//         );
//         break;
//       case 1:
//         // Already on SearchScreen
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ChatListScreen()),
//         );
//         break;
//       case 4:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//         );
//         break;
//     }
//   }

//   void _handleFabPressed() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const OfferItemScreen()),
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
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Items'),
//             Tab(text: 'Users'),
//             Tab(text: 'Exchanges'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items, users, or exchanges...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (val) => setState(() => searchQuery = val),
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildItemsTab(),
//                 _buildUsersTab(),
//                 _buildExchangesTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // ✅ Fixed BottomNavBar
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 1, // Search tab index
//         onTap: _handleNavTap,
//         onFabPressed: _handleFabPressed,
//       ),
//     );
//   }

//   Widget _buildItemsTab() {
//     return FutureBuilder<List<dynamic>>(
//       future: _searchItems(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
//         final items = snapshot.data!;
//         if (items.isEmpty) return const Center(child: Text('No items found.'));
//         return ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: kTeal.withOpacity(0.2),
//                   child: const Icon(Icons.inventory_2, color: kTeal),
//                 ),
//                 title: Text(item['title'] ?? 'Untitled'),
//                 subtitle: Text(item['description'] ?? ''),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildUsersTab() {
//     return FutureBuilder<List<dynamic>>(
//       future: _searchUsers(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
//         final users = snapshot.data!;
//         if (users.isEmpty) return const Center(child: Text('No users found.'));
//         return ListView.builder(
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             final user = users[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: kGreen.withOpacity(0.2),
//                   child: const Icon(Icons.person, color: kGreen),
//                 ),
//                 title: Text(user['name'] ?? 'Unknown'),
//                 subtitle: Text(user['email'] ?? ''),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildExchangesTab() {
//     return FutureBuilder<List<dynamic>>(
//       future: _searchExchanges(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
//         final exchanges = snapshot.data!;
//         if (exchanges.isEmpty) return const Center(child: Text('No exchanges found.'));
//         return ListView.builder(
//           itemCount: exchanges.length,
//           itemBuilder: (context, index) {
//             final exchange = exchanges[index];
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: kAmber.withOpacity(0.2),
//                   child: const Icon(Icons.swap_horiz, color: kAmber),
//                 ),
//                 title: Text('Exchange #${exchange['id']}'),
//                 subtitle: Text('Status: ${exchange['status'] ?? 'N/A'}'),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../home/home_feed_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../profile/profile_overview_screen.dart';
// import '../item_detail/item_detail_screen.dart'; // import your item detail screen

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final supabase = Supabase.instance.client;
//   final TextEditingController searchController = TextEditingController();

//   List<dynamic> allItems = [];
//   List<dynamic> displayedItems = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadAllItems();
//   }

//   Future<void> _loadAllItems() async {
//     setState(() => loading = true);
//     try {
//       final response = await supabase.from('items').select();
//       setState(() {
//         allItems = response;
//         displayedItems = allItems; // initially show all items
//         loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading items: $e');
//       setState(() => loading = false);
//     }
//   }

//   void _searchItems(String query) {
//     if (query.isEmpty) {
//       setState(() => displayedItems = allItems);
//     } else {
//       setState(() {
//         displayedItems = allItems
//             .where((item) =>
//                 (item['title'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     }
//   }

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeFeedScreen()),
//         );
//         break;
//       case 1:
//         break; // already on SearchScreen
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ChatListScreen()),
//         );
//         break;
//       case 4:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfileOverviewScreen()),
//         );
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: (val) => _searchItems(val),
//             ),
//           ),
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : displayedItems.isEmpty
//                     ? const Center(child: Text('No items found.'))
//                     : ListView.builder(
//                         itemCount: displayedItems.length,
//                         itemBuilder: (context, index) {
//                           final item = displayedItems[index];
//                           return Card(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 6),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 10, horizontal: 16),
//                               leading: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: item['image_url'] != null &&
//                                         item['image_url'].isNotEmpty
//                                     ? Image.network(
//                                         item['image_url'],
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
//                               title: Text(item['title'] ?? 'Untitled'),
//                               subtitle: Text(item['description'] ?? ''),
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
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 1, // search tab
//         onTap: _handleNavTap,
//         onFabPressed: () {},
//       ),
//     );
//   }
// }
// import 'package:circlo_app/models/item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../home/home_feed_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../profile/profile_overview_screen.dart';
// import '../item_detail/item_detail_screen.dart'; // your item detail screen

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

//   @override
//   void initState() {
//     super.initState();
//     _loadAllItems();
//   }

//   Future<void> _loadAllItems() async {
//     setState(() => loading = true);
//     try {
//       final response = await supabase.from('items').select();
//       final List<Map<String, dynamic>> itemMaps =
//           List<Map<String, dynamic>>.from(response);

//       setState(() {
//         allItems = itemMaps.map((m) => Item.fromMap(m)).toList();
//         displayedItems = allItems; // show all items initially
//         loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading items: $e');
//       setState(() => loading = false);
//     }
//   }

//   void _searchItems(String query) {
//     if (query.isEmpty) {
//       setState(() => displayedItems = allItems);
//     } else {
//       setState(() {
//         displayedItems = allItems
//             .where((item) =>
//                 item.title.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     }
//   }

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => const HomeFeedScreen()));
//         break;
//       case 1:
//         break; // already on SearchScreen
//       case 3:
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
//         break;
//       case 4:
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => const ProfileOverviewScreen()));
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: _searchItems,
//             ),
//           ),
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : displayedItems.isEmpty
//                     ? const Center(child: Text('No items found.'))
//                     : ListView.builder(
//                         itemCount: displayedItems.length,
//                         itemBuilder: (context, index) {
//                           final item = displayedItems[index];
//                           return Card(
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
//                               title: Text(item.title),
//                               subtitle: Text(item.description ?? ''),
//                               onTap: () {
//                                 // ✅ Pass proper Item object
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
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 1, // search tab
//         onTap: _handleNavTap,
//         onFabPressed: () {},
//       ),
//     );
//   }
// }
// import 'package:circlo_app/models/item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../home/home_feed_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../profile/profile_overview_screen.dart';
// import '../item_detail/item_detail_screen.dart'; // your item detail screen

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

//   @override
//   void initState() {
//     super.initState();
//     _loadAllItems();
//   }

//   Future<void> _loadAllItems() async {
//     setState(() => loading = true);
//     try {
//       final response = await supabase.from('items').select();
//       final List<Map<String, dynamic>> itemMaps =
//           List<Map<String, dynamic>>.from(response);

//       setState(() {
//         allItems = itemMaps.map((m) => Item.fromMap(m)).toList();
//         displayedItems = allItems; // show all items initially
//         loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading items: $e');
//       setState(() => loading = false);
//     }
//   }

//   void _searchItems(String query) {
//     if (query.isEmpty) {
//       setState(() => displayedItems = allItems);
//     } else {
//       setState(() {
//         displayedItems = allItems
//             .where((item) =>
//                 item.title.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     }
//   }

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => const HomeFeedScreen()));
//         break;
//       case 1:
//         break; // already on SearchScreen
//       case 3:
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
//         break;
//       case 4:
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => const ProfileOverviewScreen()));
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: _searchItems,
//             ),
//           ),
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : displayedItems.isEmpty
//                     ? const Center(child: Text('No items found.'))
//                     : ListView.builder(
//                         itemCount: displayedItems.length,
//                         itemBuilder: (context, index) {
//                           final item = displayedItems[index];
//                           return Card(
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
//                               title: Text(item.title),
//                               subtitle: Text(item.description ?? ''),
//                               onTap: () {
//                                 // ✅ Pass proper Item object
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
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 1, // search tab
//         onTap: _handleNavTap,
//         onFabPressed: () {},
//       ),
//     );
//   }
// }
// import 'package:circlo_app/models/item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../home/home_feed_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../profile/profile_overview_screen.dart';
// import '../item_detail/item_detail_screen.dart';

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

//   @override
//   void initState() {
//     super.initState();
//     _loadAllItems();
//   }

//   Future<void> _loadAllItems() async {
//     setState(() => loading = true);
//     try {
//       final response = await supabase.from('items').select();
//       final List<Map<String, dynamic>> itemMaps =
//           List<Map<String, dynamic>>.from(response);

//       setState(() {
//         allItems = itemMaps.map((m) => Item.fromMap(m)).toList();
//         displayedItems = allItems; // show all items initially
//         loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error loading items: $e');
//       setState(() => loading = false);
//     }
//   }

//   void _searchItems(String query) {
//     if (query.isEmpty) {
//       setState(() => displayedItems = allItems);
//     } else {
//       setState(() {
//         displayedItems = allItems
//             .where((item) =>
//                 item.title.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       });
//     }
//   }

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => const HomeFeedScreen()));
//         break;
//       case 1:
//         break; // already on SearchScreen
//       case 3:
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
//         break;
//       case 4:
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => const ProfileOverviewScreen()));
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: kGreen,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search, color: kGreen),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onChanged: _searchItems,
//             ),
//           ),
//           Expanded(
//             child: loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : displayedItems.isEmpty
//                     ? const Center(child: Text('No items found.'))
//                     : ListView.builder(
//                         itemCount: displayedItems.length,
//                         itemBuilder: (context, index) {
//                           final item = displayedItems[index];
//                           return Card(
//                             color: Colors.white, // ✅ White background
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
//                               title: Text(item.title),
//                               subtitle: Text(item.description ?? ''),
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
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 1, // search tab
//         onTap: _handleNavTap,
//         onFabPressed: () {},
//       ),
//     );
//   }
// }
import 'package:circlo_app/models/item_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../item_detail/item_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  /// 🔹 Load all items from Supabase
  Future<void> _loadAllItems() async {
    setState(() => loading = true);
    try {
      final response = await supabase.from('items').select();
      final List<Map<String, dynamic>> itemMaps =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        allItems = itemMaps.map((m) => Item.fromMap(m)).toList();
        displayedItems = allItems;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading items: $e');
      setState(() => loading = false);
    }
  }

  /// 🔹 Search by item title
  void _searchItems(String query) {
    if (query.isEmpty) {
      setState(() => displayedItems = allItems);
    } else {
      setState(() {
        displayedItems = allItems
            .where((item) =>
                item.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: kGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// 🔍 Search Bar
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

          /// 🔹 Search Results
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : displayedItems.isEmpty
                    ? const Center(child: Text('No items found.'))
                    : ListView.builder(
                        itemCount: displayedItems.length,
                        itemBuilder: (context, index) {
                          final item = displayedItems[index];
                          return Card(
                            color: Colors.white,
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
