
// import 'dart:io';
// import 'package:circlo_app/ui/profile/profile_items_screen.dart';
// import 'package:circlo_app/ui/profile/reviews_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../exchange/exchange_requests_screen.dart';

// class ProfileOverviewScreen extends StatefulWidget {
//   const ProfileOverviewScreen({super.key});

//   @override
//   State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
// }

// class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
//   final supabase = Supabase.instance.client;
//   bool loading = true;
//   bool uploadingAvatar = false; // ✅ track avatar upload
//   Map<String, dynamic>? userData;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//   }

//   Future<void> _loadUser() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loading = true);
//     try {
//       final res = await supabase
//           .from('users')
//           .select()
//           .eq('id', currentUser.id)
//           .maybeSingle();

//       setState(() {
//         userData = res as Map<String, dynamic>?;
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
//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error updating display name: $e');
//     }
//   }

//   Future<void> _pickAndUploadAvatar() async {
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

//     final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
//     if (pickedFile == null) return;

//     final file = File(pickedFile.path);
//     final fileName = 'avatars/${Supabase.instance.client.auth.currentUser!.id}_${path.basename(file.path)}';

//     setState(() => uploadingAvatar = true); // ✅ start uploading indicator

//     try {
//       // Upload to existing item-images bucket
//       await supabase.storage
//           .from('item-images')
//           .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

//       // Get public URL
//       final publicUrl = supabase.storage.from('item-images').getPublicUrl(fileName);

//       // Update user avatar_url
//       await supabase
//           .from('users')
//           .update({'avatar_url': publicUrl})
//           .eq('id', supabase.auth.currentUser!.id);

//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error uploading avatar: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload avatar')),
//         );
//       }
//     } finally {
//       setState(() => uploadingAvatar = false); // ✅ stop uploading indicator
//     }
//   }

//   void _editDisplayNameDialog() {
//     final controller = TextEditingController(text: userData?['display_name']);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Display Name'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter your name'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (userData == null) {
//       return const Scaffold(
//         body: Center(child: Text('User not found')),
//       );
//     }

//     final badges = (userData!['badges'] as List<dynamic>?) ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------------- USER INFO ----------------
//             Row(
//               children: [
//                 Stack(
//                   children: [
//                     GestureDetector(
//                       onTap: _pickAndUploadAvatar,
//                       child: CircleAvatar(
//                         radius: 40,
//                         backgroundImage: userData!['avatar_url'] != null
//                             ? NetworkImage(userData!['avatar_url'])
//                             : null,
//                         child: userData!['avatar_url'] == null
//                             ? const Icon(Icons.person, size: 40)
//                             : null,
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: CircleAvatar(
//                         radius: 12,
//                         backgroundColor: kGreen,
//                         child: uploadingAvatar
//                             ? const SizedBox(
//                                 width: 14,
//                                 height: 14,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(Icons.edit, size: 14, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               userData!['display_name'] ?? 'Unknown User',
//                               style: const TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit, size: 20),
//                             onPressed: _editDisplayNameDialog,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(userData!['email'] ?? '',
//                           style: const TextStyle(color: Colors.grey)),
//                       const SizedBox(height: 4),
//                       Text(userData!['bio'] ?? '',
//                           style: const TextStyle(color: Colors.black87)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // ---------------- STATS ----------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
//                 _buildStatCard('Trust Score', userData!['trust_score']?.toString() ?? '0'),
//                 _buildStatCard('Exchanges', userData!['exchanges']?.toString() ?? '0'),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // ---------------- BADGES ----------------
//             const Text('Badges', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: badges.map((b) {
//                 return Chip(
//                   label: Text(b.toString()),
//                   backgroundColor: kGreen.withOpacity(0.2),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),

//             // ---------------- ACTION BUTTONS ----------------
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kGreen,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ProfileItemsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Active / Archived Listings"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ExchangeRequestsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("My Exchanges"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ReviewsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Reviews"),
//             ),
//           ],
//         ),
//       ),
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
//           Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(title, style: const TextStyle(color: Colors.black54)),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'package:circlo_app/ui/profile/profile_items_screen.dart';
// import 'package:circlo_app/ui/profile/reviews_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../exchange/exchange_requests_screen.dart';

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

//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//   }

//   Future<void> _loadUser() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loading = true);
//     try {
//       final res = await supabase
//           .from('users')
//           .select()
//           .eq('id', currentUser.id)
//           .maybeSingle();

//       setState(() {
//         userData = res as Map<String, dynamic>?;
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
//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error updating display name: $e');
//     }
//   }

//   Future<void> _pickAndUploadAvatar() async {
//     final picker = ImagePicker();

//     // Show dialog to select source
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
//       // Upload to item-images bucket
//       await supabase.storage
//           .from('item-images')
//           .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

//       // Get public URL (directly, no .data)
//       final publicUrl = supabase.storage.from('item-images').getPublicUrl(fileName);

//       // Update users table
//       await supabase
//           .from('users')
//           .update({'avatar_url': publicUrl})
//           .eq('id', supabase.auth.currentUser!.id);

//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error uploading avatar: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload avatar')),
//         );
//       }
//     } finally {
//       setState(() => uploadingAvatar = false);
//     }
//   }

//   void _editDisplayNameDialog() {
//     final controller = TextEditingController(text: userData?['display_name']);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Display Name'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter your name'),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (userData == null) {
//       return const Scaffold(
//         body: Center(child: Text('User not found')),
//       );
//     }

//     final badges = (userData!['badges'] as List<dynamic>?) ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------------- USER INFO ----------------
//             Row(
//               children: [
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: userData!['avatar_url'] != null
//                           ? NetworkImage(userData!['avatar_url'])
//                           : null,
//                       child: userData!['avatar_url'] == null
//                           ? const Icon(Icons.person, size: 40)
//                           : null,
//                     ),
//                     if (uploadingAvatar)
//                       Positioned.fill(
//                         child: Container(
//                           color: Colors.black38,
//                           child: const Center(
//                             child: CircularProgressIndicator(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: InkWell(
//                         onTap: _pickAndUploadAvatar,
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: kGreen,
//                           child: const Icon(Icons.edit, size: 14, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               userData!['display_name'] ?? 'Unknown User',
//                               style: const TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit, size: 20),
//                             onPressed: _editDisplayNameDialog,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(userData!['email'] ?? '',
//                           style: const TextStyle(color: Colors.grey)),
//                       const SizedBox(height: 4),
//                       Text(userData!['bio'] ?? '',
//                           style: const TextStyle(color: Colors.black87)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // ---------------- STATS ----------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
//                 _buildStatCard('Trust Score',
//                     userData!['trust_score']?.toString() ?? '0'),
//                 _buildStatCard('Exchanges',
//                     userData!['exchanges']?.toString() ?? '0'),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // ---------------- BADGES ----------------
//             const Text('Badges', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: badges.map((b) {
//                 return Chip(
//                   label: Text(b.toString()),
//                   backgroundColor: kGreen.withOpacity(0.2),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),

//             // ---------------- ACTION BUTTONS ----------------
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kGreen,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ProfileItemsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Active / Archived Listings"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ExchangeRequestsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("My Exchanges"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ReviewsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Reviews"),
//             ),
//           ],
//         ),
//       ),
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
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(title, style: const TextStyle(color: Colors.black54)),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'package:circlo_app/ui/profile/profile_items_screen.dart';
// import 'package:circlo_app/ui/profile/reviews_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../exchange/exchange_requests_screen.dart';

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
//     _loadUser();
//   }

//   Future<void> _loadUser() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loading = true);
//     try {
//       // Load user data
//       final res = await supabase
//           .from('users')
//           .select()
//           .eq('id', currentUser.id)
//           .maybeSingle();

//       userData = res as Map<String, dynamic>?;

//       // ---------------- EXCHANGE COUNTS ----------------
//       // Sent exchanges
//       final sentResponse = await supabase
//           .from('exchanges')
//           .select('id')
//           .eq('proposer_id', currentUser.id);
//       sentCount = (sentResponse as List).length;

//       // Get all item IDs owned by this user
//       final itemsResponse = await supabase
//           .from('items')
//           .select('id')
//           .eq('user_id', currentUser.id);

//       final itemIds =
//           (itemsResponse as List).map((e) => e['id'] as String).toList();

//       // Received exchanges
//       if (itemIds.isNotEmpty) {
//         final receivedResponse = await supabase
//             .from('exchanges')
//             .select('id')
//             .inFilter('item_id', itemIds); // ✅ Fixed method
//         receivedCount = (receivedResponse as List).length;
//       }

//       exchangeCount = sentCount + receivedCount;

//       setState(() {
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
//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error updating display name: $e');
//     }
//   }

//   Future<void> _pickAndUploadAvatar() async {
//     final picker = ImagePicker();

//     // Show dialog to select source
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
//         '${Supabase.instance.client.auth.currentUser!.id}_${path.basename(file.path)}';

//     setState(() => uploadingAvatar = true);

//     try {
//       // Upload to Supabase Storage (item-images bucket)
//       await supabase.storage.from('item-images').upload(
//             fileName,
//             file,
//             fileOptions: const FileOptions(upsert: true),
//           );

//       // Get public URL
//       final publicUrl =
//           supabase.storage.from('item-images').getPublicUrl(fileName);

//       // Update user avatar_url
//       await supabase
//           .from('users')
//           .update({'avatar_url': publicUrl})
//           .eq('id', supabase.auth.currentUser!.id);

//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error uploading avatar: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload avatar')),
//         );
//       }
//     } finally {
//       setState(() => uploadingAvatar = false);
//     }
//   }

//   void _editDisplayNameDialog() {
//     final controller = TextEditingController(text: userData?['display_name']);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Display Name'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter your name'),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
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
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (userData == null) {
//       return const Scaffold(
//         body: Center(child: Text('User not found')),
//       );
//     }

//     final badges = (userData!['badges'] as List<dynamic>?) ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------------- USER INFO ----------------
//             Row(
//               children: [
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: userData!['avatar_url'] != null
//                           ? NetworkImage(userData!['avatar_url'])
//                           : null,
//                       child: uploadingAvatar
//                           ? const CircularProgressIndicator()
//                           : (userData!['avatar_url'] == null
//                               ? const Icon(Icons.person, size: 40)
//                               : null),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: InkWell(
//                         onTap: _pickAndUploadAvatar,
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: kGreen,
//                           child: const Icon(Icons.edit,
//                               size: 14, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               userData!['display_name'] ?? 'Unknown User',
//                               style: const TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit, size: 20),
//                             onPressed: _editDisplayNameDialog,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(userData!['email'] ?? '',
//                           style: const TextStyle(color: Colors.grey)),
//                       const SizedBox(height: 4),
//                       Text(userData!['bio'] ?? '',
//                           style: const TextStyle(color: Colors.black87)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // ---------------- STATS ----------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
//                 _buildStatCard('Trust Score',
//                     userData!['trust_score']?.toString() ?? '0'),
//                 _buildStatCard('Exchanges', exchangeCount.toString()),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // ---------------- BADGES ----------------
//             const Text('Badges', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: badges.map((b) {
//                 return Chip(
//                   label: Text(b.toString()),
//                   backgroundColor: kGreen.withOpacity(0.2),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),

//             // ---------------- ACTION BUTTONS ----------------
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kGreen,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ProfileItemsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Active / Archived Listings"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ExchangeRequestsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("My Exchanges"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ReviewsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Reviews"),
//             ),
//           ],
//         ),
//       ),
        
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
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(title, style: const TextStyle(color: Colors.black54)),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:io';
// import 'package:circlo_app/ui/home/search_screen.dart';
// import 'package:circlo_app/ui/profile/profile_items_screen.dart';
// import 'package:circlo_app/ui/profile/reviews_screen.dart';
// import 'package:circlo_app/ui/widgets/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/app_theme.dart';
// import '../exchange/exchange_requests_screen.dart';
// import '../home/home_feed_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../home/offer_item_screen.dart';

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
//     _loadUser();
//   }

//   Future<void> _loadUser() async {
//     final currentUser = supabase.auth.currentUser;
//     if (currentUser == null) return;

//     setState(() => loading = true);
//     try {
//       // Load user data
//       final res = await supabase
//           .from('users')
//           .select()
//           .eq('id', currentUser.id)
//           .maybeSingle();

//       userData = res as Map<String, dynamic>?;

//       // Sent exchanges
//       final sentResponse = await supabase
//           .from('exchanges')
//           .select('id')
//           .eq('proposer_id', currentUser.id);
//       sentCount = (sentResponse as List).length;

//       // Get all item IDs owned by this user
//       final itemsResponse = await supabase
//           .from('items')
//           .select('id')
//           .eq('user_id', currentUser.id);

//       final itemIds =
//           (itemsResponse as List).map((e) => e['id'] as String).toList();

//       // Received exchanges
//       if (itemIds.isNotEmpty) {
//         final receivedResponse = await supabase
//             .from('exchanges')
//             .select('id')
//             .inFilter('item_id', itemIds);
//         receivedCount = (receivedResponse as List).length;
//       }

//       exchangeCount = sentCount + receivedCount;

//       setState(() {
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
//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error updating display name: $e');
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
//         '${Supabase.instance.client.auth.currentUser!.id}_${path.basename(file.path)}';

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

//       await _loadUser();
//     } catch (e) {
//       debugPrint('❌ Error uploading avatar: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to upload avatar')),
//         );
//       }
//     } finally {
//       setState(() => uploadingAvatar = false);
//     }
//   }

//   void _editDisplayNameDialog() {
//     final controller = TextEditingController(text: userData?['display_name']);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Display Name'),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter your name'),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
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

//   void _handleNavTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const HomeFeedScreen()),
//         );
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const SearchScreen()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ChatListScreen()),
//         );
//         break;
//       case 4:
//         // Already on Profile
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
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (userData == null) {
//       return const Scaffold(
//         body: Center(child: Text('User not found')),
//       );
//     }

//     final badges = (userData!['badges'] as List<dynamic>?) ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // USER INFO
//             Row(
//               children: [
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundImage: userData!['avatar_url'] != null
//                           ? NetworkImage(userData!['avatar_url'])
//                           : null,
//                       child: uploadingAvatar
//                           ? const CircularProgressIndicator()
//                           : (userData!['avatar_url'] == null
//                               ? const Icon(Icons.person, size: 40)
//                               : null),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: InkWell(
//                         onTap: _pickAndUploadAvatar,
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: kGreen,
//                           child: const Icon(Icons.edit,
//                               size: 14, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               userData!['display_name'] ?? 'Unknown User',
//                               style: const TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit, size: 20),
//                             onPressed: _editDisplayNameDialog,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(userData!['email'] ?? '',
//                           style: const TextStyle(color: Colors.grey)),
//                       const SizedBox(height: 4),
//                       Text(userData!['bio'] ?? '',
//                           style: const TextStyle(color: Colors.black87)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // STATS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatCard('Points', userData!['points']?.toString() ?? '0'),
//                 _buildStatCard('Trust Score',
//                     userData!['trust_score']?.toString() ?? '0'),
//                 _buildStatCard('Exchanges', exchangeCount.toString()),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // BADGES
//             const Text('Badges', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: badges.map((b) {
//                 return Chip(
//                   label: Text(b.toString()),
//                   backgroundColor: kGreen.withOpacity(0.2),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),

//             // ACTION BUTTONS
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kGreen,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ProfileItemsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Active / Archived Listings"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ExchangeRequestsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("My Exchanges"),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const ReviewsScreen(),
//                   ),
//                 );
//               },
//               child: const Text("Reviews"),
//             ),
//           ],
//         ),
//       ),
//       // ✅ BottomNavBar
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 4, // Profile tab
//         onTap: _handleNavTap,
//         onFabPressed: _handleFabPressed,
//       ),
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
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(title, style: const TextStyle(color: Colors.black54)),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';
import '../profile/profile_items_screen.dart';
import '../profile/reviews_screen.dart';
import '../exchange/exchange_requests_screen.dart';

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

  // ------------------ LOAD USER DATA ------------------
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

  // ------------------ UPDATE DISPLAY NAME ------------------
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

  // ------------------ UPLOAD AVATAR ------------------
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

  // ------------------ EDIT NAME DIALOG ------------------
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

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return const Center(child: Text('User not found'));
    }

    final badges = (userData!['badges'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Profile'),
        ),
        backgroundColor: kGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildBadgesSection(badges),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ------------------ COMPONENTS ------------------
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

  Widget _buildBadgesSection(List<dynamic> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Badges',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        badges.isEmpty
            ? const Text('No badges earned yet.')
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: badges
                    .map((b) => Chip(
                          label: Text(b.toString()),
                          backgroundColor: kGreen.withOpacity(0.2),
                        ))
                    .toList(),
              ),
      ],
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
