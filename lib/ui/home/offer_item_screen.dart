// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_item_service.dart';
// import 'package:flutter/foundation.dart';

// class OfferItemScreen extends StatefulWidget {
//   const OfferItemScreen({super.key});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;

//   final picker = ImagePicker();

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
//     }
//   }

//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
//       return;
//     }

//     setState(() => isLoading = true);
//     try {
//       String? uploadedUrl;
//       if (imageBytes != null) {
//         uploadedUrl = await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       await SupabaseItemService.addItem(
//         title: title,
//         description: desc,
//         category: category,
//         condition: condition,
//         radiusKm: radiusKm,
//         imageUrl: uploadedUrl,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item posted successfully')));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create listing failed: $e')));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = ['Electronics', 'Furniture', 'Clothes', 'Books', 'Sports', 'Other'];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Listing'), backgroundColor: kGreen),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Image picker preview
//             GestureDetector(
//               onTap: () async {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(children: [
//                       ListTile(leading: const Icon(Icons.photo), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
//                       ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
//                     ]),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!, fit: BoxFit.cover, width: double.infinity)
//                     : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
//                         Icon(Icons.add_a_photo, size: 34, color: Colors.grey),
//                         SizedBox(height: 8),
//                         Text('Tap to add photo'),
//                       ]),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
//             const SizedBox(height: 12),
//             Row(children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: category,
//                   items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                   onChanged: (v) => setState(() => category = v ?? category),
//                   decoration: const InputDecoration(labelText: 'Category'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: condition,
//                   items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                   onChanged: (v) => setState(() => condition = v ?? condition),
//                   decoration: const InputDecoration(labelText: 'Condition'),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               const Text('Visible radius (km)', style: TextStyle(fontWeight: FontWeight.w600)),
//               Text('${radiusKm.toStringAsFixed(0)} km'),
//             ]),
//             Slider(value: radiusKm, min: 1, max: 200, divisions: 199, onChanged: (v) => setState(() => radiusKm = v)),
//             const SizedBox(height: 18),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Post Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_item_service.dart';

// class OfferItemScreen extends StatefulWidget {
//   const OfferItemScreen({super.key});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10.0;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;
//   Map<String, dynamic>? location;

//   final picker = ImagePicker();

//   // 📸 pick image
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1600,
//       );
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
//     }
//   }

//   // 📍 get current location
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Enable location services first')));
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Location denied')));
//         return;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Location permanently denied, enable in settings')));
//       return;
//     }

//     final pos = await Geolocator.getCurrentPosition();
//     setState(() {
//       location = {'lat': pos.latitude, 'lng': pos.longitude};
//     });
//   }

//   // 🚀 submit new item
//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a title')));
//       return;
//     }

//     setState(() => isLoading = true);
//     try {
//       String? uploadedUrl;
//       if (imageBytes != null) {
//         uploadedUrl =
//             await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       await SupabaseItemService.addItem(
//         title: title,
//         description: desc,
//         category: category,
//         condition: condition,
//         radiusKm: radiusKm,
//         imageUrl: uploadedUrl,
//         trustScore: 0,
//         location: location,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Item posted successfully')));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Create listing failed: $e')));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = [
//       'Electronics',
//       'Furniture',
//       'Clothes',
//       'Books',
//       'Sports',
//       'Other'
//     ];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar:
//           AppBar(title: const Text('Create Listing'), backgroundColor: kGreen),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // 📸 image preview
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(children: [
//                       ListTile(
//                           leading: const Icon(Icons.photo),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           }),
//                       ListTile(
//                           leading: const Icon(Icons.camera_alt),
//                           title: const Text('Camera'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.camera);
//                           }),
//                     ]),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!,
//                         fit: BoxFit.cover, width: double.infinity)
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.add_a_photo, size: 34, color: Colors.grey),
//                           SizedBox(height: 8),
//                           Text('Tap to add photo'),
//                         ]),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: _titleCtrl,
//                 decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(
//                 controller: _descCtrl,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3),
//             const SizedBox(height: 12),
//             Row(children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: category,
//                   items: categories
//                       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                       .toList(),
//                   onChanged: (v) => setState(() => category = v ?? category),
//                   decoration: const InputDecoration(labelText: 'Category'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: condition,
//                   items: conditions
//                       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                       .toList(),
//                   onChanged: (v) => setState(() => condition = v ?? condition),
//                   decoration: const InputDecoration(labelText: 'Condition'),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Visible radius (km)',
//                       style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text('${radiusKm.toStringAsFixed(0)} km'),
//                 ]),
//             Slider(
//                 value: radiusKm,
//                 min: 1,
//                 max: 200,
//                 divisions: 199,
//                 onChanged: (v) => setState(() => radiusKm = v)),
//             const SizedBox(height: 12),
//             // 📍 location button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: Text(location == null
//                   ? 'Use Current Location'
//                   : 'Location: ${location!['lat']?.toStringAsFixed(2)}, ${location!['lng']?.toStringAsFixed(2)}'),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kTeal,
//                   minimumSize: const Size(double.infinity, 45)),
//               onPressed: _getCurrentLocation,
//             ),
//             const SizedBox(height: 18),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Post Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/ui/home/offer_item_screen.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../utils/app_theme.dart';
// import '../../services/supabase_item_service.dart';
// import 'location_picker_screen.dart'; // make sure this exists and returns a Map

// class OfferItemScreen extends StatefulWidget {
//   const OfferItemScreen({super.key});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10.0;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;

//   Map<String, dynamic>? selectedLocation; // ✅ typed properly
//   final picker = ImagePicker();

//   // pick image
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1600,
//       );
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
//     }
//   }

//   // get current GPS location (shortcut)
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Enable location services first')));
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Location denied')));
//         return;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Location permanently denied, enable in settings')));
//       return;
//     }

//     final pos = await Geolocator.getCurrentPosition();
//     setState(() {
//       selectedLocation = {'lat': pos.latitude, 'lng': pos.longitude};
//     });
//   }

//   // format coord helper
//   String _coordLabel() {
//     if (selectedLocation == null) return 'Select Location on Map';
//     String fmt(dynamic v) {
//       if (v == null) return '?';
//       if (v is num) return v.toStringAsFixed(2);
//       return v.toString();
//     }

//     final lat = fmt(selectedLocation!['lat']);
//     final lng = fmt(selectedLocation!['lng']);
//     return 'Location: $lat, $lng';
//   }

//   // submit new item
//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a title')));
//       return;
//     }

//     setState(() => isLoading = true);
//     try {
//       String? uploadedUrl;
//       if (imageBytes != null) {
//         uploadedUrl =
//             await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       // NOTE: ensure your SupabaseItemService.addItem accepts `location` and `trustScore`
//       await SupabaseItemService.addItem(
//         title: title,
//         description: desc,
//         category: category,
//         condition: condition,
//         radiusKm: radiusKm,
//         imageUrl: uploadedUrl,
//         trustScore: 0,
//         location: selectedLocation, // typed as Map<String, dynamic>?
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Item posted successfully')));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Create listing failed: $e')));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = [
//       'Electronics',
//       'Furniture',
//       'Clothes',
//       'Books',
//       'Sports',
//       'Other'
//     ];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar:
//           AppBar(title: const Text('Create Listing'), backgroundColor: kGreen),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Image picker
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(children: [
//                       ListTile(
//                           leading: const Icon(Icons.photo),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           }),
//                       ListTile(
//                           leading: const Icon(Icons.camera_alt),
//                           title: const Text('Camera'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.camera);
//                           }),
//                     ]),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!,
//                         fit: BoxFit.cover, width: double.infinity)
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.add_a_photo, size: 34, color: Colors.grey),
//                           SizedBox(height: 8),
//                           Text('Tap to add photo'),
//                         ]),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: _titleCtrl,
//                 decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(
//                 controller: _descCtrl,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3),
//             const SizedBox(height: 12),

//             // Category + Condition
//             Row(children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: category,
//                   items: categories
//                       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                       .toList(),
//                   onChanged: (v) => setState(() => category = v ?? category),
//                   decoration: const InputDecoration(labelText: 'Category'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: condition,
//                   items: conditions
//                       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                       .toList(),
//                   onChanged: (v) => setState(() => condition = v ?? condition),
//                   decoration: const InputDecoration(labelText: 'Condition'),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),

//             // Radius
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Visible radius (km)',
//                       style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text('${radiusKm.toStringAsFixed(0)} km'),
//                 ]),
//             Slider(
//                 value: radiusKm,
//                 min: 1,
//                 max: 200,
//                 divisions: 199,
//                 onChanged: (v) => setState(() => radiusKm = v)),
//             const SizedBox(height: 12),

//             // Location selection button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: Text(_coordLabel()),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kTeal,
//                   minimumSize: const Size(double.infinity, 45)),
//               onPressed: () async {
//                 // open your LocationPickerScreen which should return a Map (lat,lng)
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//                 );

//                 // ✅ SAFELY cast the dynamic Map to Map<String,dynamic>
//                 if (result != null && result is Map) {
//                   setState(() => selectedLocation = Map<String, dynamic>.from(result));
//                 }
//               },
//             ),

//             // Optional: use current GPS quickly
//             TextButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: const Text("Use Current GPS Location"),
//               onPressed: _getCurrentLocation,
//             ),

//             const SizedBox(height: 18),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Post Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart'; // ✅ new import
// import '../../utils/app_theme.dart';
// import '../../services/supabase_item_service.dart';
// import 'location_picker_screen.dart';

// class OfferItemScreen extends StatefulWidget {
//   const OfferItemScreen({super.key});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10.0;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;

//   Map<String, dynamic>? selectedLocation; // {lat, lng, name}
//   final picker = ImagePicker();

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1600,
//       );
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Enable location services first')));
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Location denied')));
//         return;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Location permanently denied, enable in settings')));
//       return;
//     }

//     final pos = await Geolocator.getCurrentPosition();
//     await _setLocationWithName(pos.latitude, pos.longitude);
//   }

//   // ✅ Get place name from coordinates
//   Future<void> _setLocationWithName(double lat, double lng) async {
//     String placeName = 'Unknown location';
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         final placemark = placemarks.first;
//         placeName =
//             '${placemark.name ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}';
//       }
//     } catch (e) {
//       print('Reverse geocode failed: $e');
//     }

//     setState(() {
//       selectedLocation = {'lat': lat, 'lng': lng, 'name': placeName};
//     });
//   }

//   String _coordLabel() {
//     if (selectedLocation == null) return 'Select Location on Map';
//     return selectedLocation!['name'] ?? 'Unknown location';
//   }

//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();
//     if (title.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a title')));
//       return;
//     }

//     setState(() => isLoading = true);
//     try {
//       String? uploadedUrl;
//       if (imageBytes != null) {
//         uploadedUrl =
//             await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       await SupabaseItemService.addItem(
//         title: title,
//         description: desc,
//         category: category,
//         condition: condition,
//         radiusKm: radiusKm,
//         imageUrl: uploadedUrl,
//         trustScore: 0,
//         location: selectedLocation, // ✅ now includes name
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Item posted successfully')));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Create listing failed: $e')));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = [
//       'Electronics',
//       'Furniture',
//       'Clothes',
//       'Books',
//       'Sports',
//       'Other'
//     ];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Listing'), backgroundColor: kGreen),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(children: [
//                       ListTile(
//                           leading: const Icon(Icons.photo),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           }),
//                       ListTile(
//                           leading: const Icon(Icons.camera_alt),
//                           title: const Text('Camera'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.camera);
//                           }),
//                     ]),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!,
//                         fit: BoxFit.cover, width: double.infinity)
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(Icons.add_a_photo, size: 34, color: Colors.grey),
//                           SizedBox(height: 8),
//                           Text('Tap to add photo'),
//                         ]),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//                 controller: _titleCtrl,
//                 decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(
//                 controller: _descCtrl,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3),
//             const SizedBox(height: 12),
//             Row(children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: category,
//                   items: categories
//                       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                       .toList(),
//                   onChanged: (v) => setState(() => category = v ?? category),
//                   decoration: const InputDecoration(labelText: 'Category'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: condition,
//                   items: conditions
//                       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                       .toList(),
//                   onChanged: (v) => setState(() => condition = v ?? condition),
//                   decoration: const InputDecoration(labelText: 'Condition'),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('Visible radius (km)',
//                       style: TextStyle(fontWeight: FontWeight.w600)),
//                   Text('${radiusKm.toStringAsFixed(0)} km'),
//                 ]),
//             Slider(
//                 value: radiusKm,
//                 min: 1,
//                 max: 200,
//                 divisions: 199,
//                 onChanged: (v) => setState(() => radiusKm = v)),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: Text(_coordLabel()),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kTeal,
//                   minimumSize: const Size(double.infinity, 45)),
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//                 );

//                 if (result != null && result is Map) {
//                   final lat = result['lat'];
//                   final lng = result['lng'];
//                   if (lat != null && lng != null) {
//                     await _setLocationWithName(lat, lng); // ✅ set name
//                   }
//                 }
//               },
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: const Text("Use Current GPS Location"),
//               onPressed: _getCurrentLocation,
//             ),
//             const SizedBox(height: 18),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Post Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import '../../models/item_model.dart';
// import '../../services/supabase_item_service.dart';
// import '../../utils/app_theme.dart';
// import 'location_picker_screen.dart';

// class OfferItemScreen extends StatefulWidget {
//   final Item? itemToEdit;
//   const OfferItemScreen({super.key, this.itemToEdit});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10.0;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;
//   Map<String, dynamic>? selectedLocation;

//   final picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     final item = widget.itemToEdit;

//     if (item != null) {
//       _titleCtrl.text = item.title;
//       _descCtrl.text = item.description ?? '';
//       category = item.category ?? 'Electronics';
//       condition = item.condition ?? 'good';
//       radiusKm = item.radiusKm;
//       selectedLocation = item.location;
//       imagePreviewPath = item.imageUrl;
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(source: source, imageQuality: 80);
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       _showSnack('Image pick failed: $e');
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showSnack('Enable location services first');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showSnack('Location permission denied');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showSnack('Location permanently denied, please enable in settings');
//       return;
//     }

//     final pos = await Geolocator.getCurrentPosition();
//     await _setLocationWithName(pos.latitude, pos.longitude);
//   }

//   Future<void> _setLocationWithName(double lat, double lng) async {
//     String placeName = 'Unknown location';
//     try {
//       final placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         placeName = '${p.locality ?? ''}, ${p.country ?? ''}';
//       }
//     } catch (_) {}
//     setState(() {
//       selectedLocation = {'lat': lat, 'lng': lng, 'name': placeName};
//     });
//   }

//   String _coordLabel() {
//     if (selectedLocation == null) return 'Select Location on Map';
//     return selectedLocation!['name'] ?? 'Unknown location';
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();

//     if (title.isEmpty) {
//       _showSnack('Please enter a title');
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final item = widget.itemToEdit;
//       String? uploadedUrl = item?.imageUrl;

//       // Upload image if new selected
//       if (imageBytes != null) {
//         uploadedUrl =
//             await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       if (item == null) {
//         // ADD new item
//         await SupabaseItemService.addItem(
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           trustScore: 0.0,
//           location: selectedLocation,
//         );
//         _showSnack('Item posted successfully');
//       } else {
//         // UPDATE existing
//         await SupabaseItemService.updateItem(
//           id: item.id,
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           location: selectedLocation,
//         );
//         _showSnack('Item updated successfully');
//       }

//       if (mounted) Navigator.pop(context, true);
//     } catch (e) {
//       _showSnack('Failed: $e');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = ['Electronics', 'Furniture', 'Clothes', 'Books', 'Sports', 'Other'];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.itemToEdit == null ? 'Create Listing' : 'Edit Listing'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(
//                       children: [
//                         ListTile(
//                           leading: const Icon(Icons.photo),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           },
//                         ),
//                         ListTile(
//                           leading: const Icon(Icons.camera_alt),
//                           title: const Text('Camera'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.camera);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!, fit: BoxFit.cover)
//                     : (imagePreviewPath != null
//                         ? Image.network(imagePreviewPath!, fit: BoxFit.cover)
//                         : const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_a_photo, color: Colors.grey, size: 34),
//                                 SizedBox(height: 8),
//                                 Text('Tap to add photo'),
//                               ],
//                             ),
//                           )),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _descCtrl,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 12),

//             // Dropdowns
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: category,
//                     decoration: const InputDecoration(labelText: 'Category'),
//                     items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                     onChanged: (v) => setState(() => category = v ?? category),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: condition,
//                     decoration: const InputDecoration(labelText: 'Condition'),
//                     items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                     onChanged: (v) => setState(() => condition = v ?? condition),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Visible radius (km)', style: TextStyle(fontWeight: FontWeight.w600)),
//                 Text('${radiusKm.toStringAsFixed(0)} km'),
//               ],
//             ),
//             Slider(
//               value: radiusKm,
//               min: 1,
//               max: 200,
//               divisions: 199,
//               onChanged: (v) => setState(() => radiusKm = v),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: Text(_coordLabel()),
//               style: ElevatedButton.styleFrom(backgroundColor: kTeal, minimumSize: const Size(double.infinity, 45)),
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//                 );
//                 if (result != null && result is Map) {
//                   await _setLocationWithName(result['lat'], result['lng']);
//                 }
//               },
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: const Text("Use Current GPS Location"),
//               onPressed: _getCurrentLocation,
//             ),
//             const SizedBox(height: 18),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(widget.itemToEdit == null ? 'Post Listing' : 'Update Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import '../../models/item_model.dart';
// import '../../services/supabase_item_service.dart';
// import '../../utils/app_theme.dart';
// import 'location_picker_screen.dart';

// class OfferItemScreen extends StatefulWidget {
//   final Item? itemToEdit;
//   const OfferItemScreen({super.key, this.itemToEdit});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10.0;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;
//   Map<String, dynamic>? selectedLocation;

//   final picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     final item = widget.itemToEdit;

//     if (item != null) {
//       _titleCtrl.text = item.title;
//       _descCtrl.text = item.description ?? '';
//       category = item.category ?? 'Electronics';
//       condition = item.condition ?? 'good';
//       radiusKm = item.radiusKm;
//       selectedLocation = item.location;
//       imagePreviewPath = item.imageUrl;
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(source: source, imageQuality: 80);
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       if (!mounted) return;
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       _showSnack('Image pick failed: $e');
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showSnack('Enable location services first');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showSnack('Location permission denied');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showSnack('Location permanently denied, please enable in settings');
//       return;
//     }

//     final pos = await Geolocator.getCurrentPosition();
//     await _setLocationWithName(pos.latitude, pos.longitude);
//   }

//   Future<void> _setLocationWithName(double lat, double lng) async {
//     String placeName = 'Unknown location';
//     try {
//       final placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         placeName = '${p.locality ?? ''}, ${p.country ?? ''}';
//       }
//     } catch (_) {}
//     if (!mounted) return;
//     setState(() {
//       selectedLocation = {'lat': lat, 'lng': lng, 'name': placeName};
//     });
//   }

//   String _coordLabel() {
//     if (selectedLocation == null) return 'Select Location on Map';
//     return selectedLocation!['name'] ?? 'Unknown location';
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();

//     if (title.isEmpty) {
//       _showSnack('Please enter a title');
//       return;
//     }

//     if (!mounted) return;
//     setState(() => isLoading = true);

//     try {
//       final item = widget.itemToEdit;
//       String? uploadedUrl = item?.imageUrl;

//       // Upload image if new selected
//       if (imageBytes != null) {
//         uploadedUrl =
//             await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       if (item == null) {
//         // ADD new item
//         await SupabaseItemService.addItem(
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           trustScore: 0.0,
//           location: selectedLocation,
//         );
//         if (!mounted) return;
//         _showSnack('Item posted successfully');
//         Navigator.pop(context, true);
//       } else {
//         // UPDATE existing
//         await SupabaseItemService.updateItem(
//           id: item.id,
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           location: selectedLocation,
//         );
//         if (!mounted) return;
//         _showSnack('Item updated successfully');
//         Navigator.pop(context, true); // return true to refresh list
//       }
//     } catch (e) {
//       _showSnack('Failed: $e');
//     } finally {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = ['Electronics', 'Furniture', 'Clothes', 'Books', 'Sports', 'Other'];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.itemToEdit == null ? 'Create Listing' : 'Edit Listing'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(
//                       children: [
//                         ListTile(
//                           leading: const Icon(Icons.photo),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           },
//                         ),
//                         ListTile(
//                           leading: const Icon(Icons.camera_alt),
//                           title: const Text('Camera'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.camera);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!, fit: BoxFit.cover)
//                     : (imagePreviewPath != null
//                         ? Image.network(imagePreviewPath!, fit: BoxFit.cover)
//                         : const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_a_photo, color: Colors.grey, size: 34),
//                                 SizedBox(height: 8),
//                                 Text('Tap to add photo'),
//                               ],
//                             ),
//                           )),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _descCtrl,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: category,
//                     decoration: const InputDecoration(labelText: 'Category'),
//                     items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                     onChanged: (v) => setState(() => category = v ?? category),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: condition,
//                     decoration: const InputDecoration(labelText: 'Condition'),
//                     items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                     onChanged: (v) => setState(() => condition = v ?? condition),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Visible radius (km)', style: TextStyle(fontWeight: FontWeight.w600)),
//                 Text('${radiusKm.toStringAsFixed(0)} km'),
//               ],
//             ),
//             Slider(
//               value: radiusKm,
//               min: 1,
//               max: 200,
//               divisions: 199,
//               onChanged: (v) => setState(() => radiusKm = v),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: Text(_coordLabel()),
//               style: ElevatedButton.styleFrom(backgroundColor: kTeal, minimumSize: const Size(double.infinity, 45)),
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//                 );
//                 if (result != null && result is Map) {
//                   await _setLocationWithName(result['lat'], result['lng']);
//                 }
//               },
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: const Text("Use Current GPS Location"),
//               onPressed: _getCurrentLocation,
//             ),
//             const SizedBox(height: 18),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(widget.itemToEdit == null ? 'Post Listing' : 'Update Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import '../../models/item_model.dart';
// import '../../services/supabase_item_service.dart';
// import '../../utils/app_theme.dart';
// import 'location_picker_screen.dart';

// class OfferItemScreen extends StatefulWidget {
//   final Item? itemToEdit;
//   const OfferItemScreen({super.key, this.itemToEdit});

//   @override
//   State<OfferItemScreen> createState() => _OfferItemScreenState();
// }

// class _OfferItemScreenState extends State<OfferItemScreen> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   String category = 'Electronics';
//   String condition = 'good';
//   double radiusKm = 10.0;
//   Uint8List? imageBytes;
//   String? imagePreviewPath;
//   bool isLoading = false;
//   Map<String, dynamic>? selectedLocation;

//   final picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     final item = widget.itemToEdit;
//     if (item != null) {
//       _titleCtrl.text = item.title;
//       _descCtrl.text = item.description ?? '';
//       category = item.category ?? 'Electronics';
//       condition = item.condition ?? 'good';
//       radiusKm = item.radiusKm;
//       selectedLocation = item.location;
//       imagePreviewPath = item.imageUrl;
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await picker.pickImage(source: source, imageQuality: 80);
//       if (picked == null) return;
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         imageBytes = bytes;
//         imagePreviewPath = picked.path;
//       });
//     } catch (e) {
//       _showSnack('Image pick failed: $e');
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showSnack('Enable location services first');
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showSnack('Location permission denied');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showSnack('Location permanently denied, please enable in settings');
//       return;
//     }

//     final pos = await Geolocator.getCurrentPosition();
//     await _setLocationWithName(pos.latitude, pos.longitude);
//   }

//   Future<void> _setLocationWithName(double lat, double lng) async {
//     String placeName = 'Unknown location';
//     try {
//       final placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         placeName = '${p.locality ?? ''}, ${p.country ?? ''}';
//       }
//     } catch (_) {}
//     setState(() {
//       selectedLocation = {'lat': lat, 'lng': lng, 'name': placeName};
//     });
//   }

//   String _coordLabel() {
//     if (selectedLocation == null) return 'Select Location on Map';
//     return selectedLocation!['name'] ?? 'Unknown location';
//   }

//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Future<void> _submit() async {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();

//     if (title.isEmpty) {
//       _showSnack('Please enter a title');
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final item = widget.itemToEdit;
//       String? uploadedUrl = item?.imageUrl;

//       // Upload image if new selected
//       if (imageBytes != null) {
//         uploadedUrl =
//             await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
//       }

//       if (item == null) {
//         await SupabaseItemService.addItem(
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           trustScore: 0.0,
//           location: selectedLocation,
//         );
//         _showSnack('Item posted successfully');
//       } else {
//         await SupabaseItemService.updateItem(
//           id: item.id,
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           location: selectedLocation,
//         );
//         _showSnack('Item updated successfully');
//       }

//       if (mounted) Navigator.pop(context, true); // ✅ return true if updated
//     } catch (e) {
//       _showSnack('Failed: $e');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = ['Electronics', 'Furniture', 'Clothes', 'Books', 'Sports', 'Other'];
//     final conditions = ['new', 'good', 'used', 'old'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.itemToEdit == null ? 'Create Listing' : 'Edit Listing'),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (_) => SafeArea(
//                     child: Wrap(
//                       children: [
//                         ListTile(
//                           leading: const Icon(Icons.photo),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           },
//                         ),
//                         ListTile(
//                           leading: const Icon(Icons.camera_alt),
//                           title: const Text('Camera'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.camera);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 height: 180,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: imageBytes != null
//                     ? Image.memory(imageBytes!, fit: BoxFit.cover)
//                     : (imagePreviewPath != null
//                         ? Image.network(imagePreviewPath!, fit: BoxFit.cover)
//                         : const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_a_photo, color: Colors.grey, size: 34),
//                                 SizedBox(height: 8),
//                                 Text('Tap to add photo'),
//                               ],
//                             ),
//                           )),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _descCtrl,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 12),

//             // Dropdowns
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: category,
//                     decoration: const InputDecoration(labelText: 'Category'),
//                     items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                     onChanged: (v) => setState(() => category = v ?? category),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: condition,
//                     decoration: const InputDecoration(labelText: 'Condition'),
//                     items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
//                     onChanged: (v) => setState(() => condition = v ?? condition),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Visible radius (km)', style: TextStyle(fontWeight: FontWeight.w600)),
//                 Text('${radiusKm.toStringAsFixed(0)} km'),
//               ],
//             ),
//             Slider(
//               value: radiusKm,
//               min: 1,
//               max: 200,
//               divisions: 199,
//               onChanged: (v) => setState(() => radiusKm = v),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: Text(_coordLabel()),
//               style: ElevatedButton.styleFrom(backgroundColor: kTeal, minimumSize: const Size(double.infinity, 45)),
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//                 );
//                 if (result != null && result is Map) {
//                   await _setLocationWithName(result['lat'], result['lng']);
//                 }
//               },
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.my_location),
//               label: const Text("Use Current GPS Location"),
//               onPressed: _getCurrentLocation,
//             ),
            
//             const SizedBox(height: 18),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(double.infinity, 50)),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(widget.itemToEdit == null ? 'Post Listing' : 'Update Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// correct code above//
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/item_model.dart';
import '../../services/supabase_item_service.dart';
import '../../utils/app_theme.dart';
import 'location_picker_screen.dart';

class OfferItemScreen extends StatefulWidget {
  final Item? itemToEdit;
  const OfferItemScreen({super.key, this.itemToEdit});

  @override
  State<OfferItemScreen> createState() => _OfferItemScreenState();
}

class _OfferItemScreenState extends State<OfferItemScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String category = 'Electronics';
  String condition = 'good';
  double radiusKm = 10.0;
  Uint8List? imageBytes;
  String? imagePreviewPath;
  bool isLoading = false;
  Map<String, dynamic>? selectedLocation;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    if (item != null) {
      _titleCtrl.text = item.title;
      _descCtrl.text = item.description ?? '';
      category = item.category ?? 'Electronics';
      condition = item.condition ?? 'good';
      radiusKm = item.radiusKm;
      selectedLocation = item.location;
      imagePreviewPath = item.imageUrl;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
        imagePreviewPath = picked.path;
      });
    } catch (e) {
      _showSnack('Image pick failed: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Enable location services first');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('Location permanently denied, please enable in settings');
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    await _setLocationWithName(pos.latitude, pos.longitude);
  }

  /// 🔹 Updated reverse geocoding to include sub-locality, city, admin area, country
  Future<void> _setLocationWithName(double lat, double lng) async {
    String placeName = 'Unknown location';
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        placeName = [
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (_) {}
    setState(() {
      selectedLocation = {'lat': lat, 'lng': lng, 'name': placeName};
    });
  }

  String _coordLabel() {
    if (selectedLocation == null) return 'Select Location on Map';
    return selectedLocation!['name'] ?? 'Unknown location';
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty) {
      _showSnack('Please enter a title');
      return;
    }

    setState(() => isLoading = true);

    try {
      final item = widget.itemToEdit;
      String? uploadedUrl = item?.imageUrl;

      // Upload image if new selected
      if (imageBytes != null) {
        uploadedUrl =
            await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
      }

      if (item == null) {
        await SupabaseItemService.addItem(
          title: title,
          description: desc,
          category: category,
          condition: condition,
          radiusKm: radiusKm,
          imageUrl: uploadedUrl,
          trustScore: 0.0,
          location: selectedLocation,
        );
        _showSnack('Item posted successfully');
      } else {
        await SupabaseItemService.updateItem(
          id: item.id,
          title: title,
          description: desc,
          category: category,
          condition: condition,
          radiusKm: radiusKm,
          imageUrl: uploadedUrl,
          location: selectedLocation,
        );
        _showSnack('Item updated successfully');
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Electronics', 'Furniture', 'Clothes', 'Books', 'Sports', 'Other'];
    final conditions = ['new', 'good', 'used', 'old'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit == null ? 'Create Listing' : 'Edit Listing'),
        backgroundColor: kGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Camera'),
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.cover)
                    : (imagePreviewPath != null
                        ? Image.network(imagePreviewPath!, fit: BoxFit.cover)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey, size: 34),
                                SizedBox(height: 8),
                                Text('Tap to add photo'),
                              ],
                            ),
                          )),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => category = v ?? category),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: condition,
                    decoration: const InputDecoration(labelText: 'Condition'),
                    items: conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => condition = v ?? condition),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Visible radius (km)', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${radiusKm.toStringAsFixed(0)} km'),
              ],
            ),
            Slider(
              value: radiusKm,
              min: 1,
              max: 200,
              divisions: 199,
              onChanged: (v) => setState(() => radiusKm = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: Text(_coordLabel()),
              style: ElevatedButton.styleFrom(backgroundColor: kTeal, minimumSize: const Size(double.infinity, 45)),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                );
                if (result != null && result is Map) {
                  await _setLocationWithName(result['lat'], result['lng']);
                }
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text("Use Current GPS Location"),
              onPressed: _getCurrentLocation,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size(double.infinity, 50)),
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.itemToEdit == null ? 'Post Listing' : 'Update Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
