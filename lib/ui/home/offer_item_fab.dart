// import 'package:flutter/material.dart';
// import '../../utils/app_theme.dart';

// class OfferItemFAB extends StatelessWidget {
//   const OfferItemFAB({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton.extended(
//       backgroundColor: kGreen,
//       onPressed: () {
//         // TODO: Navigate to Offer Item (Create Listing) screen in Module 4
//       },
//       icon: const Icon(Icons.add_rounded),
//       label: const Text("Offer Item"),
//     );
//   }
// }
import 'package:circlo_app/ui/home/offer_item_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class OfferItemFAB extends StatelessWidget {
  const OfferItemFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: kGreen,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Offer Item'),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OfferItemScreen()));
      },
    );
  }
}
