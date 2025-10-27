
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
//     _loadExistingItem();
//   }

//   void _loadExistingItem() {
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

//   void _resetForm() {
//     setState(() {
//       _titleCtrl.clear();
//       _descCtrl.clear();
//       category = 'Electronics';
//       condition = 'good';
//       radiusKm = 10.0;
//       imageBytes = null;
//       imagePreviewPath = null;
//       selectedLocation = null;
//     });
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
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showSnack('Enable location services first');
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showSnack('Location permission denied');
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         _showSnack('Location permanently denied, please enable in settings');
//         return;
//       }

//       final pos = await Geolocator.getCurrentPosition();
//       await _setLocationWithName(pos.latitude, pos.longitude);
//     } catch (e) {
//       _showSnack('Location error: $e');
//     }
//   }

//   Future<void> _setLocationWithName(double lat, double lng) async {
//     String placeName = 'Unknown location';
//     try {
//       final placemarks = await placemarkFromCoordinates(lat, lng);
//       if (placemarks.isNotEmpty) {
//         final p = placemarks.first;
//         placeName = [
//           p.subLocality,
//           p.locality,
//           p.administrativeArea,
//           p.country
//         ].where((e) => e != null && e.isNotEmpty).join(', ');
//       }
//     } catch (_) {}
//     setState(() {
//       selectedLocation = {'lat': lat, 'lng': lng, 'name': placeName};
//     });
//     debugPrint('✅ Location set: $placeName ($lat, $lng)');
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

//       if (imageBytes != null) {
//         uploadedUrl = await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
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
//           location: selectedLocation ?? {'lat': 0, 'lng': 0, 'name': 'Unknown'},
//         );
//         _showSnack('Item posted successfully');
//         _resetForm();
//       } else {
//         await SupabaseItemService.updateItem(
//           id: item.id,
//           title: title,
//           description: desc,
//           category: category,
//           condition: condition,
//           radiusKm: radiusKm,
//           imageUrl: uploadedUrl,
//           location: selectedLocation ?? item.location,
//         );
//         _showSnack('Item updated successfully');
//       }

//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context, true);
//       }
//     } catch (e, st) {
//       debugPrint('❌ Error posting item: $e\n$st');
//       _showSnack('Something went wrong while posting');
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
//       backgroundColor: kBg,
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(
//           widget.itemToEdit == null ? 'Create Listing' : 'Edit Listing',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: kGreen,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🖼 Image Picker
//             GestureDetector(
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                   ),
//                   builder: (_) => SafeArea(
//                     child: Wrap(
//                       children: [
//                         ListTile(
//                           leading: const Icon(Icons.photo, color: kGreen),
//                           title: const Text('Gallery'),
//                           onTap: () {
//                             Navigator.pop(context);
//                             _pickImage(ImageSource.gallery);
//                           },
//                         ),
//                         ListTile(
//                           leading: const Icon(Icons.camera_alt, color: kGreen),
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
//                 height: 220,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.06),
//                       blurRadius: 14,
//                       spreadRadius: 0,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                   border: Border.all(color: Colors.transparent),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: imageBytes != null
//                       ? Image.memory(imageBytes!, fit: BoxFit.cover)
//                       : (imagePreviewPath != null
//                           ? Image.network(imagePreviewPath!, fit: BoxFit.cover)
//                           : Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 34),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Tap to add photo',
//                                     style: TextStyle(
//                                       color: Colors.grey.shade700,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // 📝 Title & Description
//             TextField(
//               controller: _titleCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Title',
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 14),
//             TextField(
//               controller: _descCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'Description',
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 18),

//             // 🧩 Dropdowns
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: category,
//                     decoration: const InputDecoration(
//                       labelText: 'Category',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     items: categories
//                         .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                         .toList(),
//                     onChanged: (v) => setState(() => category = v ?? category),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: condition,
//                     decoration: const InputDecoration(
//                       labelText: 'Condition',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     items: conditions
//                         .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                         .toList(),
//                     onChanged: (v) => setState(() => condition = v ?? condition),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // 📍 Radius Slider
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Visible radius (km)',
//                         style: TextStyle(fontWeight: FontWeight.w700),
//                       ),
//                       Text('${radiusKm.toStringAsFixed(0)} km'),
//                     ],
//                   ),
//                   SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       trackHeight: 4,
//                       thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
//                     ),
//                     child: Slider(
//                       activeColor: kGreen,
//                       inactiveColor: kGreen.withOpacity(0.2),
//                       value: radiusKm,
//                       min: 1,
//                       max: 200,
//                       divisions: 199,
//                       onChanged: (v) => setState(() => radiusKm = v),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // 📌 Location
//             ElevatedButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: Text(_coordLabel()),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 minimumSize: const Size(double.infinity, 54),
//               ),
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
//                 );
//                 if (result != null && result is Map && mounted) {
//                   await _setLocationWithName(result['lat'], result['lng']);
//                 }
//               },
//             ),
//             const SizedBox(height: 8),
//             Center(
//               child: TextButton.icon(
//                 icon: const Icon(Icons.my_location, color: kGreen),
//                 label: const Text(
//                   "Use Current GPS Location",
//                   style: TextStyle(color: kGreen),
//                 ),
//                 onPressed: _getCurrentLocation,
//               ),
//             ),
//             const SizedBox(height: 20),

//             // 🟢 Submit Button
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kGreen,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16)),
//                 elevation: 3,
//                 minimumSize: const Size(double.infinity, 56),
//               ),
//               onPressed: isLoading ? null : _submit,
//               child: isLoading
//                   ? const SizedBox(
//                       height: 22,
//                       width: 22,
//                       child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
//                     )
//                   : Text(
//                       widget.itemToEdit == null
//                           ? 'Post Listing'
//                           : 'Update Listing',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w600),
//                     ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    _loadExistingItem();
  }

  void _loadExistingItem() {
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
    try {
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
        _showSnack('Location permanently denied, enable in settings');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      await _setLocationWithName(pos.latitude, pos.longitude);
    } catch (e) {
      _showSnack('Location error: $e');
    }
  }

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
          location: selectedLocation ?? {'lat': 0, 'lng': 0, 'name': 'Unknown'},
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
          location: selectedLocation ?? item.location,
        );
        _showSnack('Item updated successfully');
      }

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('Something went wrong while posting');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Electronics',
      'Furniture',
      'Clothes',
      'Books',
      'Sports',
      'Other'
    ];
    final conditions = ['new', 'good', 'used', 'old'];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kGreen,
        elevation: 0,
        title: Text(
          widget.itemToEdit == null ? 'Create Listing' : 'Edit Listing',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Image Picker Section
            GestureDetector(
              onTap: () => _showImagePickerSheet(),
              child: Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kGreen.withOpacity(0.08), kTeal.withOpacity(0.06)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageBytes != null
                          ? Image.memory(imageBytes!, fit: BoxFit.cover)
                          : (imagePreviewPath != null
                              ? Image.network(imagePreviewPath!, fit: BoxFit.cover)
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: kGreen, size: 38),
                                      SizedBox(height: 8),
                                      Text('Tap to add photo', style: TextStyle(color: Colors.black54, fontSize: 14)),
                                    ],
                                  ),
                                )),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.black12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: kGreen),
                        onPressed: _showImagePickerSheet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _SectionHeader(title: 'Listing Details', icon: Icons.description_outlined, color: kGreen),
            const SizedBox(height: 10),

            _inputCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: kTextDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    decoration: _inputDecoration('Enter item title'),
                  ),
                  const SizedBox(height: 14),
                  const Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: kTextDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: _inputDecoration('Describe your item'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const _SectionHeader(title: 'Preferences', icon: Icons.tune_rounded, color: kTeal),
            const SizedBox(height: 10),
            _inputCard(
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: category,
                      isExpanded: true,
                      decoration: _dropdownDecorationWithIcon('Category', Icons.category_outlined),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => category = v ?? category),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: condition,
                      isExpanded: true,
                      decoration: _dropdownDecorationWithIcon('Condition', Icons.verified_outlined),
                      items: conditions
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => condition = v ?? condition),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const _SectionHeader(title: 'Visibility', icon: Icons.remove_red_eye_outlined, color: kAmber),
            const SizedBox(height: 10),
            _inputCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Visible radius (km)',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: kTextDark)),
                      Text('${radiusKm.toInt()} km',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, color: kTeal)),
                    ],
                  ),
                  Slider(
                    activeColor: kGreen,
                    value: radiusKm,
                    min: 1,
                    max: 200,
                    divisions: 199,
                    label: '${radiusKm.toInt()} km',
                    onChanged: (v) => setState(() => radiusKm = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📍 Location
            const _SectionHeader(title: 'Location', icon: Icons.location_on_outlined, color: kTeal),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: Text(
                _coordLabel(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LocationPickerScreen()),
                );
                if (result != null && result is Map && mounted) {
                  await _setLocationWithName(result['lat'], result['lng']);
                }
              },
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.my_location, color: kGreen),
                label: const Text("Use Current GPS Location",
                    style: TextStyle(color: kGreen, fontSize: 13)),
                onPressed: _getCurrentLocation,
              ),
            ),
            const SizedBox(height: 24),

            // 🟢 Submit
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.itemToEdit == null
                          ? 'Post Listing'
                          : 'Update Listing',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: kTeal),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kGreen),
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
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kGreen, width: 1.8)),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kTeal, width: 1.8)),
    );
  }

  InputDecoration _dropdownDecorationWithIcon(String label, IconData icon) {
    final base = _dropdownDecoration(label);
    return base.copyWith(
      prefixIcon: Icon(icon, color: kGreen),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kTextDark),
        ),
      ],
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final Color color;

  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = opt == selected;
        return ChoiceChip(
          label: Text(opt),
          selected: isSel,
          labelStyle: TextStyle(
            color: isSel ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: color,
          backgroundColor: Colors.white,
          side: BorderSide(color: isSel ? color : Colors.black12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: (_) => onChanged(opt),
        );
      }).toList(),
    );
  }
}
