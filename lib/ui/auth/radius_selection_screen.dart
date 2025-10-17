

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/items_provider.dart';
// import '../../utils/app_theme.dart';
// import '../home/home_feed_screen.dart'; 

// class RadiusSelectionScreen extends StatefulWidget {
//   const RadiusSelectionScreen({super.key});

//   @override
//   State<RadiusSelectionScreen> createState() => _RadiusSelectionScreenState();
// }

// class _RadiusSelectionScreenState extends State<RadiusSelectionScreen> {
//   double _selectedRadius = 30; // default radius in km

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemsProvider>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Radius'),
//         backgroundColor: kTeal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               'Set your nearby search radius',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               '${_selectedRadius.toInt()} km',
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: kTeal,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Slider(
//               value: _selectedRadius,
//               min: 5,
//               max: 200,
//               divisions: 39,
//               activeColor: kTeal,
//               label: '${_selectedRadius.toInt()} km',
//               onChanged: (value) {
//                 setState(() {
//                   _selectedRadius = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: kTeal,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               icon: const Icon(Icons.check_circle_outline, color: Colors.white),
//               label: const Text(
//                 'Apply Radius',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//               onPressed: () async {
//                 try {
//                   // ✅ Save radius in provider
//                   provider.setSelectedRadius(_selectedRadius);

//                   // ✅ Reload both lists
//                   await provider.loadNearby();
//                   await provider.loadTrending();

//                   // ✅ Navigate to HomeFeedScreen
//                   if (mounted) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const HomeFeedScreen(),
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error updating radius: $e')),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.grey, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:circlo_app/ui/main_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/items_provider.dart';
import '../../utils/app_theme.dart';
import '../home/home_feed_screen.dart';

class RadiusSelectionScreen extends StatefulWidget {
  const RadiusSelectionScreen({super.key});

  @override
  State<RadiusSelectionScreen> createState() => _RadiusSelectionScreenState();
}

class _RadiusSelectionScreenState extends State<RadiusSelectionScreen> {
  double _selectedRadius = 30; // default radius in km
  bool _loading = false; // loading state

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemsProvider>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set your nearby search radius',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Text(
                '${_selectedRadius.toInt()} km',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kTeal,
                ),
              ),
              const SizedBox(height: 20),
              Slider(
                value: _selectedRadius,
                min: 5,
                max: 200,
                divisions: 39,
                activeColor: kTeal,
                label: '${_selectedRadius.toInt()} km',
                onChanged: (value) {
                  setState(() {
                    _selectedRadius = value;
                  });
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: _loading
                      ? const Text('Applying...', style: TextStyle(fontSize: 18))
                      : const Text(
                          'Apply Radius',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            // Save radius in provider
                            provider.setSelectedRadius(_selectedRadius);

                            // Reload lists
                            await provider.loadNearby();
                            await provider.loadTrending();

                            // Navigate to HomeFeedScreen
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MainHomePage(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error updating radius: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
