// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/home/home_feed_screen.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:circlo_app/ui/home/search_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart' show BuildContext, Key, State, StatefulWidget, Widget;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class MainHomePage extends StatefulWidget {
//   const MainHomePage({ Key? key }) : super(key: key);

//   @override
//   _MainHomePageState createState() => _MainHomePageState();
// }

// class _MainHomePageState extends State<MainHomePage> {

//   final List screens = [
//     HomeFeedScreen(),
//     SearchScreen(),
//     OfferItemScreen(),
//     ChatListScreen(),
//     ProfileOverviewScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final screenIndex = context.watch<NavigtationProvider>().index;
//     return Scaffold(
//       bottomNavigationBar: BottomNavBar(),
//       body: screens[screenIndex],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:circlo_app/providers/navigtation_provider.dart';
// import 'package:circlo_app/ui/chat/chat_list_screen.dart';
// import 'package:circlo_app/ui/home/home_feed_screen.dart';
// import 'package:circlo_app/ui/home/offer_item_screen.dart';
// import 'package:circlo_app/ui/home/search_screen.dart';
// import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';

// class MainHomePage extends StatefulWidget {
//   const MainHomePage({Key? key}) : super(key: key);

//   @override
//   State<MainHomePage> createState() => _MainHomePageState();
// }

// class _MainHomePageState extends State<MainHomePage> {
//   final List<Widget> _screens = const [
//     HomeFeedScreen(),
//     SearchScreen(),
//     OfferItemScreen(),
//     ChatListScreen(),
//     ProfileOverviewScreen(),
//   ];

//   void _onItemTapped(int index) {
//     context.read<NavigtationProvider>().updateIndex(index);
//   }

//   void _onFabPressed() {
//     // ✅ When FAB pressed → go to Offer Item screen (index 2)
//     context.read<NavigtationProvider>().updateIndex(2);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenIndex = context.watch<NavigtationProvider>().index;
//     return Scaffold(
//       body: _screens[screenIndex],
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: screenIndex,
//         onTap: _onItemTapped,
//         onFabPressed: _onFabPressed,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circlo_app/providers/navigtation_provider.dart';
import 'package:circlo_app/ui/chat/chat_list_screen.dart';
import 'package:circlo_app/ui/home/home_feed_screen.dart';
import 'package:circlo_app/ui/home/offer_item_screen.dart';
import 'package:circlo_app/ui/home/search_screen.dart';
import 'package:circlo_app/ui/profile/profile_overview_screen.dart';
import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  /// ✅ Screens controlled by bottom navigation
  final List<Widget> _screens = const [
    HomeFeedScreen(),       // Home Feed (default)
    SearchScreen(),         // Search
    OfferItemScreen(),      // Add / Offer Item
    ChatListScreen(),       // Chats
    ProfileOverviewScreen() // Profile
  ];

  /// ✅ When user taps on a bottom icon
  void _onItemTapped(int index) {
    context.read<NavigtationProvider>().updateIndex(index);
  }

  /// ✅ When user taps on the floating + button
  void _onFabPressed() {
    context.read<NavigtationProvider>().updateIndex(2); // Offer Item
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigtationProvider>();
    final screenIndex = navProvider.index;

    return Scaffold(
      body: IndexedStack(
        /// Keeps all screens alive while switching
        index: screenIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: screenIndex,
        onTap: _onItemTapped,
        onFabPressed: _onFabPressed,
      ),
    );
  }
}
