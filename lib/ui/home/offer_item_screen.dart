import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class OfferItemScreen extends StatelessWidget {
  const OfferItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Listing'), backgroundColor: kGreen),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            SizedBox(height: 30),
            Text('Offer Item screen (Module 4) will let user create a listing', textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text('For now this screen is a placeholder — add create-listing backend in Module 4.'),
          ],
        ),
      ),
    );
  }
}
