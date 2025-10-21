
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../profile/profile_items_screen.dart';
// import '../profile/reviews_screen.dart';
// import '../exchange/exchange_requests_screen.dart';
// import '../auth/login_screen.dart';

// class ProfileOverviewScreen extends StatefulWidget {
//   const ProfileOverviewScreen({super.key});

//   @override
//   State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
// }

// class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
//   final supabase = Supabase.instance.client;
//   bool loading = true;
//   bool uploadingAvatar = false;
//   Map<String, dynamic>? userData;

//   int sentCount = 0;
//   int receivedCount = 0;
//   int exchangeCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loading = true);

//     try {
//       final userRes = await supabase
//           .from('users')
//           .select()
//           .eq('id', currentUser.id)
//           .maybeSingle();

//       final sentRes = await supabase
//           .from('exchanges')
//           .select('id')
//           .eq('proposer_id', currentUser.id);

//       final itemsRes = await supabase
//           .from('items')
//           .select('id')
//           .eq('user_id', currentUser.id);

//       final itemIds =
//           (itemsRes as List).map((e) => e['id'] as String).toList();

//       int received = 0;
//       if (itemIds.isNotEmpty) {
//         final receivedRes = await supabase
//             .from('exchanges')
//             .select('id')
//             .inFilter('item_id', itemIds);
//         received = (receivedRes as List).length;
//       }

//       setState(() {
//         userData = userRes as Map<String, dynamic>?;
//         sentCount = (sentRes as List).length;
//         receivedCount = received;
//         exchangeCount = sentCount + receivedCount;
//         loading = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Error loading user data: $e');
//       setState(() => loading = false);
//     }
//   }

//   Future<void> _updateDisplayName(String newName) async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     try {
//       await supabase
//           .from('users')
//           .update({'display_name': newName})
//           .eq('id', currentUser.id);
//       await _loadUserData();
//     } catch (e) {
//       debugPrint('❌ Error updating name: $e');
//     }
//   }

//   Future<void> _pickAndUploadAvatar() async {
//     final picker = ImagePicker();

//     final source = await showDialog<ImageSource>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Select Image Source'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, ImageSource.camera),
//             child: const Text('Camera'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, ImageSource.gallery),
//             child: const Text('Gallery'),
//           ),
//         ],
//       ),
//     );

//     if (source == null) return;

//     final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
//     if (pickedFile == null) return;

//     final file = File(pickedFile.path);
//     final fileName =
//         '${supabase.auth.currentUser!.id}_${path.basename(file.path)}';

//     setState(() => uploadingAvatar = true);

//     try {
//       await supabase.storage.from('item-images').upload(
//             fileName,
//             file,
//             fileOptions: const FileOptions(upsert: true),
//           );

//       final publicUrl =
//           supabase.storage.from('item-images').getPublicUrl(fileName);

//       await supabase
//           .from('users')
//           .update({'avatar_url': publicUrl})
//           .eq('id', supabase.auth.currentUser!.id);

//       await _loadUserData();
//     } catch (e) {
//       debugPrint('❌ Avatar upload error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to upload avatar')),
//       );
//     } finally {
//       setState(() => uploadingAvatar = false);
//     }
//   }

//   Future<void> _logout() async {
//     await supabase.auth.signOut();
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//       (route) => false,
//     );
//   }

//   void _showEditNameDialog() {
//     final controller = TextEditingController(text: userData?['display_name']);
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Edit Display Name'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter new name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _updateDisplayName(controller.text);
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (userData == null) {
//       return const Center(child: Text('User not found'));
//     }

//     final badges = (userData!['badges'] as List<dynamic>?) ?? [];

//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Align(
//           alignment: Alignment.centerLeft,
//           child: Text('Profile'),
//         ),
//         backgroundColor: kGreen,
//         // ✅ Removed refresh and logout buttons here
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildUserHeader(),
//             const SizedBox(height: 20),
//             _buildStatsRow(),
//             const SizedBox(height: 20),
//             _buildBadgesSection(badges),
//             const SizedBox(height: 20),
//             _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUserHeader() {
//     return Row(
//       children: [
//         Stack(
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundImage: userData!['avatar_url'] != null
//                   ? NetworkImage(userData!['avatar_url'])
//                   : null,
//               child: uploadingAvatar
//                   ? const CircularProgressIndicator()
//                   : (userData!['avatar_url'] == null
//                       ? const Icon(Icons.person, size: 40)
//                       : null),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: InkWell(
//                 onTap: _pickAndUploadAvatar,
//                 child: CircleAvatar(
//                   radius: 12,
//                   backgroundColor: kGreen,
//                   child:
//                       const Icon(Icons.edit, size: 14, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       userData!['display_name'] ?? 'Unknown User',
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit, size: 20),
//                     onPressed: _showEditNameDialog,
//                   ),
//                 ],
//               ),
//               Text(userData!['email'] ?? '',
//                   style: const TextStyle(color: Colors.grey)),
//               if (userData!['bio'] != null) ...[
//                 const SizedBox(height: 4),
//                 Text(userData!['bio'],
//                     style: const TextStyle(color: Colors.black87)),
//               ]
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
//         _buildStatCard(
//             'Trust Score', userData!['trust_score']?.toString() ?? '0'),
//         _buildStatCard('Exchanges', exchangeCount.toString()),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: kGreen.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(value,
//               style: const TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.bold)),
//           Text(title, style: const TextStyle(color: Colors.black54)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBadgesSection(List<dynamic> badges) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Badges',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         badges.isEmpty
//             ? const Text('No badges earned yet.')
//             : Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: badges
//                     .map((b) => Chip(
//                           label: Text(b.toString()),
//                           backgroundColor: kGreen.withOpacity(0.2),
//                         ))
//                     .toList(),
//               ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         _buildActionButton(
//           label: "Active / Archived Listings",
//           color: kGreen,
//           screen: const ProfileItemsScreen(),
//         ),
//         const SizedBox(height: 12),
//         _buildActionButton(
//           label: "My Exchanges",
//           color: kTeal,
//           screen: const ExchangeRequestsScreen(),
//         ),
//         const SizedBox(height: 12),
//         _buildActionButton(
//           label: "Reviews",
//           color: kTeal,
//           screen: const ReviewsScreen(),
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.redAccent,
//             minimumSize: const Size(double.infinity, 48),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           onPressed: _logout,
//           child: const Text('Logout', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required String label,
//     required Color color,
//     required Widget screen,
//   }) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         minimumSize: const Size(double.infinity, 48),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       onPressed: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => screen),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.white)),
//     );
//   }
// }  
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../../providers/items_provider.dart';
// import '../profile/profile_items_screen.dart';
// import '../profile/reviews_screen.dart';
// import '../exchange/exchange_requests_screen.dart';
// import '../auth/login_screen.dart';

// class ProfileOverviewScreen extends StatefulWidget {
//   const ProfileOverviewScreen({super.key});

//   @override
//   State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
// }

// class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
//   final supabase = Supabase.instance.client;
//   bool loading = true;
//   bool uploadingAvatar = false;
//   Map<String, dynamic>? userData;

//   int sentCount = 0;
//   int receivedCount = 0;
//   int exchangeCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loading = true);

//     try {
//       final userRes = await supabase
//           .from('users')
//           .select()
//           .eq('id', currentUser.id)
//           .maybeSingle();

//       final sentRes = await supabase
//           .from('exchanges')
//           .select('id')
//           .eq('proposer_id', currentUser.id);

//       final itemsRes = await supabase
//           .from('items')
//           .select('id')
//           .eq('user_id', currentUser.id);

//       final itemIds =
//           (itemsRes as List).map((e) => e['id'] as String).toList();

//       int received = 0;
//       if (itemIds.isNotEmpty) {
//         final receivedRes = await supabase
//             .from('exchanges')
//             .select('id')
//             .inFilter('item_id', itemIds);
//         received = (receivedRes as List).length;
//       }

//       setState(() {
//         userData = userRes as Map<String, dynamic>?;
//         sentCount = (sentRes as List).length;
//         receivedCount = received;
//         exchangeCount = sentCount + receivedCount;
//         loading = false;
//       });
//     } catch (e) {
//       debugPrint('❌ Error loading user data: $e');
//       setState(() => loading = false);
//     }
//   }

//   Future<void> _updateDisplayName(String newName) async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     try {
//       await supabase
//           .from('users')
//           .update({'display_name': newName})
//           .eq('id', currentUser.id);
//       await _loadUserData();
//     } catch (e) {
//       debugPrint('❌ Error updating name: $e');
//     }
//   }

//   Future<void> _updateRadius(double newRadius) async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     try {
//       await supabase
//           .from('users')
//           .update({'radius_km': newRadius})
//           .eq('id', currentUser.id);

//       if (mounted) {
//         // refresh provider feed
//         final provider = Provider.of<ItemsProvider>(context, listen: false);
//         provider.setSelectedRadius(newRadius);
//         await provider.loadNearby();
//         await provider.loadTrending();
//       }

//       await _loadUserData();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Radius updated successfully')),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error updating radius: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update radius: $e')),
//       );
//     }
//   }

//   Future<void> _pickAndUploadAvatar() async {
//     final picker = ImagePicker();

//     final source = await showDialog<ImageSource>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Select Image Source'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, ImageSource.camera),
//             child: const Text('Camera'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, ImageSource.gallery),
//             child: const Text('Gallery'),
//           ),
//         ],
//       ),
//     );

//     if (source == null) return;

//     final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
//     if (pickedFile == null) return;

//     final file = File(pickedFile.path);
//     final fileName =
//         '${supabase.auth.currentUser!.id}_${path.basename(file.path)}';

//     setState(() => uploadingAvatar = true);

//     try {
//       await supabase.storage.from('item-images').upload(
//             fileName,
//             file,
//             fileOptions: const FileOptions(upsert: true),
//           );

//       final publicUrl =
//           supabase.storage.from('item-images').getPublicUrl(fileName);

//       await supabase
//           .from('users')
//           .update({'avatar_url': publicUrl})
//           .eq('id', supabase.auth.currentUser!.id);

//       await _loadUserData();
//     } catch (e) {
//       debugPrint('❌ Avatar upload error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to upload avatar')),
//       );
//     } finally {
//       setState(() => uploadingAvatar = false);
//     }
//   }

//   Future<void> _logout() async {
//     await supabase.auth.signOut();
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//       (route) => false,
//     );
//   }

//   void _showEditNameDialog() {
//     final controller = TextEditingController(text: userData?['display_name']);
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Edit Display Name'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter new name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _updateDisplayName(controller.text);
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditRadiusDialog() {
//     double current = (userData?['radius_km'] ?? 30).toDouble();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Set Nearby Radius'),
//         content: StatefulBuilder(
//           builder: (context, setState) => Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('${current.toInt()} km',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 18)),
//               Slider(
//                 value: current,
//                 min: 5,
//                 max: 200,
//                 divisions: 39,
//                 activeColor: kTeal,
//                 label: '${current.toInt()} km',
//                 onChanged: (v) => setState(() => current = v),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _updateRadius(current);
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (userData == null) {
//       return const Center(child: Text('User not found'));
//     }

//     final badges = (userData!['badges'] as List<dynamic>?) ?? [];

//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Align(
//           alignment: Alignment.centerLeft,
//           child: Text('Profile'),
//         ),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildUserHeader(),
//             const SizedBox(height: 20),
//             _buildRadiusSection(), // 👈 added here
//             const SizedBox(height: 20),
//             _buildStatsRow(),
//             const SizedBox(height: 20),
//             _buildBadgesSection(badges),
//             const SizedBox(height: 20),
//             _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRadiusSection() {
//     final radius = (userData?['radius_km'] ?? 30).toDouble();
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: kTeal.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.my_location, color: kTeal),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'Search radius: ${radius.toInt()} km',
//               style: const TextStyle(fontSize: 16),
//             ),
//           ),
//           TextButton(
//             onPressed: _showEditRadiusDialog,
//             child: const Text('Edit'),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildUserHeader() {
//     return Row(
//       children: [
//         Stack(
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundImage: userData!['avatar_url'] != null
//                   ? NetworkImage(userData!['avatar_url'])
//                   : null,
//               child: uploadingAvatar
//                   ? const CircularProgressIndicator()
//                   : (userData!['avatar_url'] == null
//                       ? const Icon(Icons.person, size: 40)
//                       : null),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: InkWell(
//                 onTap: _pickAndUploadAvatar,
//                 child: CircleAvatar(
//                   radius: 12,
//                   backgroundColor: kGreen,
//                   child:
//                       const Icon(Icons.edit, size: 14, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       userData!['display_name'] ?? 'Unknown User',
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit, size: 20),
//                     onPressed: _showEditNameDialog,
//                   ),
//                 ],
//               ),
//               Text(userData!['email'] ?? '',
//                   style: const TextStyle(color: Colors.grey)),
//               if (userData!['bio'] != null) ...[
//                 const SizedBox(height: 4),
//                 Text(userData!['bio'],
//                     style: const TextStyle(color: Colors.black87)),
//               ]
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
//         _buildStatCard(
//             'Trust Score', userData!['trust_score']?.toString() ?? '0'),
//         _buildStatCard('Exchanges', exchangeCount.toString()),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: kGreen.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(value,
//               style: const TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.bold)),
//           Text(title, style: const TextStyle(color: Colors.black54)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBadgesSection(List<dynamic> badges) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Badges',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         badges.isEmpty
//             ? const Text('No badges earned yet.')
//             : Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: badges
//                     .map((b) => Chip(
//                           label: Text(b.toString()),
//                           backgroundColor: kGreen.withOpacity(0.2),
//                         ))
//                     .toList(),
//               ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         _buildActionButton(
//           label: "Active / Archived Listings",
//           color: kGreen,
//           screen: const ProfileItemsScreen(),
//         ),
//         const SizedBox(height: 12),
//         _buildActionButton(
//           label: "My Exchanges",
//           color: kTeal,
//           screen: const ExchangeRequestsScreen(),
//         ),
//         const SizedBox(height: 12),
//         _buildActionButton(
//           label: "Reviews",
//           color: kTeal,
//           screen: const ReviewsScreen(),
//         ),
//         const SizedBox(height: 12),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.redAccent,
//             minimumSize: const Size(double.infinity, 48),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           onPressed: _logout,
//           child: const Text('Logout', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required String label,
//     required Color color,
//     required Widget screen,
//   }) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         minimumSize: const Size(double.infinity, 48),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       onPressed: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => screen),
//       ),
//       child: Text(label, style: const TextStyle(color: Colors.white)),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../../providers/items_provider.dart';
import '../profile/profile_items_screen.dart';
import '../profile/reviews_screen.dart';
import '../exchange/exchange_requests_screen.dart';
import '../auth/login_screen.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  bool uploadingAvatar = false;
  Map<String, dynamic>? userData;

  int sentCount = 0;
  int receivedCount = 0;
  int exchangeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    setState(() => loading = true);

    try {
      final userRes = await supabase
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      final sentRes = await supabase
          .from('exchanges')
          .select('id')
          .eq('proposer_id', currentUser.id);

      final itemsRes = await supabase
          .from('items')
          .select('id')
          .eq('user_id', currentUser.id);

      final itemIds =
          (itemsRes as List).map((e) => e['id'] as String).toList();

      int received = 0;
      if (itemIds.isNotEmpty) {
        final receivedRes = await supabase
            .from('exchanges')
            .select('id')
            .inFilter('item_id', itemIds);
        received = (receivedRes as List).length;
      }

      setState(() {
        userData = userRes as Map<String, dynamic>?;
        sentCount = (sentRes as List).length;
        receivedCount = received;
        exchangeCount = sentCount + receivedCount;
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _updateDisplayName(String newName) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await supabase
          .from('users')
          .update({'display_name': newName})
          .eq('id', currentUser.id);
      await _loadUserData();
    } catch (e) {
      debugPrint('❌ Error updating name: $e');
    }
  }

  Future<void> _updateRadius(double newRadius) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await supabase
          .from('users')
          .update({'radius_km': newRadius})
          .eq('id', currentUser.id);

      if (mounted) {
        final provider = Provider.of<ItemsProvider>(context, listen: false);
        provider.setSelectedRadius(newRadius);
        await provider.loadNearby();
        await provider.loadTrending();
      }

      await _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Radius updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating radius: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update radius: $e')),
      );
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName =
        '${supabase.auth.currentUser!.id}_${path.basename(file.path)}';

    setState(() => uploadingAvatar = true);

    try {
      await supabase.storage.from('item-images').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          supabase.storage.from('item-images').getPublicUrl(fileName);

      await supabase
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', supabase.auth.currentUser!.id);

      await _loadUserData();
    } catch (e) {
      debugPrint('❌ Avatar upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload avatar')),
      );
    } finally {
      setState(() => uploadingAvatar = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: userData?['display_name']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateDisplayName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditRadiusDialog() {
    double current = (userData?['radius_km'] ?? 30).toDouble();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set Nearby Radius'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${current.toInt()} km',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Slider(
                value: current,
                min: 5,
                max: 200,
                divisions: 39,
                activeColor: kTeal,
                label: '${current.toInt()} km',
                onChanged: (v) => setState(() => current = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateRadius(current);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return const Center(child: Text('User not found'));
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Profile'),
        ),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 20),
            _buildRadiusSection(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusSection() {
    final radius = (userData?['radius_km'] ?? 30).toDouble();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kTeal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: kTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search radius: ${radius.toInt()} km',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: _showEditRadiusDialog,
            child: const Text('Edit'),
          )
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: userData!['avatar_url'] != null
                  ? NetworkImage(userData!['avatar_url'])
                  : null,
              child: uploadingAvatar
                  ? const CircularProgressIndicator()
                  : (userData!['avatar_url'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickAndUploadAvatar,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: kGreen,
                  child:
                      const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      userData!['display_name'] ?? 'Unknown User',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: _showEditNameDialog,
                  ),
                ],
              ),
              Text(userData!['email'] ?? '',
                  style: const TextStyle(color: Colors.grey)),
              if (userData!['bio'] != null) ...[
                const SizedBox(height: 4),
                Text(userData!['bio'],
                    style: const TextStyle(color: Colors.black87)),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
        _buildStatCard(
            'Trust Score', userData!['trust_score']?.toString() ?? '0'),
        _buildStatCard('Exchanges', exchangeCount.toString()),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          label: "Active / Archived Listings",
          color: kGreen,
          screen: const ProfileItemsScreen(),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: "My Exchanges",
          color: kTeal,
          screen: const ExchangeRequestsScreen(),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          label: "Reviews",
          color: kTeal,
          screen: const ReviewsScreen(),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _logout,
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Widget screen,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
