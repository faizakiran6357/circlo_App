
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'radius_selection_screen.dart';
// import '../../utils/app_theme.dart';

// class LocationPermissionScreen extends StatelessWidget {
//   const LocationPermissionScreen({super.key});

//   Future<void> _getAndSaveLocation(BuildContext context) async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enable location services.')),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Permission denied')));
//         return;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Location permission permanently denied.')),
//       );
//       return;
//     }

//     final position =
//         await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//     final supabase = Supabase.instance.client;
//     final user = supabase.auth.currentUser;

//     if (user != null) {
//       await supabase.from('users').update({
//         'location': {
//           'lat': position.latitude,
//           'lng': position.longitude,
//         }
//       }).eq('id', user.id);
//     }

//     // ➜ Go to radius selection next
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_on, color: kTeal, size: 120),
//             const SizedBox(height: 30),
//             Text("Enable Location",
//                 style: Theme.of(context).textTheme.titleLarge,
//                 textAlign: TextAlign.center),
//             const SizedBox(height: 10),
//             Text(
//               "We use your location to show items near you.",
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: kGreen,
//                   minimumSize: const Size(double.infinity, 50)),
//               onPressed: () => _getAndSaveLocation(context),
//               child: const Text("Allow Location Access"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'radius_selection_screen.dart';
import '../../utils/app_theme.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _loading = false;

  Future<void> _getAndSaveLocation() async {
    setState(() => _loading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
        setState(() => _loading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission denied')));
          setState(() => _loading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permission permanently denied.')),
        );
        setState(() => _loading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        await supabase.from('users').update({
          'location': {
            'lat': position.latitude,
            'lng': position.longitude,
          }
        }).eq('id', user.id);
      }

      // Navigate to radius selection
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error getting location')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: kTeal, size: 120),
            const SizedBox(height: 30),
            Text("Enable Location",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              "We use your location to show items near you.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kGreen),
                onPressed: _loading ? null : _getAndSaveLocation,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text("Allow Location Access"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
