
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
// import 'dart:ui';

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
//       builder: (_) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.1)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Select Image Source',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: kTextDark),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: kGreen,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12))),
//                       onPressed: () =>
//                           Navigator.pop(context, ImageSource.camera),
//                       icon: const Icon(Icons.camera),
//                       label: const Text('Camera'),
//                     ),
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: kTeal,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12))),
//                       onPressed: () =>
//                           Navigator.pop(context, ImageSource.gallery),
//                       icon: const Icon(Icons.photo_library),
//                       label: const Text('Gallery'),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
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
//       builder: (_) => _glassDialog(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Edit Display Name',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: kTextDark)),
//             const SizedBox(height: 12),
//             TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                   hintText: 'Enter new name',
//                   hintStyle: const TextStyle(fontSize: 14),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.08),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none)),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel', style: TextStyle(fontSize: 14))),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: kGreen,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12))),
//                     onPressed: () {
//                       _updateDisplayName(controller.text);
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Save', style: TextStyle(fontSize: 14)))
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEditRadiusDialog() {
//     double current = (userData?['radius_km'] ?? 30).toDouble();

//     showDialog(
//       context: context,
//       builder: (_) => _glassDialog(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Set Nearby Radius',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: kTextDark)),
//             const SizedBox(height: 12),
//             Text('${current.toInt()} km',
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
//             Slider(
//               value: current,
//               min: 5,
//               max: 200,
//               divisions: 39,
//               activeColor: kTeal,
//               label: '${current.toInt()} km',
//               onChanged: (v) => setState(() => current = v),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Cancel', style: TextStyle(fontSize: 14))),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: kGreen,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12))),
//                     onPressed: () {
//                       _updateRadius(current);
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Save', style: TextStyle(fontSize: 14)))
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _glassDialog({required Widget child}) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white.withOpacity(0.1))),
//           child: child,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBg,
//       appBar: AppBar(
//         title: const Text('Profile', style: TextStyle(fontSize: 20)),
//         backgroundColor: kGreen,
//         elevation: 0,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : userData == null
//               ? const Center(
//                   child: Text('User not found', style: TextStyle(fontSize: 14)))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildUserHeader(),
//                       const SizedBox(height: 20),
//                       _buildRadiusSection(),
//                       const SizedBox(height: 20),
//                       _buildStatsRow(),
//                       const SizedBox(height: 20),
//                       _buildActionButtons(),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildUserHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//       ),
//       child: Row(
//         children: [
//           Stack(
//             children: [
//               CircleAvatar(
//                 radius: 48,
//                 backgroundColor: kGreen.withOpacity(0.2),
//                 backgroundImage: userData!['avatar_url'] != null
//                     ? NetworkImage(userData!['avatar_url'])
//                     : null,
//                 child: uploadingAvatar
//                     ? const CircularProgressIndicator()
//                     : (userData!['avatar_url'] == null
//                         ? const Icon(Icons.person, size: 36, color: kGreen)
//                         : null),
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: InkWell(
//                   onTap: _pickAndUploadAvatar,
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: kGreen,
//                     child:
//                         const Icon(Icons.edit, size: 18, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         userData!['display_name'] ?? 'Unknown User',
//                         style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: kTextDark),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.edit, size: 20, color: kTeal),
//                       onPressed: _showEditNameDialog,
//                     ),
//                   ],
//                 ),
//                 Text(userData!['email'] ?? '',
//                     style: const TextStyle(fontSize: 14, color: Colors.black54)),
//                 if (userData!['bio'] != null) ...[
//                   const SizedBox(height: 4),
//                   Text(userData!['bio'],
//                       style:
//                           const TextStyle(fontSize: 14, color: Colors.black87)),
//                 ]
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRadiusSection() {
//     final radius = (userData?['radius_km'] ?? 30).toDouble();
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: kTeal.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.my_location, color: kTeal),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'Search radius: ${radius.toInt()} km',
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//           TextButton(
//             onPressed: _showEditRadiusDialog,
//             child: const Text('Edit', style: TextStyle(fontSize: 14)),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildStatCard('Points', userData!['points']?.toString() ?? '0',
//             kAmber.withOpacity(0.15)),
//         _buildStatCard('Trust Score',
//             userData!['trust_score']?.toString() ?? '0', kTeal.withOpacity(0.15)),
//         _buildStatCard('Exchanges', exchangeCount.toString(),
//             kGreen.withOpacity(0.15)),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, Color bgColor) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [bgColor.withOpacity(0.5), bgColor.withOpacity(0.1)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight),
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4))
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(value,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.bold, color: kTextDark)),
//             const SizedBox(height: 4),
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
//           ],
//         ),
//       ),
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
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//           ),
//           onPressed: _logout,
//           child: const Text('Logout',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         elevation: 4,
//       ),
//       onPressed: () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => screen),
//       ),
//       child: Text(label,
//           style: const TextStyle(
//               color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
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
import 'dart:ui';

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
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: kTextDark),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () =>
                        Navigator.pop(context, ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kTeal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () =>
                        Navigator.pop(context, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              )
            ],
          ),
        ),
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
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => _glassDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Display Name',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: kTextDark)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: 'Enter new name',
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: kBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kGreen, width: 1.8))),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontSize: 14))),
                const SizedBox(width: 8),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      _updateDisplayName(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Save', style: TextStyle(fontSize: 14)))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showEditRadiusDialog() {
    double current = (userData?['radius_km'] ?? 30).toDouble();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => _glassDialog(
        child: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set Nearby Radius',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: kTextDark)),
              const SizedBox(height: 12),
              Text('${current.toInt()} km',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: kTextDark)),
              Slider(
                value: current,
                min: 5,
                max: 200,
                divisions: 39,
                activeColor: kTeal,
                label: '${current.toInt()} km',
                onChanged: (v) => setStateDialog(() => current = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(fontSize: 14))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        _updateRadius(current);
                        Navigator.pop(context);
                      },
                      child: const Text('Save', style: TextStyle(fontSize: 14)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassDialog({required Widget child}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container
      (
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
  title: const Text('Profile', style: TextStyle(fontSize: 20)),
  centerTitle: true,
  backgroundColor: kGreen,
  elevation: 0,
  foregroundColor: Colors.white, 
  surfaceTintColor: Colors.transparent,
),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(
                  child: Text('User not found', style: TextStyle(fontSize: 14)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kGreen.withOpacity(0.12), kTeal.withOpacity(0.10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: kGreen.withOpacity(0.18),
                backgroundImage: userData!['avatar_url'] != null
                    ? NetworkImage(userData!['avatar_url'])
                    : null,
                child: uploadingAvatar
                    ? const CircularProgressIndicator()
                    : (userData!['avatar_url'] == null
                        ? const Icon(Icons.person, size: 38, color: kGreen)
                        : null),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: InkWell(
                  onTap: _pickAndUploadAvatar,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: kGreen,
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
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
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: kTextDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: kTeal),
                      onPressed: _showEditNameDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  userData!['email'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                if (userData!['bio'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    userData!['bio'],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSection() {
    final radius = (userData?['radius_km'] ?? 30).toDouble();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(color: kTeal.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kTeal.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.my_location, color: kTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search radius: ${radius.toInt()} km',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextDark),
            ),
          ),
          TextButton(
            onPressed: _showEditRadiusDialog,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: kTeal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Points', userData!['points']?.toString() ?? '0',
            kAmber.withOpacity(0.15)),
        _buildStatCard('Trust Score',
            userData!['trust_score']?.toString() ?? '0', kTeal.withOpacity(0.15)),
        _buildStatCard('Exchanges', exchangeCount.toString(),
            kGreen.withOpacity(0.15)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor.withOpacity(0.55), bgColor.withOpacity(0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _logout,
          child: const Text('Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                    color: kTextDark, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}