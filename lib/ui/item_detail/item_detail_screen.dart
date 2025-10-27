
import 'package:circlo_app/ui/exchange/propose_exchange_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/item_model.dart';
import '../../utils/app_theme.dart';
import '../chat/chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  LatLng? itemLatLng;
  String ownerName = 'Unknown User';
  String? ownerAvatar;

  @override
  void initState() {
    super.initState();
    _loadOwner();
    _setItemLatLng();
  }

  void _setItemLatLng() {
    final loc = widget.item.location;
    if (loc != null && loc['lat'] != null && loc['lng'] != null) {
      itemLatLng = LatLng(loc['lat'], loc['lng']);
    }
  }

  Future<void> _loadOwner() async {
    try {
      final supabase = Supabase.instance.client;
      final owner = await supabase
          .from('users')
          .select('display_name, avatar_url')
          .eq('id', widget.item.userId)
          .maybeSingle();

      if (owner != null) {
        setState(() {
          ownerName = owner['display_name'] ?? 'Unknown User';
          ownerAvatar = owner['avatar_url'];
        });
      }
    } catch (_) {}
  }

  String _getLocationText() {
    final loc = widget.item.location;
    if (loc == null || loc.isEmpty) return 'Unknown location';
    if (loc['name'] != null && loc['name'].toString().isNotEmpty) {
      return loc['name'].toString();
    }
    if (loc['lat'] != null && loc['lng'] != null) {
      return "${loc['lat']}, ${loc['lng']}";
    }
    return loc.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract radius (from items table)
    final double? radiusKm = widget.item.radiusKm ?? 0; // ensure not null

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.item.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image with overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.item.imageUrl!,
                          width: double.infinity,
                          height: 260,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 260,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 100, color: Colors.white),
                        ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🧾 Title & Description Card
            Card(
              elevation: 1,
              shadowColor: Colors.black12,
              color: kBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: kTextDark.withOpacity(0.06)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kGreen.withOpacity(0.18)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified, color: kGreen, size: 16),
                              SizedBox(width: 6),
                              Text('Active', style: TextStyle(color: kTextDark, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.item.description ?? "No description provided",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📍 Location Card
            Card(
              elevation: 0,
              color: kBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: kGreen,
                          child: Icon(Icons.location_on, color: Colors.white, size: 18),
                        ),
                        SizedBox(width: 10),
                        Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLocationText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    if (radiusKm != null && radiusKm > 0) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.radio_button_checked, color: kTeal, size: 16),
                            label: Text("Item radius: ${radiusKm.toStringAsFixed(0)} km"),
                            backgroundColor: kTeal.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: kTeal.withOpacity(0.18)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 👤 Owner Card
            Card(
              elevation: 1,
              shadowColor: Colors.black12,
              color: kBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: kTextDark.withOpacity(0.06)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (ownerAvatar != null)
                      CircleAvatar(
                        backgroundImage: NetworkImage(ownerAvatar!),
                        radius: 22,
                      )
                    else
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: kGreen,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ownerName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('Item Owner', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: kAmber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kAmber.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.shield_outlined, color: kAmber, size: 16),
                          SizedBox(width: 6),
                          Text('Profile', style: TextStyle(fontSize: 12, color: kTextDark)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🗺️ Map Card
            if (itemLatLng != null)
              Card(
                elevation: 1,
                shadowColor: Colors.black12,
                color: kBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: kTextDark.withOpacity(0.06)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 240,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: itemLatLng!, zoom: 14),
                      markers: {
                        Marker(
                          markerId: const MarkerId('itemLocation'),
                          position: itemLatLng!,
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text("Chat with Owner"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            itemId: widget.item.id,
                            itemOwnerId: widget.item.userId,
                            itemOwnerName: ownerName,
                            itemOwnerAvatarUrl: ownerAvatar,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProposeExchangeScreen(
                            targetItemId: widget.item.id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text("Propose Exchange"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: kBg,
    );
  }
}

