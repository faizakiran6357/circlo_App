
import 'package:circlo_app/providers/auth_provider.dart';
import 'package:circlo_app/ui/main_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_theme.dart';

class RadiusSelectionScreen extends StatefulWidget {
  const RadiusSelectionScreen({super.key});

  @override
  State<RadiusSelectionScreen> createState() => _RadiusSelectionScreenState();
}

class _RadiusSelectionScreenState extends State<RadiusSelectionScreen> {
  double _selectedRadius = 30; // default radius
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _loading ? null : () => _applyRadius(),
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

Future<void> _applyRadius() async {
  setState(() => _loading = true);

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.setRadius(_selectedRadius);

    // ➜ Navigate to MainHomePage
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainHomePage()),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error applying radius: $e')));
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
}