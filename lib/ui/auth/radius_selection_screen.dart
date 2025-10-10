import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';


class RadiusSelectionScreen extends StatefulWidget {
  const RadiusSelectionScreen({super.key});

  @override
  State<RadiusSelectionScreen> createState() => _RadiusSelectionScreenState();
}

class _RadiusSelectionScreenState extends State<RadiusSelectionScreen> {
  double radius = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, color: kAmber, size: 120),
            const SizedBox(height: 30),
            Text("Choose Your Nearby Radius",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text("${radius.toStringAsFixed(0)} km",
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: kGreen)),
            Slider(
              activeColor: kGreen,
              value: radius,
              min: 1,
              max: 50,
              divisions: 49,
              label: "${radius.toStringAsFixed(0)} km",
              onChanged: (v) => setState(() => radius = v),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                // Navigator.pushReplacement(
                //     context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
