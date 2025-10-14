// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationPickerScreen extends StatefulWidget {
//   const LocationPickerScreen({super.key});

//   @override
//   State<LocationPickerScreen> createState() => _LocationPickerScreenState();
// }

// class _LocationPickerScreenState extends State<LocationPickerScreen> {
//   GoogleMapController? mapController;
//   LatLng? selectedLocation;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getUserLocation();
//   }

//   Future<void> _getUserLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return;
//     }

//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.deniedForever) return;

//     final position = await Geolocator.getCurrentPosition();
//     setState(() {
//       selectedLocation = LatLng(position.latitude, position.longitude);
//       loading = false;
//     });
//   }

//   void _onMapTap(LatLng pos) {
//     setState(() {
//       selectedLocation = pos;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Location')),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: selectedLocation!,
//                     zoom: 14,
//                   ),
//                   onMapCreated: (c) => mapController = c,
//                   onTap: _onMapTap,
//                   markers: {
//                     if (selectedLocation != null)
//                       Marker(
//                         markerId: const MarkerId('selected'),
//                         position: selectedLocation!,
//                       ),
//                   },
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                 ),
//                 Positioned(
//                   bottom: 20,
//                   left: 40,
//                   right: 40,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(vertical: 14)),
//                     onPressed: () {
//                       if (selectedLocation != null) {
//                         Navigator.pop(context, {
//                           'lat': selectedLocation!.latitude,
//                           'lng': selectedLocation!.longitude,
//                         });
//                       }
//                     },
//                     child: const Text('Confirm Location'),
//                   ),
//                 )
//               ],
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      selectedLocation = LatLng(position.latitude, position.longitude);
      loading = false;
    });
  }

  void _onMapTap(LatLng pos) {
    setState(() {
      selectedLocation = pos;
    });
  }

  /// 🔹 Get full place name from coordinates
  Future<String> _getPlaceName(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (_) {}
    return 'Unknown location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation!,
                    zoom: 14,
                  ),
                  onMapCreated: (c) => mapController = c,
                  onTap: _onMapTap,
                  markers: {
                    if (selectedLocation != null)
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: selectedLocation!,
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 20,
                  left: 40,
                  right: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () async {
                      if (selectedLocation != null) {
                        final name = await _getPlaceName(
                            selectedLocation!.latitude, selectedLocation!.longitude);
                        Navigator.pop(context, {
                          'lat': selectedLocation!.latitude,
                          'lng': selectedLocation!.longitude,
                          'name': name,
                        });
                      }
                    },
                    child: const Text('Confirm Location'),
                  ),
                )
              ],
            ),
    );
  }
}
