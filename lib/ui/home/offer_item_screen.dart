
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

  /// ✅ Clears the form after posting a new listing
  void _resetForm() {
    setState(() {
      _titleCtrl.clear();
      _descCtrl.clear();
      category = 'Electronics';
      condition = 'good';
      radiusKm = 10.0;
      imageBytes = null;
      imagePreviewPath = null;
      selectedLocation = null;
    });
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
        _showSnack('Location permanently denied, please enable in settings');
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
    debugPrint('✅ Location set: $placeName ($lat, $lng)');
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

      // Upload image if newly selected
      if (imageBytes != null) {
        uploadedUrl = await SupabaseItemService.uploadImageToStorage(bytes: imageBytes!);
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
        _resetForm(); // ✅ clear after posting
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
    } catch (e, st) {
      debugPrint('❌ Error posting item: $e\n$st');
      _showSnack('Something went wrong while posting');
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
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
                );
                if (result != null && result is Map && mounted) {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
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
