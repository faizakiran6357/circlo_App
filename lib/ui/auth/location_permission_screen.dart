import 'package:circlo_app/ui/auth/radius_selection_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
// import 'radius_selection_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RadiusSelectionScreen()));
              },
              child: const Text("Allow Location Access"),
            ),
          ],
        ),
      ),
    );
  }
}
